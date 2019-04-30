#!/bin/bash

set -ex

name="szip"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')

[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

# manage package dependencies here
set +x
source $MODULESHOME/init/bash
module load jedi-$COMPILER
module list
set -x

export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="-fPIC"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
url=https://support.hdfgroup.org/ftp/lib-external/szip/$version/src/$software.tar.gz
[[ -d $software ]] || ( wget $url; tar -xf $software.tar.gz )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                      || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
fi

../configure --prefix=$prefix

make -j${NTHREADS:-4} 
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
cd $JEDI_STACK_ROOT/buildscripts
libs/update_modules.sh compiler $name $version

exit 0
