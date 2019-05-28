#!/bin/bash

set -ex

name="ecbuild"
source=$1
version=$2

if $MODULES; then

    module try-load cmake

    prefix="${PREFIX:-"/opt/modules"}/core/$name/$source-$version"
    if [[ -d $prefix ]]; then
	[[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
            || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix="/usr/local"
fi

software=ecbuild
cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
[[ -d $software ]] || git clone https://github.com/$source/$software.git
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
git checkout $version
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

cmake -DCMAKE_INSTALL_PREFIX=$prefix ..
$SUDO make install

# generate modulefile from template
$MODULES && update_modules core $name $source-$version

exit 0
