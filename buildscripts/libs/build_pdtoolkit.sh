#!/bin/bash

set -ex

name="pdtoolkit"
version="3.25.1"

# Hyphenated version used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')

# manage package dependencies here
if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$COMPILER
    module load zlib
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
    if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${PDTLIB_ROOT:-"/usr/local/$name/$version"}
fi

export FC=$SERIAL_FC
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
url="http://tau.uoregon.edu/pdt_lite.tgz"
[[ -d $software ]] || ( $WGET $url; tar -xf pdt_lite.tgz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build

$SUDO ./configure -prefix=$prefix 

$SUDO make

$SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version

exit 0
