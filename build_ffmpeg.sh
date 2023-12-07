#!/bin/bash -e
cd $(dirname $0)
SOURCE_DIR=$(pwd)/third_party/ffmpeg
OUT_DIR=$(pwd)/vendor/ffmpeg

function make_dir() {
  rm -rf $1
  mkdir -p $1
}

function win_build() {
  cd $SOURCE_DIR
  ../../scripts/build_ffmpeg_win.sh -t $1
  make_dir $OUT_DIR/include
  cp -a $SOURCE_DIR/out/win/$1/include/* $OUT_DIR/include
  make_dir $OUT_DIR/win/$1
  cp -a $SOURCE_DIR/out/win/$1/lib/libavcodec.a $OUT_DIR/win/$1/libavcodec.lib
  cp -a $SOURCE_DIR/out/win/$1/lib/libavutil.a $OUT_DIR/win/$1/libavutil.lib
}

if [[ $(uname) == 'Darwin' ]]; then
  MAC_REQUIRED_TOOLS="cmake yasm"
  for TOOL in ${MAC_REQUIRED_TOOLS[@]}; do
    if [ ! $(which $TOOL) ]; then
      if [ ! $(which brew) ]; then
        echo "Homebrew not found. Trying to install..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" ||
          exit 1
      fi
      echo "$TOOL not found. Trying to install..."
      brew install $TOOL || exit 1
    fi
  done

  cd $SOURCE_DIR
  # build ios
  ../../scripts/build_ffmpeg_ios.sh
  rm -rf $OUT_DIR/ios
  make_dir $OUT_DIR/include
  cp -r $SOURCE_DIR/out/ios/include/. $OUT_DIR/include
  make_dir $OUT_DIR/ios/arm
  cp -r $SOURCE_DIR/out/ios/armv7/lib/*.a $OUT_DIR/ios/arm
  make_dir $OUT_DIR/ios/arm64
  cp -r $SOURCE_DIR/out/ios/arm64/lib/*.a $OUT_DIR/ios/arm64
  make_dir $OUT_DIR/ios/x64
  cp -r $SOURCE_DIR/out/ios/x86_64/lib/*.a $OUT_DIR/ios/x64
  make_dir $OUT_DIR/ios/arm64-simulator
  cp -r $SOURCE_DIR/out/ios/arm64-simulator/lib/*.a $OUT_DIR/ios/arm64-simulator

  # build mac
  ../../scripts/build_ffmpeg_mac.sh
  rm -rf $OUT_DIR/mac
  make_dir $OUT_DIR/mac/arm64
  cp -r $SOURCE_DIR/out/mac/arm64/lib/*.a $OUT_DIR/mac/arm64
  make_dir $OUT_DIR/mac/x64
  cp -r $SOURCE_DIR/out/mac/x86_64/lib/*.a $OUT_DIR/mac/x64

  # create xcframework
  APPLE_DIR=$OUT_DIR/apple
  rm -rf $APPLE_DIR
  make_dir $APPLE_DIR/ios
  lipo -create $OUT_DIR/ios/arm64/libavcodec.a $OUT_DIR/ios/arm/libavcodec.a -o $APPLE_DIR/ios/libavcodec.a
  lipo -create $OUT_DIR/ios/arm64/libavutil.a $OUT_DIR/ios/arm/libavutil.a -o $APPLE_DIR/ios/libavutil.a
  mkdir -p $APPLE_DIR/simulator
  lipo -create $OUT_DIR/ios/x64/libavcodec.a $OUT_DIR/ios/arm64-simulator/libavcodec.a -o $APPLE_DIR/simulator/libavcodec.a
  lipo -create $OUT_DIR/ios/x64/libavutil.a $OUT_DIR/ios/arm64-simulator/libavutil.a -o $APPLE_DIR/simulator/libavutil.a
  make_dir $APPLE_DIR/mac
  lipo -create $OUT_DIR/mac/arm64/libavcodec.a $OUT_DIR/mac/x64/libavcodec.a -o $APPLE_DIR/mac/libavcodec.a
  lipo -create $OUT_DIR/mac/arm64/libavutil.a $OUT_DIR/mac/x64/libavutil.a -o $APPLE_DIR/mac/libavutil.a
  xcodebuild -create-xcframework -library $APPLE_DIR/simulator/libavcodec.a -library $APPLE_DIR/ios/libavcodec.a -library $APPLE_DIR/mac/libavcodec.a -output $APPLE_DIR/libavcodec.xcframework
  xcodebuild -create-xcframework -library $APPLE_DIR/simulator/libavutil.a -library $APPLE_DIR/ios/libavutil.a -library $APPLE_DIR/mac/libavutil.a -output $APPLE_DIR/libavutil.xcframework
  rm -rf $APPLE_DIR/ios
  rm -rf $APPLE_DIR/simulator
  rm -rf $APPLE_DIR/mac

  # build android
  ../../scripts/build_ffmpeg_android.sh
  rm -rf $OUT_DIR/android
  make_dir $OUT_DIR/android/arm
  cp -r $SOURCE_DIR/out/android/arm/lib/*.a $OUT_DIR/android/arm
  make_dir $OUT_DIR/android/arm64
  cp -r $SOURCE_DIR/out/android/arm64/lib/*.a $OUT_DIR/android/arm64
  make_dir $OUT_DIR/android/x64
  cp -r $SOURCE_DIR/out/android/x86_64/lib/*.a $OUT_DIR/android/x64

  # build web
  ../../scripts/build_ffmpeg_web.sh
  make_dir $OUT_DIR/web/wasm
  cp -r $SOURCE_DIR/out/web/wasm/lib/*.a $OUT_DIR/web/wasm

elif [[ $(uname) == 'Linux' ]]; then
  cd $SOURCE_DIR
  # build linux
  ../../scripts/build_ffmpeg_linux.sh
  make_dir $OUT_DIR/include
  cp -a $SOURCE_DIR/out/linux/include/* $OUT_DIR/include
  make_dir $OUT_DIR/linux
  cp -r $SOURCE_DIR/out/linux/lib/*.a $OUT_DIR/linux

elif [[ $(uname) == *MINGW64* ]]; then
  # build win64
  win_build x64

elif [[ $(uname) == *MINGW32* ]]; then
  # build win32
  win_build x86

fi

rm -rf $SOURCE_DIR/out
cd ../../
exit 0
