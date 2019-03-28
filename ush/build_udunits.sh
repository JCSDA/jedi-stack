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

gitUnidata="https://github.com/Unidata"

cd ${PKGDIR:-"../pkg"}
[[ -d udunits ]] && cd udunits || (git clone -b "v$version" $gitUnidata/UDUNITS-2.git udunits && cd udunits || (echo "git clone failed, ABORT!"; exit 1))
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$name/$version"

../configure --prefix=$prefix

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
