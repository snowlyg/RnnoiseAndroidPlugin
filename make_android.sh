#!/bin/bash

current=$(pwd)
src_path=$current/src

sudo rm -rf $src_path

git clone https://github.com/xiph/rnnoise.git -b master --depth=1 src
# git clone https://github.com/TeaSpeak/rnnoise-cmake --depth=1 src
sudo chmod -R 0777 $src_path

cd $src_path

# fix v.2.0  fatal error: src/_kiss_fft_guts.h: No such file or directory
# $src_path/src/dump_features.c
# sed -i 's/#include "src\/_kiss_fft_guts.h"/#include "_kiss_fft_guts.h"/g' $src_path/src/dump_features.c

export GOOS=$(go env | grep GOOS | cut -d "'" -f2)

./autogen.sh

sudo cp $current/CMakeLists.txt $src_path

for arm in armv7a aarch64; do
  printf "arm:$arm \n"
  if [ "$arm" == "armv7a" ]; then
    export ANDROID_ABI=armeabi-v7a
    export CC="$NDK_ROOT/$NDK_VERSION/toolchains/llvm/prebuilt/$GOOS-x86_64/bin/$arm-linux-androideabi29-clang"
    export CXX="$NDK_ROOT/$NDK_VERSION/toolchains/llvm/prebuilt/$GOOS-x86_64/bin/$arm-linux-androideabi29-clang++"
  else
    export ANDROID_ABI=arm64-v8a
    export CC="$NDK_ROOT/$NDK_VERSION/toolchains/llvm/prebuilt/$GOOS-x86_64/bin/$arm-linux-android29-clang"
    export CXX="$NDK_ROOT/$NDK_VERSION/toolchains/llvm/prebuilt/$GOOS-x86_64/bin/$arm-linux-android29-clang++"
  fi

  printf "CC: $CC \n"
  printf "CXX: $CXX \n"
  printf "ANDROID_ABI: $ANDROID_ABI \n"

  rm -rf $src_path/build_android
  mkdir $src_path/build_android
  cd $src_path/build_android

  cmake ..
  make

  cp librnnoise.a $current/libs/librnnoise-android-$arm.a
done
