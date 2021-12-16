#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

set -ex

name="gnu"
version=$1

software="gcc-$version"

prefix="${PREFIX:-"$HOME/opt"}/$name/$version"
[[ -d $prefix ]] && ( echo "$prefix exists, ABORT!"; exit 1 )

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

url="https://mirrors.tripadvisor.com/gnu/gcc/$software/$software.tar.gz"
[[ -d $software ]] || ( rm -f $software.tar.gz; $WGET $url; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
contrib/download_prerequisites
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

extra_conf="--disable-multilib"

../configure -v \
             --prefix=$prefix \
             --enable-checking=release \
             --enable-languages=c,c++,fortran $extra_conf

make V=$MAKE_VERBOSE -j${NTHREADS:-4}
$SUDO make install-strip

# generate modulefile from template
$MODULES && update_modules core $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
