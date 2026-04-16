#!/bin/sh


BUILDROOT_VERSION=2026.02

ROOT_DIR="$(pwd)"
BUILDROOT_DIR="$ROOT_DIR/buildroot-$BUILDROOT_VERSION"

patch_buildroot() {
    cp buildroot.config "$BUILDROOT_DIR/configs/stm32f429_disco_xip_defconfig"
    cp linux.config "$BUILDROOT_DIR/board/stmicroelectronics/stm32f429-disco"
    cp linux.patch "$BUILDROOT_DIR/board/stmicroelectronics/stm32f429-disco/patches/linux"
    mkdir -p "$BUILDROOT_DIR/board/stmicroelectronics/stm32f429-disco/patches/uclibc"
    cp flat-binary-xip.patch "$BUILDROOT_DIR/board/stmicroelectronics/stm32f429-disco/patches/uclibc"
    cd "$BUILDROOT_DIR" && patch -p1 < "$ROOT_DIR/buildroot.patch"
    cd "$ROOT_DIR"
}

fetch_sources() {
    if [ ! -d "$BUILDROOT_DIR" ]; then
        wget https://buildroot.org/downloads/buildroot-$BUILDROOT_VERSION.tar.xz
        tar xvf buildroot-$BUILDROOT_VERSION.tar.xz
        patch_buildroot
    fi
}

build() {
    cd $BUILDROOT_DIR
    make stm32f429_disco_xip_defconfig
    make -j`nproc`
    cd $ROOT_DIR
}

fetch_sources
build
