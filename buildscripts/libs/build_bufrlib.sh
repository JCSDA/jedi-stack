#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

set -ex

name="bufrlib"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')

# manage package dependencies here
if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    module try-load cmake
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
    if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${BUFRLIB_ROOT:-"/usr/local"}
fi

export FC=$SERIAL_FC
export CC=$SERIAL_CC

## Implementation can be switched to NCEPLIBS-bufr when shared libraries are supported
software=bufrlib
#software=NCEPLIBS-bufr

# Release git tag name
tag=bufr_v$version

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
[[ -d $software ]] || git clone https://github.com/JCSDA/$software.git
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
git fetch
git checkout --detach $tag
[[ -d build ]] && rm -rf build

cmake -H. -Bbuild -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=1 -DOPT_IPO=OFF
cd build
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
VERBOSE=$MAKE_VERBOSE $SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
