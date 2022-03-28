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

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name
[[ -d $software ]] || git clone https://github.com/$source/$software.git
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
git fetch --tags
git checkout $version
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    module try_load cmake git python qt
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

host=$(uname -s)
if [[ "$host" == "Darwin" ]]; then
    [[ -d `brew --cellar boost` ]] && boost_root=`brew --prefix boost`
    [[ -z $boost_root ]] || echo "Using brew-installed boost headers and libraries"

    [[ -d `brew --cellar openssl` ]] && openssl_root=`brew --prefix openssl`
    if [ -z $openssl_root ]; then
        echo "OpenSSL must be installed for ecFlow, ABORT!"
        exit 1
    fi

    [[ -d `brew --cellar qt` ]] && qt_root=`brew --prefix qt`
    if [ ! -z $qt_root ]; then
        QT="-DCMAKE_PREFIX_PATH=$qt_root"
    else
        echo "Qt must be installed for ecFlow UI, ABORT!"
        exit 1
    fi
fi

# boost component; build if not otherwise present
if [ -z $boost_root ]; then
    echo "Building boost from source"
    boost_software=$boost\_$(echo $boost_version | sed 's/\./_/g')
    url="https://boostorg.jfrog.io/artifactory/main/release/$boost_version/source/$boost_software.tar.gz"
    [[ -d $boost_software ]] || ( rm -f $boost_software.tar.gz; $WGET $url; tar -xf $boost_software.tar.gz )
    [[ -d $boost_software ]] && cd $boost_software || ( echo "$boost_software does not exist, ABORT!"; exit 1 )

    debug="--debug-configuration"

    BoostRoot=$(pwd)
    BoostBuild=$BoostRoot/BoostBuild
    build_boost=$BoostRoot/build_boost
    [[ -d $BoostBuild ]] && rm -rf $BoostBuild
    [[ -d $build_boost ]] && rm -rf $build_boost
    cd $BoostRoot/tools/build

    compName=$(echo $compiler | cut -d- -f1)
    case "$compName" in
        gnu   ) toolset=gcc ;;
        intel ) toolset=intel ;;
        clang ) toolset=clang ;;
        *     ) echo "Unknown compiler = $compName, ABORT!"; exit 1 ;;
    esac

    ./bootstrap.sh --with-toolset=$toolset --with-python=`which python3`
    ./b2 install $debug --prefix=$BoostBuild

    export PATH="$BoostBuild/bin:$PATH"

    cd $BoostRoot
    b2 $debug --build-dir=$build_boost address-model=64 toolset=$toolset stage

    $SUDO mkdir -p $prefix $prefix/include
    $SUDO cp -R boost $prefix/include
    $SUDO mv stage/lib $prefix

    boost_root=$prefix
fi

# ecFlow component
cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}/$software

ecflowVersion=$(awk '/^project/ && /ecflow/ && /VERSION/ {for (I=1;I<=NF;I++) if ($I == "VERSION") {print $(I+1)};}' CMakeLists.txt)
pythonVersion=$(`which python3` -c 'import sys;print(sys.version_info[0],".",sys.version_info[1],sep="")')

export FC=$SERIAL_FC
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX

[[ -d build ]] && $SUDO rm -rf build
mkdir -p build && cd build

cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_BUILD_TYPE=Release \
    -DBOOST_ROOT=$boost_root -DENABLE_STATIC_BOOST_LIBS=OFF \
    -DOPENSSL_ROOT_DIR=$openssl_root $QT ..
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
VERBOSE=$MAKE_VERBOSE $SUDO make install

[[ -d $prefix/lib/cmake ]] && $SUDO rm -rf $prefix/lib/cmake
[[ -d $prefix/include/boost ]] && $SUDO rm -rf $prefix/include/boost

# generate modulefile from template
$MODULES && update_modules compiler $name $version $pythonVersion \
         || echo $name $ecflowVersion >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
