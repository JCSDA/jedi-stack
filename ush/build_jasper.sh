#!/bin/sh

set -ex

software="jasper-1.900.1"

name=$(echo $software | cut -d"-" -f1)
version=$(echo $software | cut -d"-" -f2)

compiler=${COMPILER:-"gnu-7.3.0"}

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module list
set -x

export F77=gfortran
export CC=gcc
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"

mkdir -p ../build ; cd ../build
rm -rf $software ; unzip ../pkg/$software.zip ; cd $software

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$name/$version"

./configure --prefix=$prefix

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
