#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.
#
# CGAL Library used by Atlas
# https://www.cgal.org
#
# WARNING: 
#   Dependencies include the gnu gmp and mpfr libraries
#   Also, if you are using gnu compilers prior to 9.0, then
#   you also need to install the boost.thread libraries.
#   These are often availble from package managers such as
#   apt, yum, or brew.  For example, for debian systems:
#
#   sudo apt-get update
#   sudo apt-get install libgmp-dev
#   sudo apt-get install libmpfr-dev
#   sudo apt-get install libboost-thread-dev
#
#

set -ex

name="cgal"
version=$1

cd $JEDI_STACK_ROOT/${PKGDIR:-"pkg"}

software="CGAL-"$version
url="https://github.com/CGAL/cgal/releases/download/v$version/$software-library.tar.xz"
[[ -d $software ]] || ( rm -f $software-library.tar.xz; $WGET $url; tar -xf $software-library.tar.xz )

[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

# Apply a patch to fix CMake intel compiler flags.
# Remove when possible or update as needed.
if [[ $version == "5.0.4" ]]; then
    # Note. Default patch on macOS doesn't recognize --merge,
    # need to install gpatch via homebrew (brew install gpatch)
    patch --merge -p1 < ${JEDI_STACK_ROOT}/buildscripts/libs/patches/${software}-intel-fpmodel-flag-fix.patch
else
    echo "Error: Must generate new patch for unsupported CGal version: $version"
    exit 1
fi

[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

# this is only needed if MAKE_CHECK is enabled
if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    module try_load cmake
    module try_load boost-headers
    module try_load zlib
    module try_load eigen
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/core/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${CGAL_ROOT:-"/usr/local"}
fi    

[[ -d _build ]] && rm -rf _build
cmake -H. -B_build -DCMAKE_INSTALL_PREFIX=$prefix -DWITH_CGAL_Qt5=0 -DCGAL_DISABLE_GMP=1 -DEIGEN3_INCLUDE_DIR=$EIGEN_ROOT/include -DCMAKE_INSTALL_LIBDIR=lib
cd _build && VERBOSE=$MAKE_VERBOSE $SUDO make install

# generate modulefile from template
$MODULES && update_modules core $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
