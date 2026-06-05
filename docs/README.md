# 🚀 HyperOS 3 Launcher → AOSP Android 16 Porting Project
## Target Device: Poco F4 (munch) | Snapdragon 870
## Basis: AOSP Android 16 ↔ HyperOS 3 (Android 16)

> ✅ Keuntungan: Base Android sama (API 36), jadi framework gap jauh lebih kecil!

---

## 📁 Struktur Folder

```
port-launcher/
├── apk-extract/          # Hasil decompile MiuiHome.apk
│   ├── apktool/         # Output apktool (smali, manifest, res)
│   └── jadx/            # Output jadx (Java source readable)
├── framework-stubs/      # Stub classes buatan kita untuk AOSP
│   └── src/main/java/
│       └── com/miui/    # Package tiruan Xiaomi
├── native-libs/          # File .so dari HyperOS 3
│   ├── lib/             # 32-bit libs
│   └── lib64/           # 64-bit libs
├── device-tree/          # Kode untuk device tree munch
│   └── munch/
├── patches/              # Patch diff untuk source AOSP
│   ├── frameworks-base/ # Patch frameworks/base
│   └── SystemServer/    # Patch SystemServer.java
├── tools/                # Script otomasi
├── logcat-analysis/      # Simpan logcat crash di sini
└── docs/                 # Dokumentasi
    ├── README.md
    ├── DEPENDENCIES.md   # Daftar API yang harus di-stub
    └── PROGRESS.md       # Log progress porting
```

---

## 🗺️ Roadmap Lengkap

### Tahap 1 — Persiapan File
- [ ] Download ROM dump HyperOS 3 Android 16 untuk munch
- [ ] Ekstrak `MiuiHome.apk` dari ROM dump
- [ ] Ekstrak framework JARs (`miui.jar`, `miui-services.jar`, dll)
- [ ] Kumpulkan native `.so` yang relevan

### Tahap 2 — Analisis APK
- [ ] Decompile `MiuiHome.apk` dengan `apktool`
- [ ] Baca `AndroidManifest.xml` → catat semua permission & service
- [ ] Decompile dengan `jadx` → baca import class Xiaomi yang dipakai
- [ ] Jalankan `./tools/analyze-deps.sh` untuk auto-detect dependencies

### Tahap 3 — Buat Framework Stubs
- [ ] Buat stub classes untuk setiap class `com.miui.*` yang dipanggil launcher
- [ ] Tambahkan ke `frameworks/base/` di source AOSP
- [ ] Update `Android.bp` agar stub ikut di-compile

### Tahap 4 — Patch SystemServer
- [ ] Identifikasi service Xiaomi yang dibutuhkan launcher
- [ ] Buat dummy service implementation
- [ ] Inject ke `SystemServer.java`

### Tahap 5 — Integrasi Native Libs
- [ ] Copy `.so` ke `native-libs/`
- [ ] Daftarkan di `device.mk` device tree munch
- [ ] Set SELinux policy jika perlu

### Tahap 6 — Build & Test
- [ ] Build AOSP dengan modifikasi
- [ ] Flash ke Poco F4
- [ ] Ambil logcat jika FC → simpan di `logcat-analysis/`
- [ ] Fix error → ulangi

---

## 📋 File yang Dibutuhkan dari HyperOS 3

### Dari ROM Dump (Path di dalam ROM):

| File | Path di ROM | Prioritas |
|------|-------------|-----------|
| `MiuiHome.apk` | `/system_ext/priv-app/MiuiHome/` | 🔴 WAJIB |
| `framework.jar` | `/system/framework/` | 🔴 WAJIB (ref) |
| `miui.jar` | `/system/framework/` | 🔴 WAJIB (ref) |
| `miui-services.jar` | `/system/framework/` | 🔴 WAJIB (ref) |
| `services.jar` | `/system/framework/` | 🟡 Penting |
| `ext.jar` | `/system/framework/` | 🟡 Penting |
| Native `.so` | `/system/lib64/` | 🟡 Penting |

> ⚠️ JARs hanya untuk referensi decompile di PC, **tidak** dimasukkan ke AOSP langsung!

### Cara Dapat File (ROM Dump):
Lihat: `docs/GET-FILES.md`

---

## 🔧 Setup Tools

```bash
cd port-launcher/tools
./setup-tools.sh
```
