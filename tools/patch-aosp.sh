#!/bin/bash
# =============================================================
# patch-aosp.sh — Copy semua file ke lokasi yang benar
#                 di source tree AOSP kamu
# Port: HyperOS 3 Launcher → AOSP Android 16
# =============================================================

set -e
TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$TOOLS_DIR")"
STUBS_DIR="$ROOT_DIR/framework-stubs/src/main/java"
NATIVE_DIR="$ROOT_DIR/native-libs"
DEVICE_DIR="$ROOT_DIR/device-tree/munch"
PATCHES_DIR="$ROOT_DIR/patches"
APK_SRC="$ROOT_DIR/apk-extract"

echo "======================================================"
echo " 🔧 Patch AOSP Source Tree"
echo " Port: HyperOS 3 Launcher → AOSP Android 16"
echo " Device: Poco F4 (munch)"
echo "======================================================"

# --- Cek AOSP path ---
if [ -z "$AOSP_ROOT" ]; then
    echo ""
    echo "⚠️  Variabel AOSP_ROOT belum diset!"
    echo "   Set path ke root source AOSP kamu:"
    echo ""
    echo "   export AOSP_ROOT=/path/ke/aosp-android16"
    echo "   ./tools/patch-aosp.sh"
    echo ""
    read -rp "   Atau masukkan path AOSP sekarang: " AOSP_ROOT
    if [ ! -d "$AOSP_ROOT/frameworks/base" ]; then
        echo "❌ Path tidak valid atau bukan AOSP root."
        exit 1
    fi
fi

echo "📁 AOSP Root: $AOSP_ROOT"
echo ""

# --- 1. Copy Stub Classes ke frameworks/base ---
echo "[1/5] Copy stub classes ke frameworks/base..."
STUBS_COUNT=$(find "$STUBS_DIR" -name "*.java" 2>/dev/null | wc -l)
if [ "$STUBS_COUNT" -gt 0 ]; then
    cp -rv "$STUBS_DIR/"* "$AOSP_ROOT/frameworks/base/core/java/" 2>&1 | \
        sed 's/^/  /'
    echo "  ✅ $STUBS_COUNT stub files copied"
else
    echo "  ⚠️  Tidak ada stub file. Jalankan generate-stubs.sh dulu."
fi

# --- 2. Apply patch frameworks/base ---
echo ""
echo "[2/5] Apply patches ke frameworks/base..."
for patch in "$PATCHES_DIR/frameworks-base/"*.patch; do
    if [ -f "$patch" ]; then
        echo "  Applying: $(basename "$patch")"
        patch -p1 -d "$AOSP_ROOT" < "$patch" || echo "  ⚠️  Patch gagal, cek manual"
    fi
done
# Apply SystemServer patch
for patch in "$PATCHES_DIR/SystemServer/"*.patch; do
    if [ -f "$patch" ]; then
        echo "  Applying: $(basename "$patch")"
        patch -p1 -d "$AOSP_ROOT" < "$patch" || echo "  ⚠️  Patch gagal, cek manual"
    fi
done
echo "  ✅ Patches applied"

# --- 3. Copy MiuiHome.apk ke AOSP ---
echo ""
echo "[3/5] Copy MiuiHome.apk ke device priv-app..."
APK_FILE=$(find "$APK_SRC" -maxdepth 1 -name "*.apk" | head -1)
if [ -n "$APK_FILE" ]; then
    PRIV_APP_DIR="$AOSP_ROOT/vendor/munch/proprietary/system_ext/priv-app/MiuiHome"
    mkdir -p "$PRIV_APP_DIR"
    cp "$APK_FILE" "$PRIV_APP_DIR/"
    echo "  ✅ $(basename "$APK_FILE") → vendor/munch/.../MiuiHome/"
else
    echo "  ⚠️  MiuiHome.apk tidak ditemukan di apk-extract/"
fi

# --- 4. Copy native libs ---
echo ""
echo "[4/5] Copy native libraries..."
LIB64_DST="$AOSP_ROOT/vendor/munch/proprietary/system/lib64"
LIB_DST="$AOSP_ROOT/vendor/munch/proprietary/system/lib"
mkdir -p "$LIB64_DST" "$LIB_DST"

LIB64_COUNT=$(find "$NATIVE_DIR/lib64" -name "*.so" 2>/dev/null | wc -l)
LIB_COUNT=$(find "$NATIVE_DIR/lib" -name "*.so" 2>/dev/null | wc -l)

if [ "$LIB64_COUNT" -gt 0 ]; then
    cp "$NATIVE_DIR/lib64/"*.so "$LIB64_DST/" 2>/dev/null
    echo "  ✅ $LIB64_COUNT lib64 files copied"
fi
if [ "$LIB_COUNT" -gt 0 ]; then
    cp "$NATIVE_DIR/lib/"*.so "$LIB_DST/" 2>/dev/null
    echo "  ✅ $LIB_COUNT lib files copied"
fi
if [ "$LIB64_COUNT" -eq 0 ] && [ "$LIB_COUNT" -eq 0 ]; then
    echo "  ⚠️  Tidak ada .so file di native-libs/"
fi

# --- 5. Copy device tree additions ---
echo ""
echo "[5/5] Copy device tree config..."
if [ -d "$DEVICE_DIR" ]; then
    MUNCH_TREE="$AOSP_ROOT/device/xiaomi/munch"
    if [ -d "$MUNCH_TREE" ]; then
        cp -rv "$DEVICE_DIR/"* "$MUNCH_TREE/" 2>&1 | sed 's/^/  /'
        echo "  ✅ Device tree updated"
    else
        echo "  ⚠️  Device tree munch tidak ada di: $MUNCH_TREE"
        echo "      Copy manual: cp -r device-tree/munch/* /path/ke/device/xiaomi/munch/"
    fi
fi

echo ""
echo "======================================================"
echo " ✅ Patching selesai!"
echo ""
echo " Selanjutnya (di terminal AOSP):"
echo "   cd \$AOSP_ROOT"
echo "   source build/envsetup.sh"
echo "   lunch aosp_munch-ap4a-userdebug   # atau sesuai target"
echo "   m -j\$(nproc) 2>&1 | tee build.log"
echo ""
echo " Setelah flash, ambil logcat:"
echo "   adb logcat | tee logcat-analysis/logcat_\$(date +%Y%m%d).txt"
echo "   ./tools/analyze-logcat.sh logcat-analysis/logcat_*.txt"
echo "======================================================"
