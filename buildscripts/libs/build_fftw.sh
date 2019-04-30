#!/bin/bash

set -ex

name="fftw"
version=$1

software=$name-$version

# Hyphenated version used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')
mpi=$(echo $MPI | sed 's/\//-/g')

[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

set +x
source $MODULESHOME/init/bash
module load jedi-$COMPILER
module load jedi-$MPI
module list
set -x

export F77=$FC
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

url="http://fftw.org/${software}.tar.gz"
[[ -d $software ]] || ( wget $url; tar -xf $software.tar.gz )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                      || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
fi

[[ -z $mpi ]] || ( export MPICC=mpicc; extra_conf="--enable-mpi" )

../configure --prefix=$prefix --enable-openmp --enable-threads $extra_conf

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
cd $JEDI_STACK_ROOT/buildscripts

[[ -z $mpi ]] && libs/update_modules.sh compiler $name $version \
	      || libs/update_modules.sh mpi $name $version

exit 0
