#!/system/bin/sh
# =============================================================
# service.sh — Dijalankan setelah boot selesai (late-init)
# MiuiHome Launcher Port: HyperOS 3 → AOSP Android 16
#
# Fungsi:
# - Disable AOSP launcher
# - Set MiuiHome sebagai default home
# - Fix permissions runtime jika perlu
# =============================================================

MODDIR="${0%/*}"
LOG="$MODDIR/service.log"

log_msg() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG"
}

log_msg "=== MiuiHome Port Service started ==="
log_msg "Android: $(getprop ro.build.version.release)"
log_msg "Build: $(getprop ro.build.display.id)"

# Tunggu system benar-benar siap
sleep 10

# --- 1. Disable AOSP Launcher3 ---
log_msg "Disabling AOSP Launcher3..."
for pkg in com.android.launcher3 com.android.launcher com.google.android.apps.nexuslauncher; do
    if pm list packages 2>/dev/null | grep -q "$pkg"; then
        pm disable "$pkg" >> "$LOG" 2>&1
        log_msg "Disabled: $pkg"
    fi
done

# --- 2. Pastikan MiuiHome aktif ---
log_msg "Enabling MiuiHome..."
pm enable com.miui.home >> "$LOG" 2>&1

# --- 3. Set sebagai default HOME ---
# (ini mungkin tidak langsung efektif, user perlu pilih manual pertama kali)
log_msg "Setting MiuiHome as preferred home..."
cmd package set-home-activity com.miui.home/.launcher.Launcher >> "$LOG" 2>&1

# --- 4. Grant permissions yang dibutuhkan ---
log_msg "Granting runtime permissions..."
PERMS="
android.permission.READ_EXTERNAL_STORAGE
android.permission.WRITE_EXTERNAL_STORAGE
android.permission.POST_NOTIFICATIONS
android.permission.READ_PHONE_STATE
android.permission.READ_CONTACTS
android.permission.CAMERA
"
for perm in $PERMS; do
    [ -n "$perm" ] && pm grant com.miui.home "$perm" >> "$LOG" 2>&1
done

# --- 5. Cek apakah MiuiHome berjalan ---
sleep 5
if ps -A 2>/dev/null | grep -q "com.miui.home"; then
    log_msg "✅ MiuiHome is RUNNING!"
else
    log_msg "⚠️  MiuiHome not running yet, triggering..."
    am start -n com.miui.home/.launcher.Launcher >> "$LOG" 2>&1
fi

log_msg "=== Service script done ==="
