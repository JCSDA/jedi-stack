#!/bin/sh

set -ex

software=$1
dir_software=${PKGDIR:-"../pkg"}/$software

name=$(echo $software | cut -d- -f1)
tag=$(echo $software | cut -d- -f3)
version=${2:-$tag}

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

[[ -d $dir_software ]] && cd $dir_software || (echo "$dir_software does not exist, ABORT!"; exit 1)
mkdir build && cd build

prefix="${PREFIX:-"$HOME/opt"}/$name/$version"

cmake .. -DCMAKE_INSTALL_PREFIX=$prefix
[[ "$CHECK" = "YES" ]] && ctest
make install

exit 0
