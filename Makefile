BUILDROOT_VERSION := 2026.02
ROOT_DIR := $(CURDIR)
BUILDROOT_DIR := $(ROOT_DIR)/buildroot-$(BUILDROOT_VERSION)
BUILDROOT_TAR := buildroot-$(BUILDROOT_VERSION).tar.xz
ASSETS_SRC := cellphone/lv_port_linux/lvgl/demos/cellphone/assets/photos

all: fetch defconfig build rootfs-ext2 doom

fetch:
	chmod +x fetch.sh
	./fetch.sh

defconfig:
	make -C $(BUILDROOT_DIR) stm32f429_disco_xip_defconfig

cellphone:
	cellphone/cellphone-build.sh

# Build from the current cellphone/lv_port_linux/ tree as-is (no clone/patches).
cellphone-rebuild:
	cellphone/cellphone-build.sh rebuild

# --- DOOM (doomgeneric) DRM build ---
# Build logic + source set live in doomgeneric/doom-build.sh (mirrors
# cellphone-build.sh). doom1.wad is the shareware IWAD shipped in the source
# (doomgeneric/doomgeneric/doom1.wad); rootfs-ext2 just copies it.
doom:
	doomgeneric/doom-build.sh

# Force a recompile from the current doomgeneric/ source.
doom-rebuild:
	doomgeneric/doom-build.sh rebuild

initromfs: cellphone
	make -C init
	rm -rf rootfs
	mkdir rootfs
	mkdir -p rootfs/bin
	mkdir -p rootfs/dev
	mkdir -p rootfs/lib
	mkdir -p rootfs/proc
	mkdir -p rootfs/root
	mkdir -p rootfs/usr/lib/ts
	mkdir -p rootfs/usr/lib
	mv init/init rootfs
	cp -a -d $(BUILDROOT_DIR)/output/target/lib/libc.so rootfs/lib
	cp -a -d $(BUILDROOT_DIR)/output/target/lib/ld-musl-arm.so.1 rootfs/lib
	cp -d cellphone/build/lib/libts.so.* rootfs/usr/lib
	cp -a $(BUILDROOT_DIR)/output/target/usr/lib/*libdrm* rootfs/usr/lib
	cp -a $(BUILDROOT_DIR)/output/target/usr/lib/*libevdev* rootfs/usr/lib
	$(BUILDROOT_DIR)/output/host/bin/arm-linux-strip rootfs/usr/lib/lib*
	$(BUILDROOT_DIR)/output/host/bin/arm-linux-strip rootfs/lib/*
	$(BUILDROOT_DIR)/output/host/bin/genromfs -d rootfs -f $(BUILDROOT_DIR)/output/images/rootfs.romfs

rootfs-ext2:
	rm -rf rootfs-ext2
	mkdir rootfs-ext2
	mkdir -p rootfs-ext2/etc
	mkdir -p rootfs-ext2/bin
	mkdir -p rootfs-ext2/assets/photos
	cp cellphone/build/bin/lvglsim rootfs-ext2
	cp cellphone/build/bin/lvglsim0001 rootfs-ext2
	cp cellphone/build/bin/lvglsim0002 rootfs-ext2
	cp cellphone/build/bin/lvglsim0003 rootfs-ext2
	cp cellphone/build/bin/lvglsim0004 rootfs-ext2
	cp cellphone/build/bin/doomdrm rootfs-ext2           # Phase-B DOOM on DRM display (double-buffered)
	cp cellphone/build/bin/doomdrm-single rootfs-ext2    # single-buffer build for A/B comparison
	cp doomgeneric/doomgeneric/doom1.wad rootfs-ext2     # DOOM shareware IWAD
	cp cellphone/build/bin/memchild rootfs-ext2          # vfork 2-process RAM-cost experiment child
	cp $(BUILDROOT_DIR)/output/build/busybox-1.37.0/busybox rootfs-ext2/bin
	$(BUILDROOT_DIR)/output/host/bin/arm-linux-strip rootfs-ext2/bin/busybox
	ln -s busybox rootfs-ext2/bin/sh
	cp cellphone/ts.conf rootfs-ext2/etc
	cp cellphone/pointercal rootfs-ext2/etc
	cp -a $(ASSETS_SRC)/thumbs rootfs-ext2/assets/photos/
	cp -a $(ASSETS_SRC)/view rootfs-ext2/assets/photos/
	mke2fs -t ext2 -d rootfs-ext2/ rootfs-ext2.img 32M -F

build:
	make -C $(BUILDROOT_DIR) -j`nproc`
	make initromfs

linux-rebuild:
	make -C $(BUILDROOT_DIR) linux-rebuild -j`nproc`

linux-menuconfig:
	make -C $(BUILDROOT_DIR) linux-menuconfig

flash:
	$(BUILDROOT_DIR)/board/stmicroelectronics/stm32f429-disco/flash.sh $(BUILDROOT_DIR)/output stm32f429discovery

.PHONY: fetch defconfig build linux-rebuild flash cellphone cellphone-rebuild doom doom-rebuild rootfs-ext2
