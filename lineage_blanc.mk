#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from blanc device
$(call inherit-product, device/motorola/blanc/device.mk)

PRODUCT_NAME := lineage_blanc
PRODUCT_DEVICE := blanc
PRODUCT_BRAND := motorola
PRODUCT_MODEL := motorola razr fold 2026
PRODUCT_MANUFACTURER := motorola

PRODUCT_GMS_CLIENTID_BASE := android-motorola

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="blanc_gu-user 16 W3WBS36.36-48-5-1 1c4b8-a3faa release-keys" \
    BuildFingerprint=motorola/blanc_gu/blanc:16/W3WBS36.36-48-5-1/1c4b8-a3faa:user/release-keys \
    DeviceProduct=blanc_gu
