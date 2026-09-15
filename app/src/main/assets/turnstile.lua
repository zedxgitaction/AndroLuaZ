--
-- turnstile.lua — Cloudflare Turnstile solver module for AndroLuaZ+
--
-- Provides a convenient Lua interface to the Java Turnstile class.
-- Supports both synchronous and asynchronous solving via WebView or CDP.
--
-- 中文说明：Turnstile 验证码求解模块，支持同步/异步两种调用方式。
--
-- Usage / 用法：
--
--   local turnstile = require "turnstile"
--
--   -- Synchronous (blocks current thread — run in coroutine or background) / 同步（阻塞当前线程）
--   local token, err = turnstile.solve("https://example.com/with-turnstile")
--   if token then
--       print("Got token: " .. token:sub(1, 30) .. "...")
--   else
--       print("Failed: " .. (err or "unknown error"))
--   end
--
--   -- Asynchronous / 异步
--   turnstile.solveAsync("https://example.com/with-turnstile", function(token, err)
--       if token then
--           print("Async token: " .. token:sub(1, 30) .. "...")
--       else
--           print("Async failed: " .. (err or "unknown error"))
--       end
--   end)
--
--   -- Configure external chromium for CDP fallback / 配置外部 Chromium 路径
--   turnstile.setChromiumPath("/data/local/tmp/chromium")
--

local M = {}

-- Try to load the Java Turnstile class
-- 尝试加载 Java Turnstile 类
local ok, TurnstileClass = pcall(luajava.bindClass, "com.zade.androluaz.Turnstile")
if not ok then
    -- Class not available — return stub functions with error messages
    -- 类不可用时返回空函数，避免脚本崩溃
    local function notAvailable(url, ...)
        return nil, "Turnstile class not available (com.zade.androluaz.Turnstile not found)"
    end

    M.solve = notAvailable
    M.solveAsync = function(url, callback)
        if callback then
            pcall(callback, nil, "Turnstile class not available")
        end
    end
    M.setChromiumPath = function() end
    M.isAvailable = false

    print("[turnstile] WARNING: Java Turnstile class not found — module loaded as stub")
    return M
end

M.isAvailable = true

--- Solve a Turnstile challenge synchronously.
--- 同步求解 Turnstile 验证码（会阻塞调用线程）。
---
--- IMPORTANT: This blocks the calling thread. In AndroLua, if called on the
--- main/UI thread it will cause an ANR. Use in a coroutine or thread.
--- 重要：此方法会阻塞线程，不要在 UI 线程直接调用。
---
--- @param url string — the page URL containing the Turnstile widget
--- @return string|nil token — the cf-turnstile-response token, or nil on failure
--- @return string|nil error — error message when token is nil
function M.solve(url)
    if not url or url == "" then
        return nil, "URL is empty"
    end

    local ok, result = pcall(TurnstileClass.solve, url)
    if not ok then
        return nil, "Java exception: " .. tostring(result)
    end

    if result and result ~= "" then
        return tostring(result)
    end

    return nil, "Solving failed — no token obtained (timeout or blocked)"
end

--- Solve with custom timeout in milliseconds.
--- 自定义超时时间的同步求解。
---
--- @param url string — the page URL
--- @param timeoutMs number — timeout in milliseconds (default 30000)
--- @return string|nil token
--- @return string|nil error
function M.solveWithTimeout(url, timeoutMs)
    if not url or url == "" then
        return nil, "URL is empty"
    end

    timeoutMs = timeoutMs or 30000

    local ok, result = pcall(TurnstileClass.solve, url, timeoutMs)
    if not ok then
        return nil, "Java exception: " .. tostring(result)
    end

    if result and result ~= "" then
        return tostring(result)
    end

    return nil, "Solving failed — no token obtained"
end

--- Solve a Turnstile challenge asynchronously.
--- 异步求解 Turnstile 验证码 —— 完成后调用 callback。
---
--- The callback receives: callback(token, error)
---   - On success: callback(token_string, nil)
---   - On failure: callback(nil, error_string)
---
--- @param url string — the page URL
--- @param callback function — function(token, error) called when done
--- @param timeoutMs number|nil — optional timeout (default 30000)
function M.solveAsync(url, callback, timeoutMs)
    if not url or url == "" then
        if callback then
            callback(nil, "URL is empty")
        end
        return
    end

    if not callback then
        callback = function() end
    end

    -- In AndroLua, luaj auto-converts Lua functions to LuaFunction objects
    -- when passed to Java methods expecting that type.
    -- 在 AndroLua 中，luaj 会自动将 Lua 函数转换为 LuaFunction 对象。
    local ok, err
    if timeoutMs then
        ok, err = pcall(TurnstileClass.solveAsync, url, callback, timeoutMs)
    else
        ok, err = pcall(TurnstileClass.solveAsync, url, callback)
    end

    if not ok then
        if callback then
            callback(nil, "Java exception: " .. tostring(err))
        end
    end
end

--- Set the external chromium binary path for CDP fallback.
--- 设置外部 Chromium 二进制路径（CDP 回退方式）。
---
--- When WebView solving fails, the system will try using this chromium
--- binary with Chrome DevTools Protocol as a fallback.
---
--- @param path string — absolute path to chromium binary
function M.setChromiumPath(path)
    local ok, err = pcall(TurnstileClass.setChromiumPath, path)
    if not ok then
        error("Failed to set chromium path: " .. tostring(err))
    end
end

--- Get the currently configured chromium path.
--- @return string|nil
function M.getChromiumPath()
    local ok, result = pcall(TurnstileClass.getChromiumPath)
    if ok and result then
        return tostring(result)
    end
    return nil
end

return M
