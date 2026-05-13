BUILDROOT_VERSION := 2026.02
ROOT_DIR := $(CURDIR)
BUILDROOT_DIR := $(ROOT_DIR)/buildroot-$(BUILDROOT_VERSION)
BUILDROOT_TAR := buildroot-$(BUILDROOT_VERSION).tar.xz

all: fetch defconfig build

fetch:
	chmod +x fetch.sh
	./fetch.sh

defconfig:
	make -C $(BUILDROOT_DIR) stm32f429_disco_xip_defconfig

cellphone:
	cellphone/cellphone-build.sh

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

build:
	make -C $(BUILDROOT_DIR) -j`nproc`
	make initromfs

linux-rebuild:
	make -C $(BUILDROOT_DIR) linux-rebuild -j`nproc`

linux-menuconfig:
	make -C $(BUILDROOT_DIR) linux-menuconfig

flash:
	$(BUILDROOT_DIR)/board/stmicroelectronics/stm32f429-disco/flash.sh $(BUILDROOT_DIR)/output stm32f429discovery

.PHONY: fetch defconfig build linux-rebuild flash cellphone
