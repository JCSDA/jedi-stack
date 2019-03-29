#!/bin/sh

set -ex

name="eigen"
version=$1

compiler=${COMPILER:-"gnu-7.3.0"}

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module list
set -x

export FCFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"

cd ${PKGDIR:-"../pkg"}
[[ -d eigen-git-mirror ]] && cd eigen-git-mirror || (git clone -b "$version" https://github.com/eigenteam/eigen-git-mirror.git && cd eigen-git-mirror || (echo "git clone failed, ABORT!"; exit 1))

[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"$HOME/opt"}/$name/$version"

cmake .. -DCMAKE_INSTALL_PREFIX=$prefix
[[ "$CHECK" = "YES" ]] && ctest
make install

exit 0
