#!/bin/sh

set -ex

software=$1
dir_software=${PKGDIR:-"../pkg"}/$software

name=$(echo $software | cut -d"-" -f1)
version=$(echo $software | cut -d"-" -f2)

compiler=${COMPILER:-"gnu-7.3.0"}
mpi=${MPI:-""}

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module load szip
module load $(echo $mpi | sed 's/-/\//g')
module list
set -x

if [[ -z $mpi ]]; then
    export FC=gfortran
    export CC=gcc
    export CXX=g++
else
    export FC=mpif90
    export CC=mpicc
    export CXX=mpicxx
fi

export F9X=$FC
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="$FFLAGS"

[[ -d $dir_software ]] && cd $dir_software || (echo "$dir_software does not exist, ABORT!"; exit 1)

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$mpi/$name/$version"

[[ -z $mpi ]] || extra_conf="--enable-parallel --enable-unsupported"

./configure --prefix=$prefix --enable-fortran --enable-cxx --enable-hl --enable-shared --with-szlib=$SZIP_ROOT $extra_conf

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
