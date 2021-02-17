#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

set -x

name="ecflow"
source=$1
version=$2
boost=$3
boost_version=$4

# Build boost libraries first; ecFlow requires them
# Install boost and ecFlow in ecFlow directory hierarchy

# Steps 
# 1. get ecFlow software
# 2. get boost software, downloaded into ecFlow pkg dir
# 3. build full boost (libs, headers) in ecFlow pkg dir
# 4. build ecFlow against boost

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name
[[ -d $software ]] || git clone https://github.com/$source/$software.git
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
git fetch --tags
git checkout $version

compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')
mpi=$(echo $JEDI_MPI | sed 's/\//-/g')

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    [[ -z $mpi ]] || module load jedi-$JEDI_MPI
    module try-load cmake git python qt
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

# boost component
boost_software=$boost\_$(echo $boost_version | sed 's/\./_/g')
url="https://dl.bintray.com/boostorg/release/$boost_version/source/$boost_software.tar.gz"
[[ -d $boost_software ]] || ( $WGET $url; tar -xf $boost_software.tar.gz )
[[ -d $boost_software ]] && cd $boost_software || ( echo "$boost_software does not exist, ABORT!"; exit 1 )

debug="--debug-configuration"

BoostRoot=$(pwd)
BoostBuild=$BoostRoot/BoostBuild
build_boost=$BoostRoot/build_boost
[[ -d $BoostBuild ]] && rm -rf $BoostBuild
[[ -d $build_boost ]] && rm -rf $build_boost
cd $BoostRoot/tools/build

# Configure with MPI
compName=$(echo $compiler | cut -d- -f1)
case "$compName" in
    gnu   ) MPICC=$(which mpicc)  ; toolset=gcc ;;
    intel ) MPICC=$(which mpiicc) ; toolset=intel ;;
    clang ) MPICC=$(which mpiicc) ; toolset=clang ;;
    *     ) echo "Unknown compiler = $compName, ABORT!"; exit 1 ;;
esac

cp $BoostRoot/tools/build/example/user-config.jam ./user-config.jam
cat >> ./user-config.jam << EOF

# ------------------
# MPI configuration.
# ------------------
using mpi : $MPICC ;
EOF

rm -f $HOME/user-config.jam
[[ -z $mpi ]] && rm -f ./user-config.jam || mv -f ./user-config.jam $HOME

# boost python libraries may not build without these values exported
pyInc=`python3-config --includes | cut -d' ' -f1 | cut -c3-`
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$pyInc
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:$pyInc

./bootstrap.sh --with-toolset=$toolset --with-python=`which python3`
./b2 install $debug --prefix=$BoostBuild

export PATH="$BoostBuild/bin:$PATH"

cd $BoostRoot
b2 $debug --build-dir=$build_boost address-model=64 toolset=$toolset stage

$SUDO mkdir -p $prefix $prefix/include
$SUDO cp -R boost $prefix/include
$SUDO mv stage/lib $prefix

rm -f $HOME/user-config.jam

# ecFlow component
cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}/$software

ecflowVersion=$(awk '/^project/ && /ecflow/ && /VERSION/ {for (I=1;I<=NF;I++) if ($I == "VERSION") {print $(I+1)};}' CMakeLists.txt)
pythonVersion=$(`which python3` -c 'import sys;print(sys.version_info[0],".",sys.version_info[1],sep="")')

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

cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_BUILD_TYPE=Release \
    -DBOOST_ROOT=$prefix -DENABLE_STATIC_BOOST_LIBS=OFF $QT_LOC ..
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
VERBOSE=$MAKE_VERBOSE $SUDO make install

rm -rf $prefix/lib/cmake
rm -rf $prefix/include/boost

# generate modulefile from template
$MODULES && update_modules compiler $name $version $pythonVersion \
         || echo $name $ecflowVersion >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
