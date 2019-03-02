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
module load udunits
module list
set -x

export FC=gfortran
export CC=gcc
export CXX=g++
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"

export F77=$FC
export FCFLAGS=$FFLAGS

export LDFLAGS="-L$NETCDF_ROOT/lib -L$HDF5_ROOT/lib -L$SZIP_ROOT/lib"

[[ -d $dir_software ]] && cd $dir_software || (echo "$dir_software does not exist, ABORT!"; exit 1)

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$name/$version"

./configure --prefix=$prefix --enable-doc=no

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
