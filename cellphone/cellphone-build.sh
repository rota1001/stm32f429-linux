#!/bin/sh

BASE_DIR=$(pwd)/cellphone
cd $BASE_DIR

build_tslib() {
    if [ -f build/lib/libts.so.0 ]; then
        echo "tslib was built"
        return
    fi
    TMP=$PATH
    export PATH=$BASE_DIR/../buildroot-2026.02/output/host/bin:$PATH
    if [ -d tslib ]; then rm -rf tslib; fi
    git clone https://github.com/libts/tslib.git
    cd tslib

    ./autogen.sh
    ./configure \
      --host=arm-linux \
      --prefix=/usr \
      --sysconfdir=/etc \
      --enable-static \
      --disable-debug \
      --enable-input=static \
      --enable-linear=static \
      --enable-pthres=static \
      --enable-dejitter=static \
      CFLAGS="-Os -fPIC"
    make -j`nproc`
    cd ..
    mkdir -p build/lib/ts
    mkdir -p build/bin
    mkdir -p build/include
    cp -a tslib/plugins/.libs/*.so build/lib/ts
    cp -a tslib/plugins/.libs/*.a build/lib/ts
    cp -a tslib/src/.libs/libts.so.* build/lib
    cp -a tslib/src/.libs/libts.a build/lib
    cp -a tslib/tests/.libs/* build/bin
    cp tslib/src/tslib.h build/include
    cd $BASE_DIR
    export PATH=$TMP
}

# Full, reproducible build: the source of truth is "fresh clone + patches".
# ALWAYS wipes lv_port_linux/ and reconstructs it, so any local edits to that
# tree are discarded -- put lasting changes in the patches. Use `rebuild` to
# build from the working tree as-is instead.
build_cellphone() {
    echo "cellphone: full build (clone + patches) -- discards local lv_port_linux/ edits"
    if [ -d lv_port_linux ]; then rm -rf lv_port_linux; fi
    git clone https://github.com/rota1001/lv_port_linux.git
    cd lv_port_linux
    git checkout cellphone
    git submodule update --init --recursive
    rm -f cross_compile.cmake
    patch -p1 < ../0001-Enable-dynamic-linked-tslib.patch
    # Cellphone photo-viewer optimizations (decode-to-RAM, thumb cache, RGB565, anims off)
    patch -p1 < ../0002-cellphone-photo-opt-port.patch
    patch -p1 -d lvgl < ../0003-cellphone-photo-opt-lvgl.patch
    # Cellphone home-screen icon cache (per-page opaque RGB565 snapshot + scroll-swap),
    # flat-wallpaper switch, and per-frame perf instrumentation (LV_DEBUG)
    patch -p1 < ../0004-cellphone-home-cache-port.patch
    patch -p1 -d lvgl < ../0005-cellphone-home-cache-lvgl.patch
    # Lock-screen DMA2D-friendly banded vertical gradient, home scroll-settle gate,
    # tile fill optimization (lvgl) + LV_MEM_SIZE 1MB->768KB (port). Combined patch
    # applies from the lv_port_linux root (lvgl/ paths + lv_conf.defaults).
    patch -p1 < ../0006-cellphone-lock-banded-grad.patch
    # DOOM app: launch doomdrm via vfork (DRM master handoff + free/rebuild the
    # display buffers so DOOM gets the SDRAM); registers the "Doom" home icon.
    patch -p1 -d lvgl < ../0007-cellphone-doom-app-lvgl.patch
    cmake -B build -DCMAKE_TOOLCHAIN_FILE="$BASE_DIR/cross_compile.cmake"
    cmake --build build -j$(nproc)
    cd $BASE_DIR
    cp lv_port_linux/build/bin/lvglsim build/bin
}

# Incremental build from the CURRENT lv_port_linux/ working tree exactly as it
# is right now -- no clone, no patches. Whatever the code currently says is what
# gets built. Requires a prior full build (so the tree + cmake cache exist).
rebuild_cellphone() {
    if [ ! -d lv_port_linux ]; then
        echo "rebuild: lv_port_linux/ not found -- run a full build first" >&2
        return 1
    fi
    echo "cellphone: rebuild from current working tree (patches ignored)"
    cd lv_port_linux
    if [ ! -d build ]; then
        cmake -B build -DCMAKE_TOOLCHAIN_FILE="$BASE_DIR/cross_compile.cmake"
    fi
    cmake --build build -j$(nproc)
    cd $BASE_DIR
    mkdir -p build/bin
    cp lv_port_linux/build/bin/lvglsim build/bin
}

build_tslib
case "$1" in
    rebuild) rebuild_cellphone ;;
    *)       build_cellphone ;;
esac
