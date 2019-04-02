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
module load $(echo $mpi | sed 's/-/\//g')
module load szip
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

gitURLroot="https://github.com/Unidata"

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$mpi/$name/$c_version"
[[ -d $prefix ]] && ( echo "$prefix exists, ABORT!"; exit 1 )

[[ -z $mpi ]] || extra_conf="--enable-parallel-tests"

cd ${PKGDIR:-"../pkg"}
curr_dir=$(pwd)

export LDFLAGS="-L$HDF5_ROOT/lib -L$SZIP_ROOT/lib"

cd $curr_dir

# NetCDF C
version=$c_version
software=$name-"c"-$version
[[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-c.git $software )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix $extra_conf

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

export LDFLAGS+=" -L$prefix/lib"
export CFLAGS+=" -I$prefix/include"

cd $curr_dir

# NetCDF Fortran
version=$f_version
software=$name-"fortran"-$version
[[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-fortran.git $software )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix $extra_conf

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

cd $curr_dir

# NetCDF CXX
version=$cxx_version
software=$name-"cxx4"-$version
[[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-cxx4.git $software )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
