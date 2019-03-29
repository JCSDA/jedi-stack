#!/bin/sh

set -ex

name=$1
version=$2

software=$name-$version

compiler=${COMPILER:-"gnu-7.3.0"}
mpi=${MPI:-""}

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module load $(echo $mpi | sed 's/-/\//g')
module list
set -x

export F77=$FC
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export MPICC=mpicc

cd ${PKGDIR:-"../pkg"}
[[ -d $software ]] && cd $software || (echo "$software does not exist, ABORT!"; exit 1)
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$mpi/$name/$version"

[[ -z $mpi ]] || extra_conf="--enable-mpi"

../configure --prefix=$prefix --enable-openmp --enable-threads $extra_conf

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
