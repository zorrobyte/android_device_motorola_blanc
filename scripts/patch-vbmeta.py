#!/usr/bin/env python3
"""Set the AVB flags field (offset 120, big-endian u32) of a vbmeta image to 3
(HASHTREE_DISABLED | VERIFICATION_DISABLED).

Workaround for `fastboot --disable-verity --disable-verification flash vbmeta`
failing with "Failed to find AVB_MAGIC at offset: 0" on Motorola blanc factory
vbmeta images despite a valid AVB0 header (fastboot 37.0.0). The flags live in
the authenticated header, but with an unlocked bootloader the top-level vbmeta
is not signature-checked and the flag bits are honored.

Usage: patch-vbmeta.py <vbmeta.img> <output.img>
"""
import sys

FLAGS_OFFSET = 120
FLAGS = 3  # bit0 HASHTREE_DISABLED, bit1 VERIFICATION_DISABLED

def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    src, dst = sys.argv[1], sys.argv[2]
    with open(src, "rb") as f:
        data = bytearray(f.read())
    if data[:4] != b"AVB0":
        sys.exit(f"{src}: no AVB0 magic at offset 0 — not a vbmeta image")
    old = int.from_bytes(data[FLAGS_OFFSET:FLAGS_OFFSET + 4], "big")
    data[FLAGS_OFFSET:FLAGS_OFFSET + 4] = FLAGS.to_bytes(4, "big")
    with open(dst, "wb") as f:
        f.write(data)
    print(f"{dst}: flags {old:#x} -> {FLAGS:#x}")

if __name__ == "__main__":
    main()
