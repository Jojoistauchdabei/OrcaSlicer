#!/bin/bash

set -e

SCRIPT_NAME=$(basename "$0")
SCRIPT_PATH=$(dirname $(readlink -f ${0}))

pushd ${SCRIPT_PATH} > /dev/null

# Configuration
BUILD_TYPE="Release"
BUILD_DIR="build-windows"
DEPS_DIR="deps-windows"
CMAKE_BUILD_PARALLEL_LEVEL=${CMAKE_BUILD_PARALLEL_LEVEL:-$(nproc)}

# Cross-compilation toolchain
export CC=x86_64-w64-mingw32-gcc
export CXX=x86_64-w64-mingw32-g++
export AR=x86_64-w64-mingw32-ar
export STRIP=x86_64-w64-mingw32-strip
export WINDRES=x86_64-w64-mingw32-windres

# CMake toolchain file
TOOLCHAIN_FILE="cmake/windows-toolchain.cmake"

echo "Building OrcaSlicer for Windows (cross-compilation from Linux)"
echo "Build type: ${BUILD_TYPE}"
echo "Build directory: ${BUILD_DIR}"
echo "Dependencies directory: ${DEPS_DIR}"
echo "Parallel jobs: ${CMAKE_BUILD_PARALLEL_LEVEL}"

# Create build directories
mkdir -p ${BUILD_DIR}
mkdir -p ${DEPS_DIR}

# Build dependencies first
echo "Building dependencies..."
cd ${DEPS_DIR}

# Configure dependencies
cmake ../deps \
    -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DCMAKE_TOOLCHAIN_FILE=../${TOOLCHAIN_FILE} \
    -DDESTDIR="${PWD}/OrcaSlicer_dep" \
    -DDEP_DEBUG=OFF \
    -DORCA_INCLUDE_DEBUG_INFO=OFF

# Build dependencies
cmake --build . --config ${BUILD_TYPE} --target deps -- -j${CMAKE_BUILD_PARALLEL_LEVEL}

echo "Dependencies built successfully!"

# Build OrcaSlicer
echo "Building OrcaSlicer..."
cd ../${BUILD_DIR}

# Configure OrcaSlicer
cmake .. \
    -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DCMAKE_TOOLCHAIN_FILE=../${TOOLCHAIN_FILE} \
    -DBBL_RELEASE_TO_PUBLIC=1 \
    -DCMAKE_PREFIX_PATH="../${DEPS_DIR}/OrcaSlicer_dep/usr/local" \
    -DCMAKE_INSTALL_PREFIX="./OrcaSlicer" \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE}

# Build OrcaSlicer
cmake --build . --config ${BUILD_TYPE} --target ALL_BUILD -- -j${CMAKE_BUILD_PARALLEL_LEVEL}

# Install
cmake --build . --target install --config ${BUILD_TYPE}

echo "Build completed successfully!"
echo "Windows executable should be available in: ${BUILD_DIR}/OrcaSlicer/"

popd > /dev/null
