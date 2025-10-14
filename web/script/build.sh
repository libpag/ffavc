#!/bin/bash -e

SOURCE_DIR=../..
BUILD_DIR=../../build
BUILD_TS="npm run build"

echo "-----begin-----"

if [ ! -d "../src/wasm" ]; then
  mkdir ../src/wasm
fi

RELEASE_CONF="-Oz -s"
CMAKE_BUILD_TYPE=Relese
if [[ $@ == *debug* ]]; then
  CMAKE_BUILD_TYPE=Debug
  RELEASE_CONF="-O0 -gsource-map -sSAFE_HEAP=1 -Wno-limited-postlink-optimizations"
  BUILD_TS=""
fi

emcmake cmake -S $SOURCE_DIR -B $BUILD_DIR -G Ninja -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE"

cmake --build $BUILD_DIR --target ffavc

emcc $RELEASE_CONF -std=c++17 \
  -I$SOURCE_DIR/src/ \
  -I$SOURCE_DIR/vendor/ffmpeg/include/ \
  -I$SOURCE_DIR/vendor/libpag/include/ \
  $SOURCE_DIR/vendor/ffmpeg/web/wasm/*.a \
  $BUILD_DIR/libffavc.a \
  ../src/ffavc_wasm_bindings.cpp \
  --no-entry \
  -lembind \
  -s WASM=1 \
  -s ALLOW_MEMORY_GROWTH=1 \
  -s MEMORY_GROWTH_GEOMETRIC_STEP=0.25 \
  -s EXPORT_NAME="FFAVCInit" \
  -s ERROR_ON_UNDEFINED_SYMBOLS=0 \
  -s MODULARIZE=1 \
  -s NO_EXIT_RUNTIME=1 \
  -s ENVIRONMENT="web" \
  -s EXPORT_ES6=1 \
  -s EXPORTED_FUNCTIONS=['_malloc','_free'] \
  -o ../src/wasm/ffavc.js

if [ ! -d "../lib" ]; then
  mkdir ../lib
fi

cp -f ../src/wasm/ffavc.wasm ../lib

$BUILD_TS

echo "-----end-----"
