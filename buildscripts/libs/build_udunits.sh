#!/bin/bash

set -ex

name="udunits"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')

[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

set +x
source $MODULESHOME/init/bash
module load jedi-$COMPILER
module list
set -x

export FCFLAGS="-fPIC"
export CFLAGS="-fPIC"


cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
url=ftp://ftp.unidata.ucar.edu/pub/udunits/$software.tar.gz
[[ -d $software ]] || ( wget $url; tar xvf $software.tar.gz )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
[[ -d $prefix ]] && ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )

../configure --prefix=$prefix

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
$SUDO make install

# generate modulefile from template
cd $JEDI_STACK_ROOT/buildscripts
libs/update_modules.sh compiler $name $version

exit 0
