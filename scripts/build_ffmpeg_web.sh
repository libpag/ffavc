#!/bin/bash -e

OUT_DIR=out/web
OPTIONS="--disable-all --disable-everything --disable-debug --disable-autodetect --enable-small --enable-avcodec --enable-decoder=h264 --disable-pthreads"

rm -rf $OUT_DIR

emconfigure ./configure --cc=emcc --cxx=em++ --ar=emar --ranlib=emranlib --enable-cross-compile --target-os=none --arch=x86_32 --cpu=generic --disable-asm $OPTIONS --prefix=$OUT_DIR/wasm
make -j12
make install
make clean
