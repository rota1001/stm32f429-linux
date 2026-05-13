BUILDROOT_VERSION=2026.02

ROOT_DIR="$(pwd)"
BUILDROOT_DIR="$ROOT_DIR/buildroot-$BUILDROOT_VERSION"

patch_buildroot() {
    cd "$BUILDROOT_DIR"
    for p in "$ROOT_DIR"/patches/buildroot/*.patch; do
        patch -p1 < "$p"
    done
    cd "$ROOT_DIR"
    cp buildroot.config "$BUILDROOT_DIR/configs/stm32f429_disco_xip_defconfig"
    cp linux.config "$BUILDROOT_DIR/board/stmicroelectronics/stm32f429-disco"
    cp busybox-minimal.config "$BUILDROOT_DIR/package/busybox"
    cp uClibc-ng.config "$BUILDROOT_DIR/package/uclibc"
    cp -a "$ROOT_DIR"/patches/linux/*.patch "$BUILDROOT_DIR/board/stmicroelectronics/stm32f429-disco/patches/linux"
    cp -a "$ROOT_DIR"/patches/musl/*.patch "$BUILDROOT_DIR/package/musl"
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

fetch_sources
patch_buildroot
