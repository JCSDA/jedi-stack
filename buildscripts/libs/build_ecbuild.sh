#!/bin/bash

set -ex

name="ecbuild"
source=$1
version=$2
dash_version=$(echo -n $version | sed -e "s@/@-@g")

if $MODULES; then

    module try-load cmake

    prefix="${PREFIX:-"/opt/modules"}/core/$name/$source-$dash_version"
    if [[ -d $prefix ]]; then
	[[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
            || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix=${ECBUILD_ROOT:-"/usr/local"}
fi

software=ecbuild
cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
[[ -d $software ]] && [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $software EXISTS: OVERWRITING!";$SUDO rm -rf $software )
[[ -d $software ]] || git clone https://github.com/$source/$software.git
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
git checkout $version
[[ -d build ]] && $SUDO rm -rf build
mkdir -p build && cd build

cmake -DCMAKE_INSTALL_PREFIX=$prefix ..
VERBOSE="$MAKE_VERBOSE" $SUDO make install

# generate modulefile from template
$MODULES && update_modules core $name $source-$dash_version \
         || echo $name $source-$dash_version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log			   
