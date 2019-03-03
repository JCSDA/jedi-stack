#!/bin/sh

set -ex

name=$1
version=$2
f_version=$3
cxx_version=$4

software_c=$name-"c"-$version
software_f=$name-"fortran"-$f_version
software_cxx=$name-"cxx4"-$cxx_version

compiler=${COMPILER:-"gnu-7.3.0"}
mpi=${MPI:-""}

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module load szip
module load $(echo $mpi | sed 's/-/\//g')
module load hdf5
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

export F77=$FC
export F9X=$FC
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="$FFLAGS"

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$mpi/$name/$version"

[[ -z $mpi ]] || extra_conf="--enable-parallel-tests"

curr_dir=$(pwd)

export LDFLAGS="-L$HDF5_ROOT/lib -L$SZIP_ROOT/lib"

# NetCDF C
cd $curr_dir
cd ${PKGDIR:-"../pkg"}
[[ -d $software_c ]] && cd $software_c || (echo "$software_c does not exist, ABORT!"; exit 1)
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix $extra_conf

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

export LDFLAGS+=" -L$prefix/lib"

# NetCDF Fortran
cd $curr_dir
cd ${PKGDIR:-"../pkg"}
[[ -d $software_f ]] && cd $software_f || (echo "$software_f does not exist, ABORT!"; exit 1)
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix $extra_conf

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

# NetCDF CXX
cd $curr_dir
cd ${PKGDIR:-"../pkg"}
[[ -d $software_cxx ]] && cd $software_cxx || (echo "$software_cxx does not exist, ABORT!"; exit 1)
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
