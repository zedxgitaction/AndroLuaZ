package com.zade.androluaz;

import android.content.res.AssetManager;
import android.os.Bundle;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * Custom Welcome activity that ensures assets are always copied to the files directory.
 * This fixes the "cannot open main.lua: No such file or directory" error that occurs
 * when the original Welcome's UpdateTask is skipped (e.g., lastUpdateTime = 0 on some devices).
 */
public class Welcome extends com.androlua.Welcome {

    private static final String TAG = "Welcome";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // Copy critical assets BEFORE super.onCreate which may trigger the UpdateTask
        copyAssetsIfNeeded();
        super.onCreate(savedInstanceState);
    }

    private void copyAssetsIfNeeded() {
        try {
            String filesDir = getFilesDir().getAbsolutePath();
            String luaDir = getDir("lua", 0).getAbsolutePath();

            // Copy assets/ entries to filesDir
            copyAssetDir("assets", filesDir);
            // Copy lua/ entries to luaDir
            copyAssetDir("lua", luaDir);

            Log.i(TAG, "Assets copied to " + filesDir + " and " + luaDir);
        } catch (Exception e) {
            Log.e(TAG, "Failed to copy assets: " + e.getMessage());
        }
    }

    private void copyAssetDir(String prefix, String destDir) {
        try {
            AssetManager am = getAssets();
            String[] files = am.list(prefix);
            if (files == null) return;

            for (String name : files) {
                String assetPath = prefix.isEmpty() ? name : prefix + "/" + name;
                String destPath = destDir + File.separator + name;

                // Check if it's a directory
                String[] subFiles = am.list(assetPath);
                if (subFiles != null && subFiles.length > 0) {
                    // It's a directory
                    new File(destPath).mkdirs();
                    copyAssetDir(assetPath, destDir + File.separator + name);
                } else {
                    // It's a file — copy if not exists or size differs
                    File destFile = new File(destPath);
                    if (!destFile.exists()) {
                        copyFile(assetPath, destPath);
                    }
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "copyAssetDir(" + prefix + ") failed: " + e.getMessage());
        }
    }

    private void copyFile(String assetPath, String destPath) {
        try {
            InputStream in = getAssets().open(assetPath);
            File destFile = new File(destPath);
            File parent = destFile.getParentFile();
            if (parent != null && !parent.exists()) parent.mkdirs();

            OutputStream out = new FileOutputStream(destFile);
            byte[] buf = new byte[8192];
            int len;
            while ((len = in.read(buf)) > 0) {
                out.write(buf, 0, len);
            }
            out.close();
            in.close();
            Log.d(TAG, "Copied: " + assetPath + " -> " + destPath);
        } catch (Exception e) {
            Log.e(TAG, "copyFile(" + assetPath + ") failed: " + e.getMessage());
        }
    }
}
