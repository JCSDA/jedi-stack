#!/bin/sh

set -ex

#openmpi-3.1.2 OR mpich-3.2.1
software=${MPI:-"openmpi-3.1.2"}

name=$(echo $software | cut -d"-" -f1)
version=$(echo $software | cut -d"-" -f2)

compiler=gnu-7.3.0

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

mkdir -p ../build ; cd ../build
rm -rf $software; tar -xzf ../pkg/$software.tar.gz; cd $software

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$name/$version"

case "$name" in
    openmpi ) extra_conf="" ;;
    mpich   ) extra_conf="--enable-fortran --enable-cxx" ;;
    *       ) echo "Invalid option for MPI = $software, ABORT!"; exit 1 ;;
esac

./configure --prefix=$prefix $extra_conf
make -j${NTHREADS:-4}
[[ -z $CHECK ]] && make check
make install

exit 0
