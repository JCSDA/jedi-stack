#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

set -ex

name="tau2"
version="2.28.1"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=tau2  
[[ -d $software ]] || git clone https://github.com/UO-OACISS/tau2
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')
mpi=$(echo $JEDI_MPI | sed 's/\//-/g')

# manage package dependencies here
if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    module load jedi-$JEDI_MPI 
    module try_load ncarcompilers
    module try_load pdtoolkit
    module try_load zlib
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix=${TAU_ROOT:-"/usr/local/$name/$version"}
fi

export CC=${MPI_CC:-"mpicc"}
export CXX=${MPI_CXX:-"mpiicpc"}
if [[ $MPI_FC = "mpifort" ]]; then
    export FC="mpif90"
else
    export FC=${MPI_FC:-"mpif90"}
fi

export PDTOOLKIT_ROOT=$PDT_ROOT

[[ -d $PDTOOLKIT_ROOT ]] || ( echo "$software requires pdtoolkit, ABORT!"; exit 1 )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build

$SUDO ./configure -prefix=$prefix -c++=$CXX -cc=$CC -fortran=$FC -mpi -ompt -bfd=download \
                  -dwarf=download -unwind=download -iowrapper -pdt=$PDTOOLKIT_ROOT 

# Note - if this doesn't work you might have to run the entire script as root
$SUDO make install

# generate modulefile from template
$MODULES && update_modules mpi $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
