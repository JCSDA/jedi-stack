#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

set -x

name="ecflow"
source=$1
version=$2

software=$name
cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
[[ -d $software ]] || git clone https://github.com/$source/$software.git
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
git fetch --tags
git checkout $version

ecflowVersion=$(awk '/^project/ && /ecflow/ && /VERSION/ {for (I=1;I<=NF;I++) if ($I == "VERSION") {print $(I+1)};}' CMakeLists.txt)
pythonVersion=$(`which python3` -c 'import sys;print(sys.version_info[0],".",sys.version_info[1],sep="")')

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    module try-load cmake git python qt
    module load boost
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix=${ECFLOW_ROOT:-"/usr/local"}
fi

export FC=$SERIAL_FC
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX

[[ -d build ]] && $SUDO rm -rf build
mkdir -p build && cd build

host=$(uname -s)
if [[ "$host" == "Darwin" ]]
then
    export OPENSSL_ROOT_DIR=`brew --prefix openssl`
    export OPENSSL_INCLUDE_DIR=$OPENSSL_ROOT_DIR/include
    export QT=`brew --prefix qt`
    QT_LOC="-DCMAKE_PREFIX_PATH=$QT"
fi

cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_BUILD_TYPE=Release -DENABLE_STATIC_BOOST_LIBS=OFF $QT_LOC \
    -DENABLE_STATIC_BOOST_LIBS=OFF ..
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
VERBOSE=$MAKE_VERBOSE $SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version $pythonVersion \
         || echo $name $ecflowVersion >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
