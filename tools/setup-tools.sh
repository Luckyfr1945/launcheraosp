#!/bin/bash
# =============================================================
# setup-tools.sh — Install semua tools yang dibutuhkan
# Port: HyperOS 3 Launcher → AOSP Android 16
# Device: Poco F4 (munch)
# =============================================================

set -e
TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$TOOLS_DIR")"

echo "======================================================"
echo " 🔧 Setup Tools - HyperOS Launcher Port (munch/A16)"
echo "======================================================"

# --- 1. Cek OS ---
if ! command -v apt &>/dev/null; then
    echo "❌ Script ini untuk Ubuntu/Debian. Sesuaikan manual untuk distro lain."
    exit 1
fi

# --- 2. Install packages ---
echo ""
echo "[1/5] Install dependencies via apt..."
sudo apt update -q
sudo apt install -y \
    default-jdk \
    adb \
    zipalign \
    apksigner \
    python3 \
    python3-pip \
    wget \
    unzip \
    git \
    aapt

echo "✅ apt packages installed"

# --- 3. Install apktool ---
echo ""
echo "[2/5] Install apktool..."
APKTOOL_VERSION="2.10.0"
if command -v apktool &>/dev/null; then
    echo "  apktool sudah ada: $(apktool --version)"
else
    wget -q "https://github.com/iBotPeaches/Apktool/releases/download/v${APKTOOL_VERSION}/apktool_${APKTOOL_VERSION}.jar" \
        -O "$TOOLS_DIR/apktool.jar"
    echo '#!/bin/bash' > "$TOOLS_DIR/apktool"
    echo "java -jar \"$TOOLS_DIR/apktool.jar\" \"\$@\"" >> "$TOOLS_DIR/apktool"
    chmod +x "$TOOLS_DIR/apktool"
    echo "  ✅ apktool $APKTOOL_VERSION installed di tools/"
fi

# --- 4. Install JADX ---
echo ""
echo "[3/5] Install JADX..."
JADX_VERSION="1.5.0"
if [ -f "$TOOLS_DIR/jadx/bin/jadx" ]; then
    echo "  JADX sudah ada"
else
    wget -q "https://github.com/skylot/jadx/releases/download/v${JADX_VERSION}/jadx-${JADX_VERSION}.zip" \
        -O "$TOOLS_DIR/jadx.zip"
    unzip -q "$TOOLS_DIR/jadx.zip" -d "$TOOLS_DIR/jadx"
    rm "$TOOLS_DIR/jadx.zip"
    echo "  ✅ JADX $JADX_VERSION installed di tools/jadx/"
fi

# --- 5. Install baksmali/smali ---
echo ""
echo "[4/5] Install baksmali & smali..."
SMALI_VERSION="2.5.2"
if [ ! -f "$TOOLS_DIR/baksmali.jar" ]; then
    wget -q "https://github.com/JesusFreke/smali/releases/download/v${SMALI_VERSION}/baksmali-${SMALI_VERSION}.jar" \
        -O "$TOOLS_DIR/baksmali.jar"
    wget -q "https://github.com/JesusFreke/smali/releases/download/v${SMALI_VERSION}/smali-${SMALI_VERSION}.jar" \
        -O "$TOOLS_DIR/smali.jar"
    echo "  ✅ baksmali & smali $SMALI_VERSION installed"
else
    echo "  baksmali/smali sudah ada"
fi

# --- 6. Buat wrapper scripts ---
echo ""
echo "[5/5] Buat wrapper scripts..."

# jadx wrapper
cat > "$TOOLS_DIR/run-jadx" << 'EOF'
#!/bin/bash
TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
"$TOOLS_DIR/jadx/bin/jadx" "$@"
EOF
chmod +x "$TOOLS_DIR/run-jadx"

# baksmali wrapper
cat > "$TOOLS_DIR/run-baksmali" << 'EOF'
#!/bin/bash
TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
java -jar "$TOOLS_DIR/baksmali.jar" "$@"
EOF
chmod +x "$TOOLS_DIR/run-baksmali"

echo ""
echo "======================================================"
echo " ✅ Semua tools siap!"
echo ""
echo " Langkah selanjutnya:"
echo "   1. Taruh MiuiHome.apk di folder apk-extract/"
echo "   2. Jalankan: ./tools/decompile-apk.sh"
echo "   3. Jalankan: ./tools/analyze-deps.sh"
echo "======================================================"
