#!/bin/bash
#
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.
#
# GEOS - https://trac.osgeo.org/geos/
# GEOS (Geometry Engine - Open Source) is a C++ port of the ​JTS Topology Suite (JTS). It aims to contain the complete functionality of JTS in C++.
# Required for cartopy
#
# NOTE: This has noting to do with GEOS model.

set -ex

name="geos"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')

set +x
source $MODULESHOME/init/bash
module load jedi-$JEDI_COMPILER
module try-load cmake
set -x

initialize_prefix_compiler $name $version $compiler

software=$name-$version
cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
tarname="$software.tar.bz2"
url="https://download.osgeo.org/geos/${tarname}"
[[ -d $software ]] || ( $WGET $url; tar -xf ${tarname} )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

[[ -d build ]] && $SUDO rm -rf build

cmake -H. -Bbuild -DCMAKE_INSTALL_PREFIX=$prefix
cd build
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
VERBOSE=$MAKE_VERBOSE $SUDO make -j${NTHREADS:-4} install

# generate modulefile from template
$MODULES && update_modules compiler $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
