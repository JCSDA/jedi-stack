#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

set -ex

name="pnetcdf"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')
mpi=$(echo $JEDI_MPI | sed 's/\//-/g')

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
url="https://parallel-netcdf.github.io/Release/$software.tar.gz"
[[ -d $software ]] || ( rm -f $software.tar.gz; $WGET $url; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    module load jedi-$JEDI_MPI 
    module try_load ncarcompilers
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix=${PNETCDF_ROOT:-"/usr/local"}
fi

[[ -n $FC && `$FC --version` =~ GNU\ Fortran.*\ 1[0-9]\.[0-9]+ ]] && FC_GFORTRAN_10=1

export FC=$MPI_FC
export CC=$MPI_CC
export F9X=$FC

export FFLAGS+=" -fPIC -w"
# for GNU Fortran 10; see: https://github.com/Unidata/netcdf-fortran/issues/212#issuecomment-638457375
[[ -n $FC_GFORTRAN_10 ]] && export FFLAGS+=" -fallow-argument-mismatch"
export CFLAGS+=" -fPIC"
export FCFLAGS="$FFLAGS"

[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix --enable-shared --enable-static --disable-cxx

make V=$MAKE_VERBOSE -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
$MODULES && update_modules mpi $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
