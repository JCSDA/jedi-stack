#!/bin/bash

set -ex

name="netcdf"
c_version=$1
f_version=$2
cxx_version=$3

# Hyphenated version used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')
mpi=$(echo $MPI | sed 's/\//-/g')

[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

set +x
source $MODULESHOME/init/bash
module load jedi-$COMPILER
module load jedi-$MPI
module load szip
module load hdf5
module load pnetcdf
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

prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$c_version"
if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                      || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
fi

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
curr_dir=$(pwd)

export LDFLAGS="-L$HDF5_ROOT/lib -L$SZIP_ROOT/lib"

cd $curr_dir

set +x
echo "################################################################################"
echo "BUILDING NETCDF-C"
echo "################################################################################"
set -x

version=$c_version
software=$name-"c"-$version
[[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-c.git $software )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

[[ -z $mpi ]] || extra_conf="--enable-pnetcdf --enable-netcdf-4 --enable-parallel-tests"
../configure --prefix=$prefix $extra_conf

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

export LDFLAGS+=" -L$prefix/lib"
export CFLAGS+=" -I$prefix/include"
export CXXFLAGS+=" -I$prefix/include"

cd $curr_dir

set +x
echo "################################################################################"
echo "BUILDING NETCDF-Fortran"
echo "################################################################################"
set -x

version=$f_version
software=$name-"fortran"-$version
[[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-fortran.git $software )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix $extra_conf

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

cd $curr_dir

set +x
echo "################################################################################"
echo "BUILDING NETCDF-CXX"
echo "################################################################################"
set -x

version=$cxx_version
software=$name-"cxx4"-$version
[[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-cxx4.git $software )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
cd $JEDI_STACK_ROOT/buildscripts
libs/update_modules.sh mpi $name $c_version

exit 0
