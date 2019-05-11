#!/bin/bash

set -ex

name=$1
version=$2

mm=$(echo $version | cut -d. -f-2)
patch=$(echo $version | cut -d. -f3)

case "$name" in
    openmpi ) url="https://download.open-mpi.org/release/open-mpi/v$mm/openmpi-$version.tar.gz" ;;
    mpich   ) url="http://www.mpich.org/static/downloads/$version/mpich-$version.tar.gz" ;;
    *       ) echo "Invalid option for MPI = $name, ABORT!"; exit 1 ;;
esac

# Hyphenated version used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')

set +x
source $MODULESHOME/init/bash
module load jedi-$COMPILER
module list
set -x

export CC=$SERIAL_CC
export CXX=$SERIAL_CXX
export FC=$SERIAL_FC

export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="-fPIC"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"../pkg"}

software=$name-$version
[[ -d $software ]] || ( wget $url; tar -xf $software.tar.gz )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
		      || ( echo "ERROR: $prefix EXISTS, ABORT!"; exit 1 )
fi

case "$name" in
    openmpi ) extra_conf="--enable-mpi-fortran --enable-mpi-cxx" ;;
    mpich   ) extra_conf="--enable-fortran --enable-cxx" ;;
    *       ) echo "Invalid option for MPI = $software, ABORT!"; exit 1 ;;
esac

../configure --prefix=$prefix $extra_conf
make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
$MODULES update_modules compiler $name $version

exit 0
