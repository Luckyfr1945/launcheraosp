#!/bin/bash
# =============================================================
# generate-stubs.sh — Auto-generate skeleton stub .java files
#                     untuk setiap class Xiaomi yang ditemukan
#                     di analisis dependencies
# Port: HyperOS 3 Launcher → AOSP Android 16
# =============================================================

set -e
TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$TOOLS_DIR")"
DEPS_FILE="$ROOT_DIR/docs/DEPENDENCIES.md"
STUBS_DIR="$ROOT_DIR/framework-stubs/src/main/java"
SMALI_DIR="$ROOT_DIR/apk-extract/apktool"

echo "======================================================"
echo " 🏗️  Generate Framework Stub Classes"
echo " Target: framework-stubs/src/main/java/"
echo "======================================================"

mkdir -p "$STUBS_DIR"

# Fungsi: buat satu stub class
make_stub_class() {
    local FULL_CLASS="$1"   # e.g. com.miui.home.launcher.LauncherModel
    local PACKAGE="${FULL_CLASS%.*}"
    local CLASSNAME="${FULL_CLASS##*.}"

    local DIR="$STUBS_DIR/$(echo "$PACKAGE" | tr '.' '/')"
    local FILE="$DIR/${CLASSNAME}.java"

    mkdir -p "$DIR"

    if [ -f "$FILE" ]; then
        return  # skip jika sudah ada
    fi

    cat > "$FILE" << JAVA_EOF
// AUTO-GENERATED STUB — Port HyperOS 3 Launcher → AOSP Android 16
// Class: ${FULL_CLASS}
// NOTE: Ini adalah stub kosong agar launcher tidak ClassNotFoundError
//       Isi method sesuai kebutuhan setelah analisis logcat

package ${PACKAGE};

import android.util.Log;

/**
 * Stub class untuk ${CLASSNAME} (HyperOS 3 → AOSP Android 16)
 *
 * Cara penggunaan:
 * 1. Cek logcat crash log di logcat-analysis/
 * 2. Lihat method mana yang dipanggil
 * 3. Implementasikan method tersebut dengan nilai default/AOSP-equivalent
 */
public class ${CLASSNAME} {

    private static final String TAG = "${CLASSNAME}";

    // Singleton pattern (banyak dipakai Xiaomi)
    private static ${CLASSNAME} sInstance;

    public static ${CLASSNAME} getInstance() {
        if (sInstance == null) {
            sInstance = new ${CLASSNAME}();
        }
        return sInstance;
    }

    // TODO: Setelah logcat pertama, tambahkan method yang missing di sini
    // Contoh:
    // public void someXiaomiMethod() {
    //     Log.w(TAG, "someXiaomiMethod: stub called, not implemented");
    // }
    //
    // public boolean isFeatureEnabled(String feature) {
    //     return false; // safe default
    // }
    //
    // public int getIntValue(String key, int def) {
    //     return def;
    // }
}
JAVA_EOF

    echo "  ✅ Created: ${FULL_CLASS}"
}

# --- Scan smali untuk class-class yang perlu di-stub ---
FOUND_CLASSES=()

if [ -d "$SMALI_DIR" ]; then
    echo ""
    echo "📂 Scanning smali files..."
    SMALI_DIRS=$(find "$SMALI_DIR" -name "smali*" -type d 2>/dev/null)

    # Kumpulkan class dari com.miui
    while IFS= read -r cls; do
        [ -n "$cls" ] && FOUND_CLASSES+=("$cls")
    done < <(
        find $SMALI_DIRS -name "*.smali" 2>/dev/null | \
        xargs grep -h "Lcom/miui/" 2>/dev/null | \
        grep -oP 'Lcom/miui/[a-zA-Z0-9_$/]+' | \
        grep -v '\$' | \
        sed 's|L||;s|/|.|g' | \
        sort -u | head -100
    )

    # Kumpulkan class dari android.miui
    while IFS= read -r cls; do
        [ -n "$cls" ] && FOUND_CLASSES+=("$cls")
    done < <(
        find $SMALI_DIRS -name "*.smali" 2>/dev/null | \
        xargs grep -h "Landroid/miui/" 2>/dev/null | \
        grep -oP 'Landroid/miui/[a-zA-Z0-9_$/]+' | \
        grep -v '\$' | \
        sed 's|L||;s|/|.|g' | \
        sort -u | head -50
    )
else
    echo "⚠️  Smali belum ada. Pakai daftar class default HyperOS 3..."
    # Daftar manual class yang BIASANYA dipakai HyperOS Launcher
    FOUND_CLASSES=(
        "com.miui.home.launcher.LauncherModel"
        "com.miui.home.launcher.LauncherSettings"
        "com.miui.home.launcher.LauncherFiles"
        "com.miui.home.launcher.Utilities"
        "com.miui.home.launcher.DeviceProfile"
        "com.miui.home.recents.RecentsActivity"
        "com.miui.common.persistence.MiuiSettings"
        "com.miui.common.EntityHeaderController"
        "android.miui.AppOpsUtils"
        "android.miui.ActivityTaskHelper"
        "com.miui.blur.BlurController"
        "com.miui.anim.AnimUtils"
    )
fi

# --- Generate stubs ---
echo ""
echo "🏗️  Generating stubs..."
COUNT=0
for cls in "${FOUND_CLASSES[@]}"; do
    make_stub_class "$cls"
    COUNT=$((COUNT + 1))
done

echo ""
echo "======================================================"
echo " ✅ Generated $COUNT stub classes"
echo " 📁 Output: framework-stubs/src/main/java/"
echo ""
echo " Langkah selanjutnya:"
echo "   1. Copy framework-stubs ke source AOSP:"
echo "      cp -r framework-stubs/src/main/java/* \\"
echo "         /path/to/aosp/frameworks/base/core/java/"
echo "   2. Tambahkan ke Android.bp AOSP"
echo "   3. Build dan analisis logcat"
echo "   4. Jalankan: ./tools/analyze-logcat.sh <logcat-file>"
echo "======================================================"
