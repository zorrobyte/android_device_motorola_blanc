# android_device_motorola_blanc

LineageOS 23.2 (Android 16) device tree for the **Motorola Razr Fold 2026** (`blanc`).

> **STATUS: early scaffold — does not build yet.** Values below marked ✅ are read from a live
> stock device (`W3WBS36.36-48-5-1`); items marked TODO are unfinished. First target is a
> booting `lineage_blanc` userdebug build.

## Device

| | |
|---|---|
| Codename | `blanc` (product `blanc_gu`, SKU XT2651-2) |
| SoC | Qualcomm SM8845 (`canoe`), 4 KB pages |
| Android | 16 (SDK 36), board API level 202504 |
| Kernel | `6.12.38-android16-5` GKI, Moto-patched `kernel-common` @ tag `MMI-W3WB36.36-48-5` |
| Partitions | A/B, dynamic super (28.8 GB): system / system_ext / product / vendor / odm / vendor_dlkm / system_dlkm, erofs |
| Boot images | boot v4 (kernel-only, 96 MB), init_boot (Magisk lives here on the dev unit), vendor_boot, dedicated recovery (128 MB) |

## Kernel — READ THIS FIRST

The kernel is built from source via
[`zorrobyte/razr-fold-2026-kernel-build`](https://github.com/zorrobyte/razr-fold-2026-kernel-build)
(tag-pinned Moto OSS manifest; produces an `Image` whose banner matches stock:
`6.12.38-android16-5-g1d46253471dd-ab15048002-4k`).

Hard-won rules from that effort (violating any of these = bootloop):

1. **Never pair a from-source kernel with the factory `vendor_dlkm`** — Moto's `common` is
   ~1,116 commits ahead of AOSP GKI, so module CRCs differ. Always flash the kernel together
   with the `vendor_dlkm.img` from the *same build*, verity/verification disabled.
2. **Never build pristine AOSP GKI `common`** — use Moto's `kernel-common` at the MMI tag.
3. **Keep the factory `dtbo` and `vendor_boot`** — the from-source dtbo (~97 KB) lacks Moto's
   hardware overlays (factory is ~72 MB).

## Repo layout

- `BoardConfig.mk` — board/partition config (sizes read from device)
- `device.mk`, `lineage_blanc.mk`, `AndroidProducts.mk` — product config
- `proprietary-files.txt` — TODO: blob list (extract from stock `W3WBS36.36-48-5-1`)
- `recon/` — raw data captured from the stock device (fstab, partition map/sizes, VINTF fragment list)

## Bring-up checklist

- [x] Partition map + sizes from device
- [x] Stock fstab captured
- [x] From-source kernel proven to match stock vermagic (kernel-build repo)
- [ ] repo sync lineage-23.2 build tree
- [ ] BoardConfig/device.mk complete enough to `breakfast lineage_blanc`
- [ ] `proprietary-files.txt` + `extract-files.py` (blobs from rooted device / stock firmware)
- [ ] Kernel wired in (inline `kernel/motorola/sm8845` or prebuilt + matched vendor_dlkm)
- [ ] sepolicy (boot permissive-equivalent first, then tighten)
- [ ] First boot → then hardware: fold/hinge, displays, GPS, camera, fingerprint, NFC, sensors

## Notes

- LineageOS has **no canoe/sm8845 platform support yet** — closest reference is
  `LineageOS/android_device_oneplus_sm8750-common` (sun). This tree is the first canoe bring-up.
- Dev unit keeps root because Magisk lives in `init_boot`, which we never flash.
- Full stock firmware for rescue: `BLANC_G_W3WBS36.36_48_5_1_..._cid50_CFC.xml` (RSA download).
