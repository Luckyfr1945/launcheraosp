#!/bin/bash
# =============================================================
# decompile-apk.sh — Decompile MiuiHome.apk dengan apktool + jadx
# Port: HyperOS 3 Launcher → AOSP Android 16
# =============================================================

set -e
TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$TOOLS_DIR")"
APK_SRC="$ROOT_DIR/apk-extract"
APKTOOL="$TOOLS_DIR/apktool"
JADX="$TOOLS_DIR/jadx/bin/jadx"

echo "======================================================"
echo " 📦 Decompile MiuiHome.apk"
echo "======================================================"

# Cek APK ada
APK_FILE=$(find "$APK_SRC" -maxdepth 1 -name "*.apk" | head -1)
if [ -z "$APK_FILE" ]; then
    echo ""
    echo "❌ ERROR: Tidak ada file .apk di folder apk-extract/"
    echo "   Taruh MiuiHome.apk di: $APK_SRC/"
    exit 1
fi

echo "📁 APK ditemukan: $(basename "$APK_FILE")"
echo ""

# --- 1. Decompile dengan apktool ---
echo "[1/2] Decompile dengan apktool (Smali + Resources)..."
APKTOOL_OUT="$APK_SRC/apktool"
rm -rf "$APKTOOL_OUT"

if [ -f "$APKTOOL" ]; then
    "$APKTOOL" d "$APK_FILE" -o "$APKTOOL_OUT" --no-src 2>&1
else
    apktool d "$APK_FILE" -o "$APKTOOL_OUT" --no-src 2>&1
fi

echo "  ✅ Hasil apktool → apk-extract/apktool/"
echo ""

# --- 2. Tampilkan AndroidManifest.xml ---
MANIFEST="$APKTOOL_OUT/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
    echo "========================================"
    echo " 📄 AndroidManifest.xml (ringkasan)"
    echo "========================================"
    echo ""
    echo "→ Package name:"
    grep -oP 'package="[^"]+"' "$MANIFEST" || echo "  (tidak ditemukan)"

    echo ""
    echo "→ Permissions yang diminta:"
    grep -oP 'android:name="[^"]+"' "$MANIFEST" | grep -i "permission" | \
        sort -u | sed 's/android:name="//;s/"//' | head -30

    echo ""
    echo "→ Services yang didaftarkan:"
    grep -A2 '<service' "$MANIFEST" | grep 'android:name' | \
        sed 's/.*android:name="//;s/".*//' | head -20

    echo ""
    echo "→ Activities:"
    grep -A2 '<activity' "$MANIFEST" | grep 'android:name' | \
        sed 's/.*android:name="//;s/".*//' | head -20

    # Simpan ringkasan
    SUMMARY_FILE="$ROOT_DIR/docs/manifest-summary.txt"
    {
        echo "=== AndroidManifest.xml Summary ==="
        echo "APK: $(basename "$APK_FILE")"
        echo "Date: $(date)"
        echo ""
        echo "--- Package ---"
        grep -oP 'package="[^"]+"' "$MANIFEST"
        echo ""
        echo "--- All Permissions ---"
        grep -oP 'android:name="[^"]+"' "$MANIFEST" | grep -i "permission" | sort -u
        echo ""
        echo "--- All Services ---"
        grep -A2 '<service' "$MANIFEST" | grep 'android:name' | sed 's/.*android:name="//;s/"//'
        echo ""
        echo "--- All Activities ---"
        grep -A2 '<activity' "$MANIFEST" | grep 'android:name' | sed 's/.*android:name="//;s/"//'
    } > "$SUMMARY_FILE"
    echo ""
    echo "💾 Ringkasan disimpan di: docs/manifest-summary.txt"
fi

# --- 3. Decompile dengan jadx ---
echo ""
echo "[2/2] Decompile dengan jadx (Java source)..."
JADX_OUT="$APK_SRC/jadx"
rm -rf "$JADX_OUT"

if [ -f "$JADX" ]; then
    "$JADX" -d "$JADX_OUT" "$APK_FILE" --show-bad-code 2>&1 | tail -5
else
    echo "  ⚠️  jadx tidak ditemukan, jalankan setup-tools.sh dulu"
    echo "  Skip jadx decompile..."
fi

echo ""
echo "======================================================"
echo " ✅ Decompile selesai!"
echo ""
echo " Langkah selanjutnya:"
echo "   Jalankan: ./tools/analyze-deps.sh"
echo "======================================================"
