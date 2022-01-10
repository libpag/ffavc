#!/bin/bash -e
IPHONEOS_DEPLOYMENT_TARGET=9.0
OUT_DIR=out/ios
OPTIONS="--disable-all --disable-everything --disable-debug --disable-autodetect --enable-small \
        --enable-avcodec --enable-decoder=h264"

build_arch() {
  ./configure --target-os=darwin --enable-cross-compile --arch=$ARCH --cc="$CC" $OPTIONS \
    --extra-cflags="-w -fvisibility=hidden $CFLAGS -arch $ARCH" --extra-ldflags="$CFLAGS -arch $ARCH" \
    --prefix=$OUT_DIR/$ARCH
  make -j12
  make install
  make clean
}

rm -rf $OUT_DIR

# build x86_64
CC="xcrun -sdk iphonesimulator clang"
CFLAGS="-mios-simulator-version-min=${IPHONEOS_DEPLOYMENT_TARGET}"
ARCH="x86_64"
build_arch

# build arm64
CC="xcrun -sdk iphoneos clang"
CFLAGS="-mios-version-min=${IPHONEOS_DEPLOYMENT_TARGET} -fembed-bitcode"
ARCH="arm64"
build_arch

# build armv7
ARCH="armv7"
build_arch

# merge to a fat library
mkdir -p $OUT_DIR/lib
lipo -create $OUT_DIR/arm64/lib/libavcodec.a $OUT_DIR/armv7/lib/libavcodec.a $OUT_DIR/x86_64/lib/libavcodec.a -o $OUT_DIR/lib/libavcodec.a
lipo -create $OUT_DIR/arm64/lib/libavutil.a $OUT_DIR/armv7/lib/libavutil.a $OUT_DIR/x86_64/lib/libavutil.a -o $OUT_DIR/lib/libavutil.a
mkdir -p $OUT_DIR/include
cp -r $OUT_DIR/arm64/include/. $OUT_DIR/include
rm -rf $OUT_DIR/arm64
rm -rf $OUT_DIR/armv7
rm -rf $OUT_DIR/x86_64
