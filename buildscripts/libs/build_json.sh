#!/bin/bash
# © Crown Copyright 2020 Met Office UK
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

set -ex

name="json"
version=$1

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    module try-load cmake
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/core/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${json_ROOT:-"/usr/local"}
fi

cd $JEDI_STACK_ROOT/${PKGDIR:-"pkg"}

software="$name-$version"
tarfile="v$version.tar.gz"
url="https://github.com/nlohmann/json/archive/$tarfile"
[[ -d $software ]] || ( $WGET $url; tar -xf $tarfile )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

cmake .. -DCMAKE_INSTALL_PREFIX=$prefix -DJSON_BuildTests=$MAKE_CHECK
[[ $MAKE_CHECK =~ [yYtT] ]] && make test
$SUDO make install

# generate modulefile from template
$MODULES && update_modules core $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log

exit 0
