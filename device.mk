#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# API levels (stock: SDK 36, board API 202504, launched on Android 16)
PRODUCT_SHIPPING_API_LEVEL := 36

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Boot control / A/B
PRODUCT_PACKAGES += \
    android.hardware.boot-service.default_recovery

# TODO: confirm Virtual A/B on stock, then:
# $(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# Display density (stock ro.sf.lcd_density = 420)
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := 420dpi
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.sf.lcd_density=420

# Fastbootd
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.1-impl-mock \
    fastbootd

# Ramdisk fstab for first-stage mount
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.qcom:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.qcom \
    $(LOCAL_PATH)/rootdir/etc/fstab.qcom:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.qcom

# Overlays
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# Soong namespace
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# TODO (bring-up order):
#  - HAL packages (graphics/gralloc/hwcomposer, audio, etc.) — from stock vintf fragments
#  - init scripts (init.blanc.rc, ueventd) — extract from stock vendor
#  - kernel modules lists (modules.load / vendor_ramdisk) — from stock vendor_boot + vendor_dlkm
#  - foldable config (device_state_configuration.xml, display settings)

# Lindroid (LXC + EVDI): container runtime, LindroidUI, perspectived, sepolicy
$(call inherit-product, vendor/lindroid/lindroid.mk)

# Proprietary vendor blobs
$(call inherit-product-if-exists, vendor/motorola/blanc/blanc-vendor.mk)
