#!/bin/sh

set -ex

name=$1
version=$2

software=$name-$version

mm=$(echo $version | cut -d. -f-2)
patch=$(echo $version | cut -d. -f3)

case "$name" in
    openmpi ) url="https://download.open-mpi.org/release/open-mpi/v$mm/openmpi-$version.tar.gz" ;;
    mpich   ) url="http://www.mpich.org/static/downloads/$version/mpich-$version.tar.gz" ;;
    *       ) echo "Invalid option for MPI = $name, ABORT!"; exit 1 ;;
esac

compiler=${COMPILER:-"gnu-7.3.0"}

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module load szip
module list
set -x

export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="-fPIC"

cd ${PKGDIR:-"../pkg"}
[[ -d $software ]] && cd $software || ( wget $url; tar -xf $software.tar.gz; cd $software )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$name/$version"

case "$name" in
    openmpi ) extra_conf="" ;;
    mpich   ) extra_conf="--enable-fortran --enable-cxx" ;;
    *       ) echo "Invalid option for MPI = $software, ABORT!"; exit 1 ;;
esac

../configure --prefix=$prefix $extra_conf
make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
