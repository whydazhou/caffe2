#!/bin/bash
##############################################################################
# Build script to build the protoc compiler for the host platform.
##############################################################################
# This script builds the protoc compiler for the host platform, which is needed
# for any cross-compilation as we will need to convert the protobuf source
# files to cc files.
#
# --other-flags accepts flags that should be passed to cmake. Optional.
#
# After the execution of the file, one should be able to find the host protoc
# binary at build_host_protoc/bin/protoc.

set -e

CAFFE2_ROOT="$( cd "$(dirname -- "$0")"/.. ; pwd -P)"
BUILD_ROOT=${BUILD_ROOT:-"$CAFFE2_ROOT/build_host_protoc"}
mkdir -p $BUILD_ROOT/build
cd $BUILD_ROOT/build

CMAKE_ARGS=()
CMAKE_ARGS+=("-DCMAKE_INSTALL_PREFIX=$BUILD_ROOT")
CMAKE_ARGS+=("-Dprotobuf_BUILD_TESTS=OFF")

while true; do
    case "$1" in
        --other-flags)
            shift;
            CMAKE_ARGS+=("$@")
            break ;;
        "")
            break ;;
        *)
            echo "Unknown option passed as argument: $1"
            break ;;
    esac
done

# Use ccache if available (this path is where Homebrew installs ccache symlinks)
if [ "$(uname)" == 'Darwin' ] && [ -d /usr/local/opt/ccache/libexec ]; then
  CMAKE_ARGS+=("-DCMAKE_C_COMPILER=/usr/local/opt/ccache/libexec/gcc")
  CMAKE_ARGS+=("-DCMAKE_CXX_COMPILER=/usr/local/opt/ccache/libexec/g++")
fi

cmake "$CAFFE2_ROOT/third_party/protobuf/cmake" ${CMAKE_ARGS[@]}

if [ "$(uname)" == 'Darwin' ]; then
  make "-j$(sysctl -n hw.ncpu)" install
else
  make "-j$(nproc)" install
fi
