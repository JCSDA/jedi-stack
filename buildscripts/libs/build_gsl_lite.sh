#!/bin/bash

# This is a project to generate C++/Python bindings.
# Library is header-only, so there is no need to link to Python here.

set -ex

name="gsl_lite"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    module try-load cmake
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/core/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix="/usr/local"
fi

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=gsl-lite
branch=v$(echo $version)
[[ -d $software ]] || git clone https://github.com/gsl-lite/$software
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
git fetch
git checkout $branch
[[ -d build ]] && rm -rf build
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DGSL_LITE_OPT_INSTALL_COMPAT_HEADER=ON -DCMAKE_VERBOSE_MAKEFILE=1 ..
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
#[[ $MAKE_CHECK =~ [yYtT] ]] && make test
VERBOSE=$MAKE_VERBOSE $SUDO make install

# generate modulefile from template
$MODULES && update_modules core $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
