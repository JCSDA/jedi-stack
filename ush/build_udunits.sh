#!/bin/sh

set -ex


software=$1
dir_software=${PKGDIR:-"../pkg"}/$software

name=$(echo $software | cut -d"-" -f1)
version=$(echo $software | cut -d"-" -f2)

compiler=${COMPILER:-"gnu-7.3.0"}

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module list
set -x

export FCFLAGS="-fPIC"
export CFLAGS="-fPIC"

[[ -d $dir_software ]] && cd $dir_software || (echo "$dir_software does not exist, ABORT!"; exit 1)

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$name/$version"

./configure --prefix=$prefix

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
