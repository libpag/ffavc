#!/bin/bash -e
MACOSX_DEPLOYMENT_TARGET=10.13
OUT_DIR=out/mac
OPTIONS="--disable-all --disable-everything --disable-debug --disable-autodetect --enable-avcodec --enable-decoder=h264"

build_arch() {
  ./configure --target-os=darwin --arch=$ARCH --cc="$CC" $OPTIONS $EXTRA_OPTIONS\
    --extra-cflags="-w -fvisibility=hidden $CFLAGS -arch $ARCH" --extra-ldflags="$CFLAGS -arch $ARCH" \
    --prefix=$OUT_DIR/$ARCH
  make -j12
  make install
  make clean
}

rm -rf $OUT_DIR

# build x86_64
EXTRA_OPTIONS=""
CC="xcrun -sdk macosx clang"
CFLAGS="-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
ARCH="x86_64"
build_arch

# build arm64
CPU=`sysctl -n machdep.cpu.brand_string`
if [[ ${CPU} == *Intel* ]]; then
  EXTRA_OPTIONS="--enable-cross-compile"
fi
CFLAGS="-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET -fembed-bitcode"
ARCH="arm64"
build_arch

mkdir -p $OUT_DIR/include
cp -r $OUT_DIR/x86_64/include/. $OUT_DIR/include