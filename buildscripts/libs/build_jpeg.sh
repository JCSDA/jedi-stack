#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

set -ex

name="jpeg"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
gitURL="https://github.com/LuaDist/libjpeg"
[[ -d $software ]] || ( git clone $gitURL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

# manage package dependencies here
if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    module try_load cmake
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${JPEG_ROOT:-"/usr/local"}
fi

export CC=$SERIAL_CC
export CFLAGS+=" -fPIC"

[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
sourceDir=$PWD
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

cmake $sourceDir \
  -DCMAKE_INSTALL_PREFIX=$prefix \
  -DBUILD_TESTS=ON \
  -DBUILD_EXECUTABLES=ON \
  -DCMAKE_BUILD_TYPE=RELEASE

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make test

$SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
