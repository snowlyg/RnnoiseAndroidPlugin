#!/bin/bash

sudo rm -rf ./src
git clone https://github.com/xiph/rnnoise.git --depth=1 src
# git clone https://github.com/TeaSpeak/rnnoise-cmake --depth=1 src
sudo chmod -R 0777 ./src
sudo cp CMakeLists.txt ./src
cd ./src

src_path=$(pwd)

# fix v.2.0  fatal error: src/_kiss_fft_guts.h: No such file or directory
# $src_path/src/dump_features.c
sed -i 's/#include "src\/_kiss_fft_guts.h"/#include "_kiss_fft_guts.h"/g' $src_path/src/dump_features.c

cat $src_path/src/dump_features.c | grep "_kiss_fft_guts.h"

export GOOS=$(go env | grep GOOS | cut -d "'" -f2)

# foreach n ( "armv7a" "aarch64" )
#   echo
#   #command2
# end

./autogen.sh

./configure
make

cp ./.libs/librnnoise.a ../../lib/librnnoise-linux-amd64.a

cp ./libs

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

  rm -rf build_android
  mkdir build_android
  cd build_android
  cmake -DCMAKE_BUILD_TYPE=Release ..
  make

  cp librnnoise.a ../../lib/librnnoise-android-$arm.a
  cd ../
done
