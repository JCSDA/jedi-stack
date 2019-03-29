#!/bin/sh

set -ex

name="netcdf"
c_version=$1
f_version=$2
cxx_version=$3

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


if [[ ! -z $mpi ]]; then
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

gitUnidata="https://github.com/Unidata"

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$mpi/$name/$c_version"

[[ -z $mpi ]] || extra_conf="--enable-parallel-tests"

curr_dir=$(pwd)

export LDFLAGS="-L$HDF5_ROOT/lib -L$SZIP_ROOT/lib"

# NetCDF C
software=$name-"c"
version=$c_version
cd $curr_dir
cd ${PKGDIR:-"../pkg"}
[[ -d $software ]] && cd $software || (git clone -b "v$version" $gitUnidata/$software.git && cd $software || (echo "git clone failed, ABORT!"; exit 1))
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix $extra_conf

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

export LDFLAGS+=" -L$prefix/lib"

# NetCDF Fortran
software=$name-"fortran"
version=$f_version
cd $curr_dir
cd ${PKGDIR:-"../pkg"}
[[ -d $software ]] && cd $software || (git clone -b "v$version" $gitUnidata/$software.git && cd $software || (echo "git clone failed, ABORT!"; exit 1))
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix $extra_conf

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

# NetCDF CXX
software=$name-"cxx4"
version=$cxx_version
cd $curr_dir
cd ${PKGDIR:-"../pkg"}
[[ -d $software ]] && cd $software || (git clone -b "v$version" $gitUnidata/$software.git && cd $software || (echo "git clone failed, ABORT!"; exit 1))
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
