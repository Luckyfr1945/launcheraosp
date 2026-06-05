// =============================================================
// Contoh Stub Class — com.miui.home.launcher.LauncherModel
// Port: HyperOS 3 Launcher → AOSP Android 16
//
// Letakkan file ini di AOSP:
//   frameworks/base/core/java/com/miui/home/launcher/LauncherModel.java
//
// CARA KERJA:
//   Stub ini membuat AOSP "pura-pura" punya class Xiaomi
//   sehingga launcher tidak ClassNotFoundException.
//   Method yang dipanggil akan return nilai aman/default.
// =============================================================

package com.miui.home.launcher;

import android.content.Context;
import android.util.Log;

/**
 * Stub: LauncherModel
 *
 * Class asli di HyperOS bertanggung jawab untuk:
 * - Load app list dari system
 * - Manage workspace items (icons, widgets, folders)
 * - Sinkronisasi dengan launcher database
 *
 * Implementasi stub ini hanya mencegah crash. Setelah launcher
 * berjalan, tambahkan implementasi bertahap sesuai logcat.
 */
public class LauncherModel {

    private static final String TAG = "LauncherModel[STUB]";
    private static LauncherModel sInstance;

    private final Context mContext;

    private LauncherModel(Context context) {
        this.mContext = context;
        Log.w(TAG, "LauncherModel stub initialized (HyperOS→AOSP port)");
    }

    public static LauncherModel getInstance(Context context) {
        if (sInstance == null) {
            sInstance = new LauncherModel(context.getApplicationContext());
        }
        return sInstance;
    }

    /** Biasanya dipakai untuk cek apakah model sudah siap */
    public boolean isLoaded() {
        Log.w(TAG, "isLoaded() stub → returning true");
        return true;
    }

    /** Cek apakah app tertentu ada */
    public boolean isPackageInstalled(String packageName) {
        try {
            mContext.getPackageManager().getPackageInfo(packageName, 0);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Stub untuk callback load selesai.
     * Di implementasi asli ini fire event ke launcher activity.
     */
    public interface ModelCallback {
        void onModelLoaded();
    }

    public void addCallback(ModelCallback callback) {
        Log.w(TAG, "addCallback() stub → immediately calling onModelLoaded()");
        if (callback != null) {
            callback.onModelLoaded();
        }
    }

    public void removeCallback(ModelCallback callback) {
        // no-op stub
    }

    /** Force reload app list */
    public void forceReload() {
        Log.w(TAG, "forceReload() stub → no-op");
    }

    // =========================================================
    // TODO: Setelah logcat pertama, isi method yang missing:
    //
    // public ShortcutInfo getShortcutInfo(Intent intent) {
    //     return null;  // atau implementasi AOSP-equivalent
    // }
    //
    // public List<AppInfo> getAllAppsList() {
    //     return new ArrayList<>();
    // }
    // =========================================================
}
