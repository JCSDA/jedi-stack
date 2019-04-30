#!/bin/bash

set -ex

name="nccmp"
version=$1

software=$name-$version

# Hyphenated version used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')
mpi=$(echo $MPI | sed 's/\//-/g')

[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

set +x
source $MODULESHOME/init/bash
module load jedi-$COMPILER
module load jedi-$MPI
module load szip
module load hdf5
module load netcdf
module list
set -x

export CFLAGS="-fPIC"
export LDFLAGS="-L$NETCDF_ROOT/lib -L$HDF5_ROOT/lib -L$SZIP_ROOT/lib"

url="https://sourceforge.net/projects/nccmp/files/${software}.tar.gz"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

# Enable header pad comparison, if netcdf-c src directory exists!
[[ -d "netcdf-c-$NETCDF_VERSION" ]] && extra_confs="--with-netcdf=$PWD/netcdf-c-$NETCDF_VERSION" || extra_confs=""

[[ -d $software ]] || ( wget $url; tar -xf $software.tar.gz )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                      || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
fi

../configure --prefix=$prefix $extra_confs

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
cd $JEDI_STACK_ROOT/buildscripts
libs/update_modules.sh mpi $name $version

exit 0
