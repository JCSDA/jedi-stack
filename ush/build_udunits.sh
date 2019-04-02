#!/bin/sh

set -ex

name="udunits"
version=$1

compiler=${COMPILER:-"gnu-7.3.0"}

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module list
set -x

export FCFLAGS="-fPIC"
export CFLAGS="-fPIC"

gitURL="https://github.com/Unidata/UDUNITS-2.git"

cd ${PKGDIR:-"../pkg"}

software=$name-$version
[[ -d $software ]] || ( git clone -b v$version $gitURL $software )
[[ -d $software ]] && cd i$software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$name/$version"
[[ -d $prefix ]] && ( echo "$prefix exists, ABORT!"; exit 1 )

../configure --prefix=$prefix

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
