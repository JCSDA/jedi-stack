#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

set -ex

name="eigen"
version=$1

cd $JEDI_STACK_ROOT/${PKGDIR:-"pkg"}

software="eigen-$version"
tarfile="$software.tar.bz2"
url="https://gitlab.com/libeigen/eigen/-/archive/$version/$tarfile"
[[ -d $software ]] || ( rm -f $tarfile; $WGET $url; tar -xf $tarfile )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

# this is only needed if MAKE_CHECK is enabled
if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    module try_load boost-headers
    module try_load cmake
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/core/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${EIGEN_ROOT:-"/usr/local"}
fi

[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

cmake .. -DCMAKE_INSTALL_PREFIX=$prefix
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
$MODULES && update_modules core $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log

exit 0
