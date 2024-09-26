# Sample toolchain file for building for Windows from an Ubuntu Linux system.
#
# Typical usage:
#    *) install cross compiler: `sudo apt-get install mingw-w64` or `brew install mingw-w64` on macOS
#    *) cmake -DCMAKE_BUILD_TYPE=Release ..
#    *) make

cmake_minimum_required(VERSION 3.5...3.30) 
project(rnnoise)

set(CMAKE_SYSTEM_NAME Windows)
set(TOOLCHAIN_PREFIX x86_64-w64-mingw32)

# cross compilers to use for C, C++ and Fortran
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++)
set(CMAKE_Fortran_COMPILER ${TOOLCHAIN_PREFIX}-gfortran)
set(CMAKE_RC_COMPILER ${TOOLCHAIN_PREFIX}-windres)

# target environment on the build host system
set(CMAKE_FIND_ROOT_PATH /usr/${TOOLCHAIN_PREFIX})

# modify default behavior of FIND_XXX() commands
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(CMAKE_CXX_FLAGS "-std=c++17 -DANDROID -g")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffunction-sections -fdata-sections")


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