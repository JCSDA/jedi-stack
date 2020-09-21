#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.
#
# PROJ - https://proj.org/
# PROJ is a generic coordinate transformation software that transforms geospatial coordinates from one coordinate reference system (CRS) to another.
# Required for cartopy
#

set -ex

name="proj"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')

set +x
source $MODULESHOME/init/bash
module load jedi-$JEDI_COMPILER
module try-load cmake
module list
set -x

initialize_prefix_compiler $name $version $compiler "" sqlite
set -x
software=$name-$version
cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
tarname="$software.tar.gz"
url="https://download.osgeo.org/proj/$tarname"
[[ -d $software ]] || ( $WGET $url; tar -xf $tarname )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

[[ -d build ]] && $SUDO rm -rf build
LIB_DIR=$sqlite_ROOT cmake -H. -Bbuild -DCMAKE_INSTALL_PREFIX=$prefix
cd build
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
VERBOSE=$MAKE_VERBOSE $SUDO make -j${NTHREADS:-4} install

# generate modulefile from template
$MODULES && update_modules compiler $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
