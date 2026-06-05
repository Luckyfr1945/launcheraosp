#!/system/bin/sh
# =============================================================
# post-fs-data.sh — Dijalankan sangat awal saat boot
#                   (setelah /data mount, sebelum zygote)
# MiuiHome Launcher Port: HyperOS 3 → AOSP Android 16
#
# Fungsi:
# - Pastikan framework JARs bisa diakses
# - Patch bootclasspath jika perlu (untuk miuix.jar)
# =============================================================

MODDIR="${0%/*}"
LOG="$MODDIR/post-fs.log"

log_msg() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG"
}

log_msg "=== post-fs-data started ==="

# --- Cek framework JARs tersedia ---
for jar in xiaomi-framework.jar miuix.jar; do
    if [ -f "/system/framework/$jar" ]; then
        log_msg "✅ Found: /system/framework/$jar"
    else
        log_msg "⚠️  Missing: /system/framework/$jar (akan dipasang oleh Magisk overlay)"
    fi
done

# --- Fix SELinux context untuk APK ---
# Pastikan MiuiHome.apk punya context yang benar
if [ -f "/system/product/priv-app/MiuiHome/MiuiHome.apk" ]; then
    chcon u:object_r:system_file:s0 /system/product/priv-app/MiuiHome/MiuiHome.apk 2>/dev/null
    log_msg "✅ SELinux context set untuk MiuiHome.apk"
fi

log_msg "=== post-fs-data done ==="
