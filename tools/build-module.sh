#!/bin/bash
# =============================================================
# build-module.sh — Package semua jadi Magisk Module ZIP
# MiuiHome Launcher Port: HyperOS 3 → AOSP Android 16
# =============================================================

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
MODULE_DIR="$ROOT_DIR/magisk-module"
APK_SRC="$ROOT_DIR/apk-extract/MiuiHome.apk"
FRAMEWORK_DIR="$ROOT_DIR/docs/jars"
NATIVE_DIR="$ROOT_DIR/native-libs/lib64"
OUTPUT_DIR="$ROOT_DIR/output"

mkdir -p "$OUTPUT_DIR"

echo "======================================================"
echo " 📦 Build Magisk Module"
echo " MiuiHome Launcher Port — HyperOS 3 → AOSP A16"
echo "======================================================"

# --- Validasi file wajib ---
echo ""
echo "[1/5] Validasi file..."
MISSING=0

if [ ! -f "$APK_SRC" ]; then
    echo "  ❌ MiuiHome.apk tidak ditemukan di apk-extract/"
    MISSING=1
else
    echo "  ✅ MiuiHome.apk — $(du -sh "$APK_SRC" | cut -f1)"
fi

if [ ! -f "$FRAMEWORK_DIR/xiaomi-framework.jar" ]; then
    echo "  ⚠️  xiaomi-framework.jar tidak ada — launcher mungkin crash"
else
    echo "  ✅ xiaomi-framework.jar"
fi

if [ ! -f "$FRAMEWORK_DIR/miuix.jar" ]; then
    echo "  ⚠️  miuix.jar tidak ada — UI mungkin crash"
else
    echo "  ✅ miuix.jar"
fi

[ "$MISSING" -eq 1 ] && echo "❌ File wajib kurang, batalkan build" && exit 1

# --- Copy APK ke module ---
echo ""
echo "[2/5] Copy MiuiHome.apk..."
cp "$APK_SRC" "$MODULE_DIR/system/product/priv-app/MiuiHome/MiuiHome.apk"
echo "  ✅ APK copied ($(du -sh "$MODULE_DIR/system/product/priv-app/MiuiHome/MiuiHome.apk" | cut -f1))"

# --- Copy framework JARs ---
echo ""
echo "[3/5] Copy framework JARs..."
if [ -f "$FRAMEWORK_DIR/xiaomi-framework.jar" ]; then
    cp "$FRAMEWORK_DIR/xiaomi-framework.jar" "$MODULE_DIR/system/framework/"
    echo "  ✅ xiaomi-framework.jar"
fi
if [ -f "$FRAMEWORK_DIR/miuix.jar" ]; then
    cp "$FRAMEWORK_DIR/miuix.jar" "$MODULE_DIR/system/framework/"
    echo "  ✅ miuix.jar"
fi

# --- Copy native libs (jika ada yang perlu di-expose ke system) ---
echo ""
echo "[4/5] Copy native libs..."
if ls "$NATIVE_DIR"/*.so 2>/dev/null | head -1 | grep -q ".so"; then
    mkdir -p "$MODULE_DIR/system/lib64"
    cp "$NATIVE_DIR"/*.so "$MODULE_DIR/system/lib64/" 2>/dev/null
    LIB_COUNT=$(ls "$MODULE_DIR/system/lib64/"*.so 2>/dev/null | wc -l)
    echo "  ✅ $LIB_COUNT native libs copied"
else
    echo "  ℹ️  Tidak ada native libs eksternal (libs sudah di dalam APK)"
fi

# --- Package jadi ZIP ---
echo ""
echo "[5/5] Packaging menjadi ZIP..."
TIMESTAMP=$(date +%Y%m%d)
OUTPUT_ZIP="$OUTPUT_DIR/MiuiHome-Port-AOSP-A16-munch-${TIMESTAMP}.zip"

cd "$MODULE_DIR"
zip -r "$OUTPUT_ZIP" . \
    --exclude "*.DS_Store" \
    --exclude "*Thumbs.db" \
    2>&1 | tail -5

echo ""
echo "======================================================"
echo " ✅ Build selesai!"
echo ""
echo " 📦 Output: output/$(basename "$OUTPUT_ZIP")"
echo " 📏 Size  : $(du -sh "$OUTPUT_ZIP" | cut -f1)"
echo ""
echo " Cara install:"
echo "   1. Copy ZIP ke HP"
echo "   2. Buka Magisk → Modules → Install from storage"
echo "   3. Pilih file ZIP"
echo "   4. Reboot"
echo ""
echo " ⚠️  Jika bootloop setelah reboot:"
echo "   • Tahan Volume- saat boot Magisk → safe mode"
echo "   • Atau masuk recovery → hapus module"
echo "     /data/adb/modules/miuihome-port-aosp"
echo "======================================================"
