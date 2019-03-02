#!/bin/sh

set -ex


software_c=$1
software_f=$2
software_cxx=$3

name=$(echo $software_c | cut -d"-" -f1)
version=$(echo $software_c | cut -d"-" -f3)

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

# NetCDF C
cd $curr_dir
dir_software=${PKGDIR:-"../pkg"}/$software_c
[[ -d $dir_software ]] && cd $dir_software || (echo "$dir_software does not exist, ABORT!"; exit 1)

export LDFLAGS="-L$HDF5_ROOT/lib -L$SZIP_ROOT/lib"

./configure --prefix=$prefix $extra_conf

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

export LDFLAGS+=" -L$prefix/lib"

# NetCDF Fortran
cd $curr_dir
dir_software=${PKGDIR:-"../pkg"}/$software_f
[[ -d $dir_software ]] && cd $dir_software || (echo "$dir_software does not exist, ABORT!"; exit 1)

./configure --prefix=$prefix $extra_conf

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

# NetCDF CXX
cd $curr_dir
dir_software=${PKGDIR:-"../pkg"}/$software_cxx
[[ -d $dir_software ]] && cd $dir_software || (echo "$dir_software does not exist, ABORT!"; exit 1)

./configure --prefix=$prefix

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
