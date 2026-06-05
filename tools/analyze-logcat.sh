#!/bin/bash
# =============================================================
# analyze-logcat.sh — Analisis logcat crash dan identifikasi
#                     class/method yang perlu diimplementasi
# Port: HyperOS 3 Launcher → AOSP Android 16
# =============================================================

TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$TOOLS_DIR")"
LOGCAT_DIR="$ROOT_DIR/logcat-analysis"

echo "======================================================"
echo " 🪲 Logcat Crash Analyzer — MiuiHome Port"
echo "======================================================"

# Bisa: ./analyze-logcat.sh <file>  ATAU  ./analyze-logcat.sh (live ADB)
if [ -n "$1" ]; then
    LOGCAT_FILE="$1"
    if [ ! -f "$LOGCAT_FILE" ]; then
        echo "❌ File tidak ditemukan: $LOGCAT_FILE"
        exit 1
    fi
    echo "📄 Mode: File — $LOGCAT_FILE"
    LOGCAT_CMD="cat \"$LOGCAT_FILE\""
else
    echo "📱 Mode: Live ADB (Ctrl+C untuk stop)"
    echo "   Pastikan device terhubung dan launcher sudah crash/running"
    echo ""
    # Simpan logcat ke file juga
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    LOGCAT_FILE="$LOGCAT_DIR/logcat_${TIMESTAMP}.txt"
    echo "💾 Menyimpan ke: logcat-analysis/logcat_${TIMESTAMP}.txt"
    adb logcat -d > "$LOGCAT_FILE" 2>&1
    LOGCAT_CMD="cat \"$LOGCAT_FILE\""
    echo "✅ Logcat tersimpan!"
    echo ""
fi

echo ""
echo "========================================"
echo " ❌ FATAL EXCEPTIONS / CRASHES"
echo "========================================"
eval "$LOGCAT_CMD" | grep -A 30 "FATAL EXCEPTION" | head -80

echo ""
echo "========================================"
echo " 🔍 ClassNotFoundException"
echo "========================================"
eval "$LOGCAT_CMD" | grep "ClassNotFoundException\|NoClassDefFoundError" | \
    grep -oP '(com\.miui|android\.miui|miuix)\.[a-zA-Z0-9._]+' | \
    sort -u | while read cls; do
        echo "  → PERLU STUB: $cls"
    done

echo ""
echo "========================================"
echo " 🔍 NoSuchMethodException"
echo "========================================"
eval "$LOGCAT_CMD" | grep "NoSuchMethodException\|NoSuchMethodError" | head -20

echo ""
echo "========================================"
echo " 🔍 ServiceNotFoundException"
echo "========================================"
eval "$LOGCAT_CMD" | grep "ServiceNotFoundException\|getService.*null\|service.*not found" | \
    sort -u | head -20

echo ""
echo "========================================"
echo " 🔍 MiuiHome specific errors"
echo "========================================"
eval "$LOGCAT_CMD" | grep -i "miuihome\|miuilauncher\|com.miui.home" | \
    grep -i "error\|exception\|fatal\|crash" | head -30

echo ""
echo "========================================"
echo " 🔍 Native Library errors (.so)"
echo "========================================"
eval "$LOGCAT_CMD" | grep -i "UnsatisfiedLinkError\|dlopen\|can't find.*\.so\|dlopen failed" | \
    sort -u | head -20

# Auto-generate daftar stub yang masih kurang
echo ""
echo "========================================"
echo " 📋 Summary: Action Items"
echo "========================================"

MISSING_CLASSES=$(eval "$LOGCAT_CMD" | \
    grep "ClassNotFoundException\|NoClassDefFoundError" | \
    grep -oP '(com\.miui|android\.miui|miuix)\.[a-zA-Z0-9._]+' | \
    sort -u)

if [ -n "$MISSING_CLASSES" ]; then
    echo ""
    echo "🔴 Class yang belum di-stub (jalankan generate-stubs.sh):"
    echo "$MISSING_CLASSES" | while read cls; do
        echo "   - $cls"
    done
    echo ""
    echo "💡 Jalankan: ./tools/generate-stubs.sh"
else
    echo "✅ Tidak ada ClassNotFoundException baru ditemukan!"
    echo "   Cek bagian lain di atas untuk error lainnya."
fi

MISSING_LIBS=$(eval "$LOGCAT_CMD" | \
    grep "UnsatisfiedLinkError\|dlopen failed" | \
    grep -oP 'lib[a-zA-Z0-9_]+\.so' | sort -u)

if [ -n "$MISSING_LIBS" ]; then
    echo ""
    echo "🔴 Native library yang missing:"
    echo "$MISSING_LIBS" | while read lib; do
        echo "   - $lib  → copy ke native-libs/lib64/"
    done
fi

echo ""
echo "======================================================"
echo " ✅ Analisis selesai. Simpan file logcat di:"
echo "    logcat-analysis/$(basename "$LOGCAT_FILE")"
echo "======================================================"
