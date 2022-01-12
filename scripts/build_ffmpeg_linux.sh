#!/bin/bash -e
OUT_DIR=out/linux
OPTIONS="--disable-all --disable-everything --disable-debug --disable-autodetect --enable-avcodec --enable-decoder=h264 --enable-x86asm"

build_arch() {
  ./configure --arch=$ARCH --enable-x86asm $OPTIONS \
    --prefix=$OUT_DIR
  make -j12
  make install
  make clean
}

rm -rf $OUT_DIR

# build x86_64
ARCH="x86_64"
build_arch
