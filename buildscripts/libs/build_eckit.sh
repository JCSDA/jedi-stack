#!/bin/bash

set -ex

name="eckit"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')
mpi=$(echo $MPI | sed 's/\//-/g')

[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

set +x
source $MODULESHOME/init/bash
module load jedi-$COMPILER
module load jedi-$MPI
module load zlib udunits
module load netcdf
module load boost-headers eigen
module load ecbuild
module list
set -x

export FC=mpif90
export CC=mpicc
export CXX=mpicxx

export F9X=$FC
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="$FFLAGS"

prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"

software=$name
cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
[[ -d $software ]] || git clone https://github.com/ecmwf/$software.git
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
git checkout $version
sed -i -e 's/project( eckit CXX/project( eckit CXX Fortran/' CMakeLists.txt
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

ecbuild -DCMAKE_INSTALL_PREFIX=$prefix --build=Release ..
make -j${NTHREADS:-4}
$SUDO make install

# generate modulefile from template
cd $JEDI_STACK_ROOT/buildscripts
libs/update_modules.sh mpi $name $version

exit 0
