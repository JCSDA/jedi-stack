#!/bin/bash
# © Copyright 2020 UCAR
# © Copyright 2020 NOAA/NWS/NCEP/EMC
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.


set -ex

name="fms"
source=$1
version=$2

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')
mpi=$(echo $JEDI_MPI | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load jedi-$JEDI_COMPILER
  module load jedi-$JEDI_MPI
  module load netcdf
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$source-$version"
  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi

else
    prefix=${FMS_ROOT:-"/usr/local"}
fi

export FC=$MPI_FC
export CC=$MPI_CC

export FFLAGS+=" -fPIC -w"
export CFLAGS+=" -fPIC -w"
export FCFLAGS="$FFLAGS"

gitURL="https://github.com/$source/fms"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
[[ -d $software ]] || ( git clone -b $version $gitURL $software)
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

cmake .. \
      -DCMAKE_INSTALL_PREFIX=$prefix \
      -D32BIT=ON -D64BIT=ON \
      -DGFS_PHYS=ON \
      -DLARGEFILE=ON
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
$MODULES && update_modules mpi $name $source-$version \
         || echo $name $source-$version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
