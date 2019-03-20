#!/bin/sh

set -x

name="boost"
version=$1

compiler=${COMPILER:-"gnu-7.3.0"}
mpi=${MPI:-""}

debug="--debug-configuration"

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module load $(echo $mpi | sed 's/-/\//g')
module list
set -x

cd ${PKGDIR:-"../pkg"}
[[ -d boost ]] && cd boost || (git clone https://github.com/boostorg/boost.git && cd boost || (echo "git clone failed, ABORT!"; exit 1))
git checkout tags/boost-$version || (echo "git checkout failed, ABORT!"; exit 1)

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

./bootstrap.sh --with-toolset=$toolset
./b2 install $debug --prefix=$BoostBuild

export PATH="$BoostBuild/bin:$PATH"

cd $BoostRoot
b2 $debug --build-dir=$build_boost address-model=64 toolset=$toolset stage

mkdir -p $prefix $prefix/include
mv stage/lib $prefix
cp -R boost $prefix/include

rm -f $HOME/user-config.jam

exit 0
