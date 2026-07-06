#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/motorola/blanc

# Architecture (64-bit only: stock ro.zygote = zygote64)
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a-dotprod
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic

# Platform
TARGET_BOARD_PLATFORM := canoe
TARGET_BOOTLOADER_BOARD_NAME := blanc
TARGET_NO_BOOTLOADER := true

# Kernel
# From-source Moto GKI — see https://github.com/zorrobyte/razr-fold-2026-kernel-build
# Stock banner: 6.12.38-android16-5-g1d46253471dd-ab15048002-4k (boot.img is v4, kernel-only)
# TODO: wire as inline TARGET_KERNEL_SOURCE := kernel/motorola/sm8845 once the Moto
# kernel-common tree (tag MMI-W3WB36.36-48-5) is imported; until then use prebuilts
# from the kernel-build harness. NEVER pair this kernel with factory vendor_dlkm.
BOARD_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_INIT_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_INIT_ARGS += --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)
BOARD_RAMDISK_USE_LZ4 := true
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_IMAGE_NAME := Image
BOARD_USES_GENERIC_KERNEL_IMAGE := true
# Milestone 1 (system-only build, stock vendor+boot kept on device): use the
# stock kernel Image (extracted from factory boot.img W3WBS36.36-48-5-1) so
# check_vintf has a kernel to validate. Replaced by the from-source kernel
# (kernel-build harness) when we move past the stock-vendor phase.
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel

# Partitions — sizes read from device (recon/partition-sizes.txt)
BOARD_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_DTBOIMG_PARTITION_SIZE := 75497472
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 134217728
BOARD_FLASH_BLOCK_SIZE := 262144 # (BOARD_KERNEL_PAGESIZE * 64)

BOARD_SUPER_PARTITION_SIZE := 28789702656
BOARD_SUPER_PARTITION_GROUPS := motorola_dynamic_partitions
BOARD_MOTOROLA_DYNAMIC_PARTITIONS_PARTITION_LIST := odm product system system_dlkm system_ext vendor vendor_dlkm
BOARD_MOTOROLA_DYNAMIC_PARTITIONS_SIZE := 28785508352 # BOARD_SUPER_PARTITION_SIZE - 4 MiB

# File systems (stock is erofs everywhere; userdata f2fs)
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
TARGET_USERIMAGES_USE_F2FS := true

TARGET_COPY_OUT_ODM := odm
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm

# A/B (dedicated recovery partition exists — not recovery-as-boot)
AB_OTA_UPDATER := true
# TODO: confirm Virtual A/B (likely on an A16-launch device) and add
# $(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk) in device.mk
AB_OTA_PARTITIONS += \
    boot \
    init_boot \
    dtbo \
    odm \
    product \
    system \
    system_dlkm \
    system_ext \
    vbmeta \
    vbmeta_system \
    vendor \
    vendor_boot \
    vendor_dlkm

# AVB (stock ro.boot.avb_version = 1.3; dev flashing uses --disable-verity/--disable-verification)
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_AVB_VBMETA_SYSTEM := system system_ext product
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 1

# Platform security patch level shipped by stock build we target
# TODO: set BOOT_SECURITY_PATCH / VENDOR_SECURITY_PATCH from stock props

# VINTF
# TODO: DEVICE_MANIFEST_FILE / DEVICE_MATRIX_FILE — derive from recon/vintf-fragments.txt
# and the stock /vendor/etc/vintf/manifest/ fragments

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.qcom
TARGET_USERIMAGES_USE_EXT4 := true

# SELinux
# TODO: sepolicy dirs (start from qcom sepolicy_vndr + device-specific)

# Metadata
BOARD_USES_METADATA_PARTITION := true

# Verified boot bypass for bring-up: we flash with fastboot --disable-verity
# --disable-verification and a matched vendor_dlkm (see README kernel rules).
