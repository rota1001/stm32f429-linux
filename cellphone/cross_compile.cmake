# Usage:
# cmake -DCMAKE_TOOLCHAIN_FILE=./user_cross_compile_setup.cmake -B build -S .
# make  -C build -j

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(EXTRA_CFLAGS "-O2 -mcpu=cortex-m4 -mthumb -mfdpic --sysroot=${CMAKE_CURRENT_LIST_DIR}/../buildroot-2026.02/output/host/arm-buildroot-uclinuxfdpiceabi/sysroot")
set(CMAKE_C_FLAGS_INIT "${EXTRA_CFLAGS}")

set(tools ${CMAKE_CURRENT_LIST_DIR}/../buildroot-2026.02/output/host)
set(CMAKE_C_COMPILER ${tools}/bin/arm-linux-gcc)
set(CMAKE_AR     "${tools}/bin/arm-linux-ar" CACHE FILEPATH "Archiver")
set(CMAKE_RANLIB "${tools}/bin/arm-linux-ranlib" CACHE FILEPATH "Ranlib")
set(CMAKE_LINKER "${tools}/bin/arm-linux-ld" CACHE FILEPATH "Linker")
set(PKG_CONFIG_EXECUTABLE "${tools}/bin/pkg-config" CACHE FILEPATH "pkg-config wrapper")

set(CMAKE_SYSROOT ${CMAKE_CURRENT_LIST_DIR}/../buildroot-2026.02/output/staging)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# If necessary, set STAGING_DIR
# if not work, please try(in shell command): export STAGING_DIR=/home/ubuntu/Your_SDK/out/xxx/openwrt/staging_dir/target
#set(ENV{STAGING_DIR} "/home/ubuntu/Your_SDK/out/xxx/openwrt/staging_dir/target")
