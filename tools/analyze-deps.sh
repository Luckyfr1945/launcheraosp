#!/bin/bash
# =============================================================
# analyze-deps.sh — Analisis dependencies Xiaomi yang dipakai
#                   MiuiHome.apk, output daftar class/API yang
#                   perlu di-stub di AOSP
# Port: HyperOS 3 Launcher → AOSP Android 16
# =============================================================

set -e
TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$TOOLS_DIR")"
JADX_OUT="$ROOT_DIR/apk-extract/jadx"
SMALI_DIR="$ROOT_DIR/apk-extract/apktool"
DOCS_DIR="$ROOT_DIR/docs"

echo "======================================================"
echo " 🔍 Analisis Dependencies MiuiHome → AOSP Stubs"
echo "======================================================"

# Cek apakah sudah didecompile
if [ ! -d "$SMALI_DIR" ] && [ ! -d "$JADX_OUT" ]; then
    echo "❌ Belum ada hasil decompile. Jalankan dulu: ./tools/decompile-apk.sh"
    exit 1
fi

OUTPUT="$DOCS_DIR/DEPENDENCIES.md"

{
echo "# 📋 Dependency Analysis — MiuiHome Launcher"
echo ""
echo "> Generated: $(date)"
echo "> Tool: analyze-deps.sh"
echo ""

# --- Scan dari Smali (lebih akurat) ---
if [ -d "$SMALI_DIR/smali" ] || [ -d "$SMALI_DIR/smali_classes2" ]; then
    SMALI_DIRS=$(find "$SMALI_DIR" -name "smali*" -type d 2>/dev/null)
    echo "## 🔴 Class Xiaomi yang Dipanggil Launcher"
    echo ""
    echo "### com.miui.* imports"
    echo '```'
    find $SMALI_DIRS -name "*.smali" 2>/dev/null | \
        xargs grep -h "Lcom/miui/" 2>/dev/null | \
        grep -oP 'Lcom/miui/[a-zA-Z0-9_/]+' | \
        sed 's|L||;s|/|.|g' | sort -u | head -80
    echo '```'
    echo ""

    echo "### android.miui.* imports"
    echo '```'
    find $SMALI_DIRS -name "*.smali" 2>/dev/null | \
        xargs grep -h "Landroid/miui/" 2>/dev/null | \
        grep -oP 'Landroid/miui/[a-zA-Z0-9_/]+' | \
        sed 's|L||;s|/|.|g' | sort -u | head -50
    echo '```'
    echo ""

    echo "### miuix.* imports"
    echo '```'
    find $SMALI_DIRS -name "*.smali" 2>/dev/null | \
        xargs grep -h "Lmiuix/" 2>/dev/null | \
        grep -oP 'Lmiuix/[a-zA-Z0-9_/]+' | \
        sed 's|L||;s|/|.|g' | sort -u | head -50
    echo '```'
    echo ""

    echo "### Service Calls (getService)"
    echo '```'
    find $SMALI_DIRS -name "*.smali" 2>/dev/null | \
        xargs grep -h "getService\|getSystemService" 2>/dev/null | \
        grep -oP '"[a-z_.]+"' | sort -u | head -40
    echo '```'
    echo ""

    echo "### Native Library Loads (System.loadLibrary)"
    echo '```'
    find $SMALI_DIRS -name "*.smali" 2>/dev/null | \
        xargs grep -h "loadLibrary\|loadLibrary" 2>/dev/null | \
        grep -oP '"[a-zA-Z0-9_]+"' | sort -u
    echo '```'
    echo ""
fi

# --- Scan dari JADX output ---
if [ -d "$JADX_OUT/sources" ]; then
    echo "## 🟡 Import dari JADX (Java Source)"
    echo ""
    echo "### Semua import non-standard:"
    echo '```'
    find "$JADX_OUT/sources" -name "*.java" | \
        xargs grep -h "^import " 2>/dev/null | \
        grep -E "miui|xiaomi|MiuiBlur|MiuiAnim" | \
        sort -u | head -100
    echo '```'
    echo ""
fi

echo "## ✅ Action Plan: Stub Priority"
echo ""
echo "| Priority | Package | Action |"
echo "|----------|---------|--------|"
echo "| 🔴 High | com.miui.home | Core stub wajib dibuat |"
echo "| 🔴 High | com.miui.launcher | Core stub wajib dibuat |"
echo "| 🟡 Medium | com.miui.common | Buat stub jika dipanggil |"
echo "| 🟡 Medium | android.miui | Stub minimal |"
echo "| 🟢 Low | miuix.* | UI lib, stub kosong dulu |"
echo ""
echo "---"
echo "Setelah membaca dokumen ini, jalankan: ./tools/generate-stubs.sh"

} > "$OUTPUT"

echo ""
echo "✅ Analisis selesai!"
echo "📄 Output: docs/DEPENDENCIES.md"
echo ""

# Quick preview
echo "--- Preview (com.miui.* classes found) ---"
if [ -d "$SMALI_DIR" ]; then
    SMALI_DIRS=$(find "$SMALI_DIR" -name "smali*" -type d 2>/dev/null)
    find $SMALI_DIRS -name "*.smali" 2>/dev/null | \
        xargs grep -h "Lcom/miui/" 2>/dev/null | \
        grep -oP 'Lcom/miui/[a-zA-Z0-9_/]+' | \
        sed 's|L||;s|/|.|g' | sort -u | head -20
    echo "  (lihat docs/DEPENDENCIES.md untuk daftar lengkap)"
else
    echo "  (jalankan decompile-apk.sh dulu untuk hasil lebih detail)"
fi
