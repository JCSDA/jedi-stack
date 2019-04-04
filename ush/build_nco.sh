#!/bin/sh

set -ex


name="nco"
version=$1

compiler=${COMPILER:-"gnu-7.3.0"}

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module load szip
module load hdf5
module load netcdf
module load udunits
module list
set -x

export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"

export F77=$FC
export FCFLAGS=$FFLAGS

export LDFLAGS="-L$NETCDF_ROOT/lib -L$HDF5_ROOT/lib -L$SZIP_ROOT/lib"

gitURL="https://github.com/nco/nco.git"

cd ${PKGDIR:-"../pkg"}

software=$name-$version
[[ -d $software ]] || ( git clone -b $version $gitURL $software )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$name/$version"
[[ -d $prefix ]] && ( echo "$prefix exists, ABORT!"; exit 1 )

../configure --prefix=$prefix --enable-doc=no

make -j${NTHREADS:-4}
[[ "$CHECK" = "YES" ]] && make check
make install

exit 0
