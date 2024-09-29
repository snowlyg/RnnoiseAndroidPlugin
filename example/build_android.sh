#!/bin/bash

echo "build android"

mkdir -p bin

# export NDK_ROOT=/opt/android/sdk/ndk
# GOOS=android GOARCH=arm GOARM=7 go get -d

export GOOS=$(go env | grep GOOS | cut -d "'" -f2)

CC="$NDK_ROOT/$NDK_VERSION/toolchains/llvm/prebuilt/$GOOS-x86_64/bin/armv7a-linux-androideabi29-clang" \
  CXX="$NDK_ROOT/$NDK_VERSION/toolchains/llvm/prebuilt/$GOOS-x86_64/bin/armv7a-linux-androideabi29-clang++" \
  CGO_ENABLED=1 CGO_CFLAGS="-march=armv7-a" \
  GOOS=android GOARCH=arm GOARM=7 \
  go build -o $(pwd)/bin/denoise $(pwd)/.

# adb connect $1
adb root
adb remount
adb push $(pwd)/bin/denoise /system/bin
adb push $(pwd)/origin.wav sdcard/chindeo_app/origin.wav
adb shell denoise sdcard/chindeo_app/origin.wav

# adb -s $1:5555 push $GOLANG_CALL_GATEWAY/cmd/ctl/index.html /system/bin
# adb -s $1:5555 push /opt/ssl/cert/dev-key.pem /system/bin
# adb -s $1:5555 push /opt/ssl/cert/dev.pem /system/bin
# adb -s $1:5555 shell gateway_media -s $1 -i $1 -m true -n 1100 -c "/system/bin/dev.pem" -k "/sdcard/chindeo_app/bin/dev-key.pem" -w ":1100" --devType=websocket --isServe true
# adb -s $1:5555 shell am force-stop com.chindeo.call.app

# curl --location 'http://$1:1100/register'
# curl --location 'http://$1:1100/invite' \
#   --header 'Content-Type: application/json' \
#   --data '{
#     "toNumber":"1100",
#     "fromNumber":"1100",
#     "isVideo":true
# }'

# GOOS=android GOARCH=arm64 CGO_ENABLED=1 CC=$NDK_ROOT/21.0.6113669/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi29-clang go build -o bin/gateway-arm64
# go build -i -buildmode=c-shared -o android/app/src/main/jniLibs/armeabi-v7a/libgomain.so
