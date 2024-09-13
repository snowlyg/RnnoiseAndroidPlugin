# RnnoiseAndroidPlugin

## How to use

```
git clone https://github.com/snowlyg/RnnoiseAndroidPlugin.git --depth=1

cd RnnoiseAndroidPlugin
./make.sh

cd example
go build -o denoise main.go

./denoise origin.wav denoised.wav
```


## use for android

[RnnoiseAndroidPlugin](https://github.com/snowlyg/RnnoiseAndroidPlugin.git)

### mp4 to wav

```
ffmpeg -i <infile> -ac 2 -f wav <outfile>
```

## build for windows

```
  cd build/windows \
  rm -rf build_windows \
  mkdir build_windows \
  cd build_windows \
  cmake -DCMAKE_BUILD_TYPE=Release ..
  make
```
