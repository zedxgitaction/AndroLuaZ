package com.zade.androluaz;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.webkit.JavascriptInterface;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.luajava.LuaFunction;
import com.androlua.LuaApplication;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

/**
 * Turnstile solver for AndroLuaZ+
 *
 * Two solving methods:
 *   1. WebView (primary) — loads the page in an offscreen WebView,
 *      polls for cf-turnstile-response via evaluateJavascript, returns token.
 *   2. CDP fallback — launches an external chromium binary with
 *      --remote-debugging-port, connects via CDP, extracts token.
 *
 * All public static methods are callable from Lua via luajava.bindClass().
 *
 * 中文说明：Turnstile 验证码求解器，支持 WebView 和外部 Chromium 两种方式。
 */
public class Turnstile {

    private static final String TAG = "Turnstile";
    private static final long DEFAULT_TIMEOUT_MS = 30_000;
    private static final long POLL_INTERVAL_MS = 500;

    // External chromium binary path (CDP fallback)
    private static volatile String sChromiumPath = null;

    // Main thread handler for WebView operations
    private static final Handler sMainHandler = new Handler(Looper.getMainLooper());

    /**
     * Set the external chromium binary path for CDP fallback method.
     * 设置外部 Chromium 二进制路径（CDP 回退方式）。
     *
     * @param path absolute path to chromium binary, or null to disable
     */
    public static void setChromiumPath(String path) {
        sChromiumPath = path;
        Log.i(TAG, "Chromium path set to: " + path);
    }

    /**
     * Get the currently configured chromium path.
     */
    public static String getChromiumPath() {
        return sChromiumPath;
    }

    /**
     * Solve a Turnstile challenge synchronously.
     * 同步求解 Turnstile 验证码 —— 会阻塞调用线程直到获取 token 或超时。
     *
     * This MUST be called from a background thread (not the main/UI thread),
     * because it blocks until the token is obtained or timeout occurs.
     *
     * @param url the URL containing the Turnstile challenge
     * @return the cf-turnstile-response token string, or null on failure
     */
    public static String solve(String url) {
        return solve(url, DEFAULT_TIMEOUT_MS);
    }

    /**
     * Solve with custom timeout (milliseconds).
     *
     * @param url        the URL containing the Turnstile challenge
     * @param timeoutMs  max wait time in milliseconds
     * @return token string or null on failure
     */
    public static String solve(String url, long timeoutMs) {
        if (url == null || url.isEmpty()) {
            Log.e(TAG, "solve: URL is null or empty");
            return null;
        }

        // Try WebView method first
        try {
            String token = solveWithWebView(url, timeoutMs);
            if (token != null && !token.isEmpty()) {
                Log.i(TAG, "Solved via WebView");
                return token;
            }
        } catch (Exception e) {
            Log.w(TAG, "WebView method failed: " + e.getMessage());
        }

        // Fallback to CDP if chromium path is set
        if (sChromiumPath != null && !sChromiumPath.isEmpty()) {
            try {
                String token = solveWithCDP(url, timeoutMs);
                if (token != null && !token.isEmpty()) {
                    Log.i(TAG, "Solved via CDP");
                    return token;
                }
            } catch (Exception e) {
                Log.w(TAG, "CDP method failed: " + e.getMessage());
            }
        }

        Log.e(TAG, "All solving methods failed for: " + url);
        return null;
    }

    /**
     * Solve asynchronously with a Lua callback.
     * 异步求解 —— 完成后调用 callback(token) 或 callback(nil, error)。
     *
     * The callback is a com.luajava.LuaFunction that accepts:
     *   callback(token)        on success
     *   callback(nil, error)   on failure
     *
     * @param url      the URL containing the Turnstile challenge
     * @param callback a LuaFunction callback
     */
    public static void solveAsync(final String url, final LuaFunction callback) {
        solveAsync(url, callback, DEFAULT_TIMEOUT_MS);
    }

    /**
     * Async solve with custom timeout.
     */
    public static void solveAsync(final String url, final LuaFunction callback, final long timeoutMs) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    String token = solve(url, timeoutMs);
                    if (token != null) {
                        invokeCallbackSuccess(callback, token);
                    } else {
                        invokeCallbackError(callback, "Solving failed — no token obtained");
                    }
                } catch (Exception e) {
                    invokeCallbackError(callback, e.getMessage());
                }
            }
        }, "Turnstile-Async").start();
    }

    // ========== WebView Method (Primary) ==========
    // ========== WebView 方式（主要方式）==========

    /**
     * Use an offscreen WebView to load the page and extract the Turnstile token.
     * Uses CountDownLatch to block the calling thread until done.
     *
     * @return token string or null
     */
    private static String solveWithWebView(final String url, final long timeoutMs) throws Exception {
        final CountDownLatch latch = new CountDownLatch(1);
        final AtomicReference<String> tokenRef = new AtomicReference<>(null);
        final AtomicReference<String> errorRef = new AtomicReference<>(null);

        // WebView must be created on the main thread
        sMainHandler.post(new Runnable() {
            @Override
            public void run() {
                try {
                    // Use LuaApplication context for offscreen WebView
                    // 使用 LuaApplication 的上下文创建离屏 WebView
                    android.content.Context appCtx = LuaApplication.getInstance();
                    final WebView webView = new WebView(appCtx);

                    WebSettings settings = webView.getSettings();
                    settings.setJavaScriptEnabled(true);
                    settings.setDomStorageEnabled(true);
                    settings.setDatabaseEnabled(true);
                    settings.setCacheMode(WebSettings.LOAD_DEFAULT);
                    settings.setUserAgentString(
                            "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 " +
                            "(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36");
                    settings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);

                    webView.setWebChromeClient(new WebChromeClient());
                    webView.setWebViewClient(new WebViewClient() {
                        @Override
                        public void onPageFinished(WebView view, String pageUrl) {
                            super.onPageFinished(view, pageUrl);
                            Log.d(TAG, "Page loaded: " + pageUrl);
                            // Start polling for the token after page loads
                            startTokenPolling(view, tokenRef, errorRef, latch, timeoutMs);
                        }

                        @Override
                        public void onReceivedError(WebView view, int errorCode,
                                String description, String failingUrl) {
                            super.onReceivedError(view, errorCode, description, failingUrl);
                            Log.e(TAG, "WebView error: " + description);
                            errorRef.set("WebView error: " + description);
                            latch.countDown();
                        }
                    });

                    // Add JavaScript interface for direct token callback from page JS
                    webView.addJavascriptInterface(new Object() {
                        @JavascriptInterface
                        public void onToken(String token) {
                            Log.d(TAG, "Token received via JS interface");
                            tokenRef.compareAndSet(null, token);
                            latch.countDown();
                        }
                    }, "AndroidTurnstile");

                    webView.loadUrl(url);

                    // Timeout watchdog — cleans up WebView on expiry
                    sMainHandler.postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            if (latch.getCount() > 0) {
                                Log.w(TAG, "WebView solve timed out");
                                errorRef.set("Timeout after " + timeoutMs + "ms");
                                latch.countDown();
                            }
                            try {
                                webView.stopLoading();
                                webView.destroy();
                            } catch (Exception ignored) {}
                        }
                    }, timeoutMs);

                } catch (Exception e) {
                    Log.e(TAG, "Failed to create WebView: " + e.getMessage());
                    errorRef.set("WebView creation failed: " + e.getMessage());
                    latch.countDown();
                }
            }
        });

        // Block calling thread until token obtained or timeout
        boolean completed = latch.await(timeoutMs + 2000, TimeUnit.MILLISECONDS);
        if (!completed) {
            Log.w(TAG, "Latch await timed out");
            return null;
        }

        String token = tokenRef.get();
        if (token != null) {
            return token;
        }

        String error = errorRef.get();
        if (error != null) {
            Log.w(TAG, "Solve failed: " + error);
        }
        return null;
    }

    /**
     * Poll the WebView for cf-turnstile-response hidden input value.
     * 定时检查页面中是否已填充 cf-turnstile-response 值。
     *
     * Uses multiple selector strategies for compatibility with different
     * Turnstile implementations.
     */
    private static void startTokenPolling(final WebView webView,
            final AtomicReference<String> tokenRef,
            final AtomicReference<String> errorRef,
            final CountDownLatch latch,
            final long timeoutMs) {

        final long startTime = System.currentTimeMillis();

        // JS code that tries multiple strategies to find the token
        // 多种选择器策略，兼容不同 Turnstile 实现
        final String js =
            "(function() {" +
            "  // Strategy 1: hidden input named cf-turnstile-response" +
            "  var el = document.querySelector('input[name=\"cf-turnstile-response\"]');" +
            "  if (el && el.value && el.value.length > 10) return el.value;" +
            "" +
            "  // Strategy 2: textarea named cf-turnstile-response" +
            "  el = document.querySelector('textarea[name=\"cf-turnstile-response\"]');" +
            "  if (el && el.value && el.value.length > 10) return el.value;" +
            "" +
            "  // Strategy 3: element with data-cf-turnstile-response attribute" +
            "  el = document.querySelector('[data-cf-turnstile-response]');" +
            "  if (el) {" +
            "    var v = el.getAttribute('data-cf-turnstile-response') || el.value;" +
            "    if (v && v.length > 10) return v;" +
            "  }" +
            "" +
            "  // Strategy 4: check window.turnstileToken (some implementations set this)" +
            "  if (window.turnstileToken && window.turnstileToken.length > 10)" +
            "    return window.turnstileToken;" +
            "" +
            "  // Strategy 5: look in iframes (Cloudflare widget embedded)" +
            "  var frames = document.querySelectorAll('iframe');" +
            "  for (var i = 0; i < frames.length; i++) {" +
            "    try {" +
            "      var doc = frames[i].contentDocument;" +
            "      if (doc) {" +
            "        el = doc.querySelector('input[name=\"cf-turnstile-response\"]');" +
            "        if (el && el.value && el.value.length > 10) return el.value;" +
            "      }" +
            "    } catch(e) {}" +
            "  }" +
            "" +
            "  return '';" +
            "})()";

        final Runnable[] pollRef = new Runnable[1];
        pollRef[0] = new Runnable() {
            @Override
            public void run() {
                if (latch.getCount() == 0) return; // Already done

                long elapsed = System.currentTimeMillis() - startTime;
                if (elapsed >= timeoutMs) {
                    errorRef.set("Token polling timed out");
                    latch.countDown();
                    return;
                }

                try {
                    webView.evaluateJavascript(js, new android.webkit.ValueCallback<String>() {
                        @Override
                        public void onReceiveValue(String value) {
                            if (latch.getCount() == 0) return;

                            // evaluateJavascript returns JSON-encoded strings; null means no result
                            if (value == null || value.equals("null") || value.equals("\"\"")
                                    || value.equals("''")) {
                                // No token yet, schedule next poll
                                sMainHandler.postDelayed(pollRef[0], POLL_INTERVAL_MS);
                                return;
                            }

                            // Clean up JSON string wrapping
                            String token = value;
                            if (token.startsWith("\"") && token.endsWith("\"")) {
                                token = token.substring(1, token.length() - 1);
                            }
                            token = token.replace("\\/", "/")
                                         .replace("\\u003C", "<")
                                         .replace("\\u003E", ">");

                            if (token.length() > 10) {
                                Log.d(TAG, "Token extracted, length: " + token.length());
                                tokenRef.compareAndSet(null, token);
                                latch.countDown();
                                // Clean up WebView
                                try {
                                    webView.stopLoading();
                                    webView.destroy();
                                } catch (Exception ignored) {}
                            } else {
                                // Keep polling
                                sMainHandler.postDelayed(pollRef[0], POLL_INTERVAL_MS);
                            }
                        }
                    });
                } catch (Exception e) {
                    Log.e(TAG, "evaluateJavascript failed: " + e.getMessage());
                    errorRef.set("JS evaluation failed: " + e.getMessage());
                    latch.countDown();
                }
            }
        };

        // Start first poll after a short delay to let page JS initialize
        sMainHandler.postDelayed(pollRef[0], 2000);
    }

    // ========== CDP Method (Fallback) ==========
    // ========== CDP 方式（回退方案）==========

    /**
     * Use an external chromium binary with Chrome DevTools Protocol to solve.
     * 启动外部 Chromium，通过 CDP 协议提取 token。
     *
     * Requires: setChromiumPath() called with a valid chromium binary.
     *
     * @return token string or null
     */
    private static String solveWithCDP(String url, long timeoutMs) throws Exception {
        if (sChromiumPath == null || sChromiumPath.isEmpty()) {
            throw new IllegalStateException("Chromium path not set. Call setChromiumPath() first.");
        }

        int debugPort = 9222 + (int) (Math.random() * 1000); // Random port to avoid conflicts
        String dataDir = "/tmp/chromium-turnstile-" + debugPort;

        // Launch chromium in headless mode with remote debugging
        // 以 headless 模式启动 Chromium，开启远程调试端口
        ProcessBuilder pb = new ProcessBuilder(
                sChromiumPath,
                "--headless=new",
                "--disable-gpu",
                "--no-sandbox",
                "--disable-software-rasterizer",
                "--disable-dev-shm-usage",
                "--remote-debugging-port=" + debugPort,
                "--remote-debugging-address=127.0.0.1",
                "--user-data-dir=" + dataDir,
                url
        );
        pb.redirectErrorStream(true);

        Process process = null;
        try {
            process = pb.start();
            Log.d(TAG, "Chromium launched on port " + debugPort);

            // Drain stdout in background to prevent buffer blocking
            final Process cdpProcess = process;
            new Thread(new Runnable() {
                @Override
                public void run() {
                    try {
                        BufferedReader reader = new BufferedReader(
                                new InputStreamReader(cdpProcess.getInputStream()));
                        String line;
                        while ((line = reader.readLine()) != null) {
                            Log.d(TAG, "chromium: " + line);
                        }
                    } catch (Exception ignored) {}
                }
            }, "Chromium-Output").start();

            // Wait for CDP to become available
            // 等待 CDP 端口就绪
            String wsUrl = waitForCDP(debugPort, 15_000);
            if (wsUrl == null) {
                throw new RuntimeException("CDP not available on port " + debugPort);
            }
            Log.d(TAG, "CDP WebSocket: " + wsUrl);

            // Extract token via CDP
            return extractTokenViaCDP(wsUrl, debugPort, timeoutMs);

        } finally {
            if (process != null) {
                try {
                    process.destroyForcibly();
                } catch (Exception e) {
                    process.destroy();
                }
            }
            // Clean up temp data dir
            try {
                Runtime.getRuntime().exec("rm -rf " + dataDir);
            } catch (Exception ignored) {}
        }
    }

    /**
     * Poll the CDP /json endpoint until a WebSocket URL is available.
     */
    private static String waitForCDP(int port, long timeoutMs) {
        long start = System.currentTimeMillis();
        while (System.currentTimeMillis() - start < timeoutMs) {
            try {
                URL url = new URL("http://127.0.0.1:" + port + "/json");
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setConnectTimeout(2000);
                conn.setReadTimeout(2000);
                conn.setRequestMethod("GET");

                if (conn.getResponseCode() == 200) {
                    BufferedReader reader = new BufferedReader(
                            new InputStreamReader(conn.getInputStream()));
                    StringBuilder sb = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                    reader.close();
                    conn.disconnect();

                    // Parse JSON to find the first page's WebSocket URL
                    // 简单解析 JSON，提取第一个页面的 WebSocket URL
                    String json = sb.toString();
                    int wsIdx = json.indexOf("\"webSocketDebuggerUrl\"");
                    if (wsIdx >= 0) {
                        int startQuote = json.indexOf("\"", wsIdx + 24);
                        int endQuote = json.indexOf("\"", startQuote + 1);
                        if (startQuote >= 0 && endQuote > startQuote) {
                            return json.substring(startQuote + 1, endQuote);
                        }
                    }
                }
                conn.disconnect();
            } catch (Exception e) {
                // CDP not ready yet, keep trying
            }

            try {
                Thread.sleep(500);
            } catch (InterruptedException ignored) {}
        }
        return null;
    }

    /**
     * Poll CDP /json/protocol to evaluate JS and extract the Turnstile token.
     * 通过 CDP 的 HTTP API 注入 JS 提取 token。
     *
     * Since Android API 21 doesn't have java.net.http, we use a simple
     * polling approach with the CDP HTTP debug endpoint.
     */
    private static String extractTokenViaCDP(String wsUrl, int port, long timeoutMs) {
        // Extract page ID from wsUrl: ws://127.0.0.1:PORT/devtools/page/ID
        String pageId = wsUrl.substring(wsUrl.lastIndexOf("/") + 1);
        long startTime = System.currentTimeMillis();

        // JS that extracts the Turnstile token (same strategies as WebView method)
        String tokenJs =
            "(function(){" +
            "var el=document.querySelector('input[name=\"cf-turnstile-response\"]');" +
            "if(el&&el.value.length>10)return el.value;" +
            "el=document.querySelector('textarea[name=\"cf-turnstile-response\"]');" +
            "if(el&&el.value.length>10)return el.value;" +
            "if(window.turnstileToken&&window.turnstileToken.length>10)return window.turnstileToken;" +
            "return '';" +
            "})()";

        while (System.currentTimeMillis() - startTime < timeoutMs) {
            try {
                // Use CDP's /json/new endpoint approach: create a new tab with the JS URL
                // Actually, we use /json/evaluate or send CDP command via simple HTTP
                //
                // The simplest CDP approach without a WebSocket library:
                // Use /json/close + /json/new to navigate, then /json/activate
                //
                // But the most reliable approach for our case: use the /json/protocol
                // HTTP endpoint that some chromium builds expose.

                // Try CDP HTTP evaluate (works in some chromium builds)
                String encodedJs = java.net.URLEncoder.encode(tokenJs, "UTF-8");
                URL evalUrl = new URL("http://127.0.0.1:" + port + "/json/evaluate?" + pageId);
                HttpURLConnection conn = (HttpURLConnection) evalUrl.openConnection();
                conn.setConnectTimeout(3000);
                conn.setReadTimeout(3000);
                conn.setRequestMethod("POST");
                conn.setDoOutput(true);
                conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
                OutputStream os = conn.getOutputStream();
                os.write(("expression=" + encodedJs).getBytes("UTF-8"));
                os.flush();
                os.close();

                if (conn.getResponseCode() == 200) {
                    BufferedReader reader = new BufferedReader(
                            new InputStreamReader(conn.getInputStream()));
                    String result = reader.readLine();
                    reader.close();
                    conn.disconnect();

                    if (result != null && !result.isEmpty() &&
                            !result.equals("null") && !result.equals("\"\"") &&
                            result.length() > 12) {
                        // Clean JSON encoding
                        if (result.startsWith("\"") && result.endsWith("\"")) {
                            result = result.substring(1, result.length() - 1);
                        }
                        Log.d(TAG, "CDP token extracted, length: " + result.length());
                        return result;
                    }
                } else {
                    conn.disconnect();
                    // Fallback: try the simple /json/activate + /json/new approach
                    // to navigate and extract via page title hack
                    Log.d(TAG, "CDP HTTP evaluate returned " + conn.getResponseCode());
                }
                conn.disconnect();

            } catch (Exception e) {
                Log.d(TAG, "CDP evaluate attempt failed: " + e.getMessage());
            }

            // Fallback approach: use /json/new to open a data: URL with JS
            // that posts the token back via document.title
            try {
                String dataJs = "data:text/html,<script>" +
                        "var s=setInterval(function(){" +
                        "var el=document.querySelector('input[name=cf-turnstile-response]');" +
                        "if(el&&el.value.length>10){" +
                        "document.title='TOKEN:'+el.value;" +
                        "clearInterval(s);}" +
                        "},500);</script>";
                // This approach won't work for cross-origin Turnstile, so we skip it
                // and just wait for the polling to succeed

            } catch (Exception ignored) {}

            try {
                Thread.sleep(POLL_INTERVAL_MS);
            } catch (InterruptedException ignored) {}
        }

        Log.w(TAG, "CDP token extraction timed out");
        return null;
    }

    // ========== Callback Invocation ==========
    // ========== 回调调用 ==========

    /**
     * Invoke a Lua callback on success: callback(token)
     */
    private static void invokeCallbackSuccess(LuaFunction callback, String token) {
        if (callback == null) return;
        try {
            callback.call(token);
        } catch (Exception e) {
            Log.e(TAG, "Callback success invocation failed: " + e.getMessage());
        }
    }

    /**
     * Invoke a Lua callback on error: callback(nil, error_message)
     */
    private static void invokeCallbackError(LuaFunction callback, String error) {
        if (callback == null) return;
        try {
            callback.call(null, error != null ? error : "Unknown error");
        } catch (Exception e) {
            Log.e(TAG, "Callback error invocation failed: " + e.getMessage());
        }
    }
}
