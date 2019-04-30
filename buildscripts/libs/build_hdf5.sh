#!/bin/bash

set -ex

name="hdf5"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')
mpi=$(echo $MPI | sed 's/\//-/g')

[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

set +x
source $MODULESHOME/init/bash
module load jedi-$COMPILER
module load jedi-$MPI
module load szip zlib
module list
set -x

if [[ ! -z $mpi ]]; then
    export FC=mpif90
    export CC=mpicc
    export CXX=mpicxx
fi

export F9X=$FC
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="$FFLAGS"

gitURL="https://bitbucket.hdfgroup.org/scm/hdffv/hdf5.git"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$(echo $version | sed 's/\./_/g')
[[ -d $software ]] || ( git clone -b $software $gitURL $software )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                      || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
fi

[[ -z $mpi ]] || extra_conf="--enable-parallel --enable-unsupported"

../configure --prefix=$prefix --enable-fortran --enable-fortran2003 --enable-cxx --enable-hl --enable-shared --with-szlib=$SZIP_ROOT --with-zlib=$ZLIB_ROOT $extra_conf

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
[[ $USE_SUDO =~ [yYtT] ]] && sudo -- bash -c "export PATH=$PATH; make install" \
	                  || make install

# generate modulefile from template
cd $JEDI_STACK_ROOT/buildscripts
libs/update_modules.sh mpi $name $version

exit 0
