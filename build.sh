#!/bin/sh
set -eux

BUILDROOT_VERSION=2026.02

ROOT_DIR="$(pwd)"
BUILDROOT_DIR="$ROOT_DIR/buildroot-$BUILDROOT_VERSION"

patch_buildroot() {
    cp buildroot.config "$BUILDROOT_DIR/configs/stm32f429_disco_xip_defconfig"
    cp linux.config "$BUILDROOT_DIR/board/stmicroelectronics/stm32f429-disco"
    cp busybox-minimal.config "$BUILDROOT_DIR/package/busybox"
    cp uClibc-ng.config "$BUILDROOT_DIR/package/uclibc"
    cd "$BUILDROOT_DIR"
    for p in "$ROOT_DIR"/patches/*.patch; do
        patch -p1 < "$p"
    done
    cd "$ROOT_DIR"
}

fetch_sources() {
    if [ ! -f "buildroot-$BUILDROOT_VERSION.tar.xz" ]; then
        wget https://buildroot.org/downloads/buildroot-$BUILDROOT_VERSION.tar.xz
    fi
    if [ ! -d "$BUILDROOT_DIR" ]; then
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
