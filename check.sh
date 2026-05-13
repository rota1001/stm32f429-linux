#!/bin/sh

FILES="
buildroot-2026.02/output/images/rootfs.romfs
buildroot-2026.02/output/images/xipImage
rootfs/init
rootfs/lib/libc.so
rootfs/usr/lib/libts.so.0
rootfs/usr/lib/libevdev.so
rootfs/usr/lib/libdrm.so.2
cellphone/build/bin/lvglsim
"

for FILE in $FILES; do
  if [ ! -f "$FILE" ]; then
    echo "❌ $FILE is missing!"
    exit 1
  fi
done

ls -lh rootfs/lib
ls -lh rootfs/usr/lib
readelf -d cellphone/build/bin/lvglsim | grep "NEEDED"
