#!/bin/bash

set -x

name="boost"
version=$1
[[ $# -lt 2 ]] && level="full" || level=$2

[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
software=$name\_$(echo $version | sed 's/\./_/g')
url="https://dl.bintray.com/boostorg/release/$version/source/$software.tar.gz"
[[ -d $software ]] || ( wget $url; tar -xf $software.tar.gz )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

########################################################################
# The headers-only option

if [[ $level = "headers-only" ]]; then

    prefix="${PREFIX:-"/opt/modules"}/core/$name/$version"
    $SUDO mkdir -p $prefix $prefix/include
    $SUDO cp -R boost $prefix/include

    # generate modulefile from template
    cd $JEDI_STACK_ROOT/buildscripts
    libs/update_modules.sh core "boost-headers" $version

    exit 0
fi

########################################################################

# Hyphenated version used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')
mpi=$(echo $MPI | sed 's/\//-/g')

debug="--debug-configuration"

set +x
source $MODULESHOME/init/bash
module load jedi-$COMPILER
module load jedi-$MPI
module list
set -x

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

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$mpi/$name/$version"
[[ -d $prefix ]] && ( echo "$prefix exists, ABORT!"; exit 1 )

./bootstrap.sh --with-toolset=$toolset
./b2 install $debug --prefix=$BoostBuild

export PATH="$BoostBuild/bin:$PATH"

cd $BoostRoot
b2 $debug --build-dir=$build_boost address-model=64 toolset=$toolset stage
$SUDO mkdir -p $prefix $prefix/include
$SUDO cp -R boost $prefix/include
$SUDO mv stage/lib $prefix

rm -f $HOME/user-config.jam

exit 0
