# =============================================================
# device.mk additions — Poco F4 (munch)
# Port: HyperOS 3 Launcher → AOSP Android 16
#
# Tambahkan isi file ini ke device/xiaomi/munch/device.mk
# =============================================================

# ------------------------------------------------------------------
# [PORT] HyperOS 3 MiuiHome Launcher
# ------------------------------------------------------------------

# Launcher APK sebagai priv-app (privileged system app)
PRODUCT_PACKAGES += \
    MiuiHome

# Framework stubs untuk HyperOS API
PRODUCT_PACKAGES += \
    miui-framework-stubs

# Disable AOSP default launcher (agar tidak bentrok)
PRODUCT_PACKAGES += \
    -Launcher3QuickStep

# Pastikan MiuiHome sebagai HOME app default
PRODUCT_PROPERTY_OVERRIDES += \
    ro.home.launcher=com.miui.home/.launcher.Launcher

# Izin priv-app untuk MiuiHome
# (tambahkan juga file privapp-permissions-miuihome.xml)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/permissions/privapp-permissions-miuihome.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-miuihome.xml

# Native libs dari HyperOS
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/lib64/libmiuiblur.so:$(TARGET_COPY_OUT_SYSTEM)/lib64/libmiuiblur.so \
    $(LOCAL_PATH)/prebuilt/lib64/libmigui.so:$(TARGET_COPY_OUT_SYSTEM)/lib64/libmigui.so

# ------------------------------------------------------------------
# Properties untuk kompatibilitas launcher
# ------------------------------------------------------------------
PRODUCT_PROPERTY_OVERRIDES += \
    ro.miui.version=HyperOS3 \
    ro.miui.ui.version.code=16 \
    ro.miui.ui.version.name=V816 \
    persist.sys.miui_optimization=true
