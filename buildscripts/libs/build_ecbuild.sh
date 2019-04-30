#!/bin/bash

set -ex

name="ecbuild"
version=$1

[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

prefix="${PREFIX:-"/opt/modules"}/core/$name/$version"

software=ecbuild
cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
[[ -d $software ]] || git clone https://github.com/ecmwf/$software.git
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
git checkout $version
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                      || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
fi

cmake -DCMAKE_INSTALL_PREFIX=$prefix ..
$SUDO make install

# generate modulefile from template
cd $JEDI_STACK_ROOT/buildscripts
libs/update_modules.sh core $name $version

exit 0
