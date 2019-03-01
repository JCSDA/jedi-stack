#!/bin/sh

set -ex

software=udunits-2.2.26

name=$(echo $software | cut -d"-" -f1)
version=$(echo $software | cut -d"-" -f2)

compiler=gnu-7.3.0

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module list
set -x

export CFLAGS="-fPIC"
export FCFLAGS="-fPIC"

mkdir -p ../build ; cd ../build
rm -rf $software; tar -xzf ../pkg/$software.tar.gz; cd $software

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$name/$version"

./configure --prefix=$prefix
make -j${NTHREADS:-4}
[[ -z $CHECK ]] && make check
make install

exit 0
