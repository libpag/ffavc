#!/bin/bash -e
OUT_DIR=out/android
OPTIONS="--disable-all --disable-everything --disable-debug --disable-autodetect --enable-small \
        --enable-avcodec --enable-decoder=h264"

find_ndk() {
  if [ -f "$NDK_HOME/ndk-build" ]; then
    return
  fi
  ANDROID_HOME=$HOME/Library/Android/sdk
  if [ -f "$ANDROID_HOME/ndk-bundle/ndk-build" ]; then
    NDK_HOME=$ANDROID_HOME/ndk-bundle
    return
  fi

  if [ -d "$ANDROID_HOME/ndk" ]; then
    for file in $ANDROID_HOME/ndk/*; do
      if [ -f "$file/ndk-build" ]; then
        NDK_HOME=$file
        return
      fi
    done
  fi
}

build_arch() {
  ./configure --target-os=android --enable-cross-compile --cc=$CC --arch=$ARCH --cpu=${CPU} $OPTIONS \
    --cross-prefix=${CROSS_PREFIX} --sysroot=${SYSROOT} --extra-cflags="-w" --prefix=$OUT_DIR/$ARCH
  make -j12
  make install
  make clean
}

find_ndk
if ! [ -d "$NDK_HOME" ]; then
  echo "Could not find the NDK_HOME!"
  exit 1
fi
echo "NDK_HOME: $NDK_HOME"
TOOLCHAIN=$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64
SYSROOT=$TOOLCHAIN/sysroot

rm -rf $OUT_DIR

# build arm64
ARCH="arm64"
CPU="armv8-a"
CROSS_PREFIX=$TOOLCHAIN/bin/aarch64-linux-android-
CC=$TOOLCHAIN/bin/aarch64-linux-android21-clang
build_arch

# build armv7
ARCH="arm"
CPU="armv7-a"
CROSS_PREFIX=$TOOLCHAIN/bin/arm-linux-androideabi-
CC=$TOOLCHAIN/bin/armv7a-linux-androideabi21-clang
build_arch
