#!/bin/bash -e
OUT_DIR=out/win
OPTIONS="--disable-all --disable-everything --disable-debug --disable-autodetect --enable-avcodec --enable-decoder=h264 --disable-x86asm"

function make_dir() {
  rm -rf $1
  mkdir -p $1
}

helpFunction() {
   echo ""
   echo "Usage: $0 -t arch"
   echo "-t x86"
   echo "-t x64"
   echo ""
   exit 1
}

while getopts "t:" opt
do
	case "$opt" in
		t ) parameterT="$OPTARG" ;;
		* ) helpFunction ;;
	esac
done

case $parameterT in
	 x86 )
	    OPTIONS="$OPTIONS \
				--target-os=win32 \
				--arch=x86 \
				"
			ARCH="x86"
		;;
	   x64 )
	    OPTIONS="$OPTIONS \
				--target-os=win64 \
				--arch=x86_64 \
				"
			ARCH="x64"
		;;
	  * )
	    helpFunction
		;;
esac

make_dir $OUT_DIR

build_arch() {
  echo "--win---ARCH:$ARCH"

  ./configure --toolchain=msvc --enable-cross-compile $OPTIONS \
    --prefix=$OUT_DIR/$ARCH
  make -j12
  make install
  make clean
}

build_arch



