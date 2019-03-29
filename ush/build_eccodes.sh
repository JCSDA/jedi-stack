#!/bin/sh

set -ex

name="eccodes"
version=$1

compiler=${COMPILER:-"gnu-7.3.0"}

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module load szip
module load hdf5
module load netcdf
module list
set -x

export FCFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"

gitECMWF="https://github.com/ecmwf/"

cd ${PKGDIR:-"../pkg"}
[[ -d $name ]] && cd $name || (git clone -b "$version" $gitECMWF/$name.git && cd $name || (echo "git clone failed, ABORT!"; exit 1))
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$name/$version"

cmake -DCMAKE_INSTALL_PREFIX=$prefix -DENABLE_NETCDF=ON -DENABLE_FORTRAN=ON ..

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && ctest
make install

exit 0
