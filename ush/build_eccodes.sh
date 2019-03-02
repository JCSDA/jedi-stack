#!/bin/sh

set -ex

software=$1
dir_software=${PKGDIR:-"../pkg"}/$software

name=$(echo $software | cut -d"-" -f1)
version=$(echo $software | cut -d"-" -f2)

compiler=${COMPILER:-"gnu-7.3.0"}

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module load szip
module load hdf5
module load netcdf
module list
set -x

export FC=gfortran
export CC=gcc
export CXX=g++
export FCFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"

[[ -d $dir_software ]] && cd $dir_software || (echo "$dir_software does not exist, ABORT!"; exit 1)
mkdir -p build && cd build

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$name/$version"

cmake -DCMAKE_INSTALL_PREFIX=$prefix -DENABLE_NETCDF=ON -DENABLE_FORTRAN=ON ..

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && ctest
make install

exit 0
