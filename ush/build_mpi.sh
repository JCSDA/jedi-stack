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
module list
set -x

export CC=gcc
export CXX=g++
export FC=gfortran
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="-fPIC"

[[ -d $dir_software ]] && cd $dir_software || (echo "$dir_software does not exist, ABORT!"; exit 1)

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$name/$version"

case "$name" in
    openmpi ) extra_conf="" ;;
    mpich   ) extra_conf="--enable-fortran --enable-cxx" ;;
    *       ) echo "Invalid option for MPI = $software, ABORT!"; exit 1 ;;
esac

./configure --prefix=$prefix $extra_conf
make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
