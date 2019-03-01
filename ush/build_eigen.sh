#!/bin/sh

set -ex

software=eigen-eigen-b3f3d4950030
name=eigen
version=3.3.5

compiler=${COMPILER:-"gnu-7.3.0"}

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module list
set -x

export FC=gfortran
export CC=gcc
export CXX=g++
export FCFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"

mkdir -p ../build ; cd ../build
rm -rf $software; tar -xzf ../pkg/$software.tar.gz; cd $software
mkdir build && cd build

prefix="${PREFIX:-"$HOME/opt"}/$name/$version"

cmake .. -DCMAKE_INSTALL_PREFIX=$prefix
[[ "$CHECK" = "YES" ]] && ctest
make install

exit 0
