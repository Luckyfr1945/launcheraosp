# Cara Mendapatkan File HyperOS 3 (Android 16) untuk Poco F4 (munch)

## Opsi 1: Download ROM Dump (Paling Mudah)

ROM dump adalah ekstraksi penuh dari ROM HyperOS, sudah dalam bentuk
folder yang bisa langsung diakses. Tidak perlu flash ke HP.

### Situs ROM Dump Terpercaya:
- **XDA Developers**: https://xdaforums.com/f/poco-f4.12585/
  - Cari thread "HyperOS 3 ROM Dump munch"
- **GitHub ROM Dumps**:
  ```
  https://github.com/search?q=munch+hyperos+dump&type=repositories
  ```
- **SourceForge**: Cari "munch hyperos 3 dump"

### Yang Perlu Didownload:
Cari file dengan nama seperti:
```
munch_hyperos3_a16_dump.zip   (~4-8 GB)
```
atau
```
miui_POCO_F4_OS1.0.X.X_*.zip   (official OTA)
```

---

## Opsi 2: Ekstrak dari OTA Resmi Xiaomi

### Langkah:
1. Download OTA/ROM resmi dari: https://xiaomifirmwareupdater.com/miui/munch/
2. Pilih versi HyperOS 3 terbaru (Android 16)
3. Extract ZIP → dapat `payload.bin`
4. Extract `payload.bin` dengan tool:
   ```bash
   # Install payload-dumper-go
   pip3 install payload-dumper-go
   # atau download dari:
   # https://github.com/ssut/payload-dumper-go

   payload-dumper-go payload.bin
   # Output: folder dengan image .img terpisah
   ```
5. Mount image `system_ext.img`:
   ```bash
   sudo mount -o loop,ro system_ext.img /mnt/system_ext
   # Kemudian ambil file yang dibutuhkan
   cp /mnt/system_ext/priv-app/MiuiHome/MiuiHome.apk ./apk-extract/
   cp /mnt/system_ext/framework/*.jar ./  # untuk referensi
   ```

---

## Opsi 3: Dump Langsung dari HP (Jika Sudah Pakai HyperOS)

Jika Poco F4 kamu masih menjalankan HyperOS 3:

```bash
# Pastikan HP sudah di-root atau pakai ADB dengan USB Debugging
adb shell

# Cek lokasi MiuiHome
find /system_ext /system -name "MiuiHome.apk" 2>/dev/null

# Pull file APK
adb pull /system_ext/priv-app/MiuiHome/MiuiHome.apk ./apk-extract/

# Pull framework JARs (untuk referensi)
adb pull /system/framework/miui.jar ./
adb pull /system/framework/miui-services.jar ./
adb pull /system/framework/framework.jar ./

# Pull native libs
adb pull /system/lib64/ ./native-libs/lib64/
```

---

## File yang Harus Dikumpulkan

Setelah dapat file, taruh di folder yang benar:

```
port-launcher/
├── apk-extract/
│   └── MiuiHome.apk          ← WAJIB
├── native-libs/
│   ├── lib64/
│   │   ├── libmiuiblur.so    ← Jika ada
│   │   └── libmigui*.so      ← Jika ada
│   └── lib/
│       └── *.so              ← Versi 32-bit
```

Untuk JARs (hanya untuk referensi decompile, JANGAN copy ke AOSP):
```
port-launcher/
└── docs/
    └── jars/
        ├── miui.jar
        ├── miui-services.jar
        └── framework.jar
```

---

## Setelah File Terkumpul

```bash
cd port-launcher/tools
chmod +x *.sh

# 1. Install tools
./setup-tools.sh

# 2. Decompile APK
./decompile-apk.sh

# 3. Analisis dependencies
./analyze-deps.sh

# 4. Generate stubs
./generate-stubs.sh
```
