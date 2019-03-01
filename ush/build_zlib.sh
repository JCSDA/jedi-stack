#!/bin/sh

set -ex

software=zlib-1.2.8

name=$(echo $software | cut -d"-" -f1)
version=$(echo $software | cut -d"-" -f2)

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

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$name/$version"

./configure --prefix=$prefix

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
