#!/bin/sh

set -ex

software=fftw-3.3.8

name=$(echo $software | cut -d"-" -f1)
version=$(echo $software | cut -d"-" -f2)

compiler=${COMPILER:-"gnu-7.3.0"}
mpi=${MPI:-""}

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module load $(echo $mpi | sed 's/-/\//g')
module list
set -x

export F77=gfortran
export CC=gcc
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export MPICC=mpicc

mkdir -p ../build ; cd ../build
rm -rf $software; tar -xzf ../pkg/$software.tar.gz; cd $software

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$mpi/$name/$version"

[[ -z $mpi ]] || extra_conf="--enable-mpi"

./configure --prefix=$prefix --enable-openmp --enable-threads $extra_conf

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
