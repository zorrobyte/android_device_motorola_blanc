# android_device_motorola_blanc

LineageOS 23.2 (Android 16) device tree for the **Motorola Razr Fold 2026** (`blanc`).

> **STATUS: BOOTS AND IS USABLE.** First successful boot 2026-07-06, on the first flash
> attempt, SELinux **enforcing**. Display/touch/UI, Wi-Fi, RIL, battery, sensors, rear
> camera, inner selfie camera all work. See [Known issues](#known-issues).

This is (as far as LineageOS repos show) the **first SM8845/canoe device bring-up**.

## Strategy (milestone 1): Lineage system on stock vendor

Only `system`, `system_ext`, and `product` are replaced. **Kernel, vendor, vendor_dlkm,
odm, boot, init_boot, vendor_boot, dtbo all stay stock**, so the entire Qualcomm/Moto HAL
stack (and the stock-kernel↔stock-modules pairing) is untouched. AVB is disabled via a
flag-patched factory vbmeta. Consequences:

- No custom kernel yet (that's a later phase — see
  [razr-fold-2026-kernel-build](https://github.com/zorrobyte/razr-fold-2026-kernel-build),
  which already produces a stock-vermagic-matching kernel + vendor_dlkm).
- The stock kernel Image (extracted from factory boot.img) is committed at
  `prebuilt/kernel` purely so `check_vintf` validates against what really runs.
- Rollback = reflash three stock images from the unpacked factory super.

## Device

| | |
|---|---|
| Codename | `blanc` (product `blanc_gu`, SKU XT2651-2) |
| SoC | Qualcomm SM8845 (`canoe`), 4 KB pages |
| Android | 16 (SDK 36), board API 202504, stock build `W3WBS36.36-48-5-1` |
| Displays | Inner 2232×2484 @ up to 120 Hz; cover 1080×2520 @ up to 165 Hz; both with camera cutouts |
| Partitions | A/B, dynamic super 28.8 GB (erofs), dedicated recovery |
| Device states | 0=CLOSED 1=TENT 2=STAND 3=LAPTOP 4=OPENED 5=REAR_DISPLAY 6=CONCURRENT_INNER 7=REAR_DISPLAY_OUTER 8=HALF_OPENED_INNER |

## Reproduce the build

```bash
# 1. Sync LineageOS 23.2 (~170 GB source + ~100 GB out/)
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs
mkdir -p .repo/local_manifests
cp <this repo>/local_manifests/blanc.xml .repo/local_manifests/
repo sync -c -j16 --force-sync --no-clone-bundle --no-tags

# 2. Build (needs ~32 GB RAM; first build ~1 h on 32 cores)
source build/envsetup.sh
breakfast blanc userdebug
m systemimage productimage systemextimage
```

## Flash (milestone-1 recipe)

Everything from `out/target/product/blanc/` plus factory `vbmeta.img`/`vbmeta_system.img`
from the stock firmware (`BLANC_G_W3WBS36.36_48_5_1_..._cid50_CFC.xml` RSA package).

```bash
# bootloader must be unlocked; THIS WIPES DATA (stock encryption keys won't survive)
adb reboot bootloader

# fastboot 37.0.0 chokes on Moto's vbmeta with --disable-verity ("Failed to find
# AVB_MAGIC") even though the image is valid. Patch the flags byte directly instead:
python3 scripts/patch-vbmeta.py vbmeta.img vbmeta-disabled.img   # sets flags=3
fastboot flash vbmeta vbmeta-disabled.img
fastboot --disable-verity --disable-verification flash vbmeta_system vbmeta_system.img

fastboot reboot fastboot          # userspace fastboot for dynamic partitions
fastboot flash system system.img
fastboot flash system_ext system_ext.img
fastboot flash product product.img
fastboot -w                       # mandatory data wipe
fastboot reboot
```

Recovery from a bad flash: reflash the three stock images (extract from factory super:
`simg2img super.img_sparsechunk.* super.raw && lpunpack -p system_a,system_ext_a,product_a super.raw`).

## Known issues

| Issue | Status |
|---|---|
| Cover display ran at 60 Hz (supports 165) | **Fixed** via `overlay/` (`config_defaultPeakRefreshRate=165`, `config_defaultRefreshRate=0`). Root cause: cover panel's HWC default mode is 60 Hz; stock relies on Moto's adaptive-refresh service (product partition) which Lineage replaces. |
| Selfie camera fails when folded (cover display) | **Under investigation.** Fold state reaches the CamX HAL correctly (verified `0x4`/`0x0` live); the Moto-customized HAL still rejects logical camera 1 (`CamxResultEInvalidArg` at `camxhal3module.cpp:1473`) while folded. HAL strings show fold-dependent camera classes (`AvailableOnlyInFoldedState`…) — the cover lens appears to be a hidden aux camera ID; stock reaches it via Moto-private vendor tags (`com.lenovo.moto.clientapp`). Next: QTI `exposeAuxCamera` experiment (needs root). Selfie works unfolded. |
| Magisk root lost after data wipe | Magisk is still in stock `init_boot`; reinstall the Magisk app and let it repair the environment. |

## Repo layout

- `BoardConfig.mk`, `device.mk`, `lineage_blanc.mk`, `AndroidProducts.mk` — build config (partition sizes read from a live device)
- `overlay/frameworks/base/…/config.xml` — refresh-rate defaults + foldable device-state arrays
- `prebuilt/kernel` — stock kernel Image (for check_vintf; see Strategy)
- `rootdir/etc/fstab.qcom` — stock fstab
- `local_manifests/blanc.xml` — drop into `.repo/local_manifests/` to reproduce
- `scripts/patch-vbmeta.py` — vbmeta flags patcher (fastboot AVB_MAGIC workaround)
- `recon/` — raw captures from the stock device (fstab, partitions, VINTF fragment list)
- `proprietary-files.txt` — TODO (blob extraction is the next phase; stock vendor is currently kept whole)

## Bring-up checklist

- [x] Partition map + sizes from device
- [x] From-source kernel matching stock vermagic (kernel-build repo)
- [x] repo sync lineage-23.2 + device tree to `breakfast blanc`
- [x] First build (1:08:41) and **first boot — SELinux enforcing**
- [x] Wi-Fi, RIL, rear camera, inner selfie, sensors, battery
- [x] Cover display 165 Hz (overlay)
- [ ] Cover-display selfie (hidden aux camera — in progress)
- [ ] Fold/hinge transitions, dual-display handoff audit
- [ ] Fingerprint, NFC, GPS, audio/calls/VoLTE, stylus, wireless charging
- [ ] Blob extraction → self-contained vendor (drop stock-vendor dependency)
- [ ] From-source kernel + matched vendor_dlkm (Lindroid patches optional)
- [ ] sepolicy tightening, signed builds, OTA
