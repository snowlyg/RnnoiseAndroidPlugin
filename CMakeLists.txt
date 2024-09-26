# cmake_minimum_required(VERSION 3.1)
cmake_minimum_required(VERSION 3.5...3.30) 
project(rnnoise)


# Set the target platform to Android
set(CMAKE_SYSTEM_NAME Android)

# which compilers to use for C and C++
set(CMAKE_C_COMPILER   $ENV{CC})
set(CMAKE_CXX_COMPILER $ENV{CXX})

set(CMAKE_CXX_FLAGS "-std=c++17 -DANDROID -g")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffunction-sections -fdata-sections")


# Specify the Android platform and architecture
set(ANDROID_ABI  $ENV{ANDROID_ABI})  # Specify your desired ABI, e.g., armeabi-v7a, arm64-v8a, x86, etc.

# Set the toolchain file for Android
# set(CMAKE_TOOLCHAIN_FILE  $ENV{NDK_ROOT}/$ENV{NDK_VERSION}/android-cmake/android.toolchain.cmake)

# Specify the Android API level
set(ANDROID_NATIVE_API_LEVEL 21)  # Specify the desired API level

# Include the Android toolchain file
# include(${CMAKE_TOOLCHAIN_FILE})

# Get source files
file(GLOB SOURCES "src/*.c" "src/*.h" "include/*.h")

# Build rnnoise
add_definitions(-DRNNOISE_BUILD)

# Compile the library
add_library(rnnoise ${SOURCES})

# Set compiler flags if needed
target_compile_options(rnnoise PUBLIC
        -Wall -finline-functions -fno-strict-aliasing -O3 -frtti -Wno-unknown-pragmas -funroll-loops -fexceptions -fno-math-errno)

# Set target properties
set_target_properties(rnnoise PROPERTIES
    ANDROID_ARM_MODE arm)

# Include dirs
target_include_directories(rnnoise PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
        PRIVATE src)

# Set include directories, sử dụng biến NDK_PATH
target_include_directories(rnnoise PUBLIC
        include
       $ENV{NDK_ROOT}/$ENV{NDK_VERSION}/sysroot/usr/include
       $ENV{NDK_ROOT}/$ENV{NDK_VERSION}/sysroot/usr/include/arm-linux-androideabi) 