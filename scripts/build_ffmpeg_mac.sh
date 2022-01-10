#!/bin/bash -e
MACOSX_DEPLOYMENT_TARGET=10.13
OUT_DIR=out/mac
OPTIONS="--disable-all --disable-everything --disable-debug --disable-autodetect --enable-avcodec --enable-decoder=h264"

rm -rf $OUT_DIR
./configure $OPTIONS --extra-cflags="-w -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET" --prefix=$OUT_DIR
make -j12
make install
make clean
