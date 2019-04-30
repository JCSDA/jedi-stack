#!/bin/bash

set -ex

name="esmf"
version=$1

software=${name}_$version

# Hyphenated versions used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')
mpi=$(echo $MPI | sed 's/\//-/g')

[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

set +x
source $MODULESHOME/init/bash
module load jedi-$COMPILER
module load szip
module load jedi-$MPI
module load hdf5
module load netcdf
module load udunits
module list
set -x

if [[ ! -z $mpi ]]; then
    export FC=mpif90
    export CC=mpicc
    export CXX=mpicxx
fi

export F9X=$FC
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="$FFLAGS"

if [[ ! -z $mpi ]]; then

    if [[ $(echo $mpi | cut -d- -f1) = "openmpi" ]]; then
        export ESMF_COMM="openmpi"
    elif [[ $(echo $mpi | cut -d- -f1) = "mpich" ]]; then
        export ESMF_COMM="mpich3"
    fi

fi

export ESMF_COMPILER="gfortran"
export ESMF_NETCDF="nc-config"

gitURL="https://git.code.sf.net/p/esmf/esmf.git"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software="ESMF_$version"
[[ -d $software ]] || ( git clone -b $software $gitURL $software )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
export ESMF_DIR=$PWD

prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                      || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
fi
export ESMF_INSTALL_PREFIX=$prefix

make -j${NTHREADS:-4}
$SUDO make install
[[ $MAKE_CHECK =~ [yYtT] ]] && make installcheck

# generate modulefile from template
cd $JEDI_STACK_ROOT/buildscripts
[[ -z $mpi ]] && libs/update_modules.sh compiler $name $version \
	      || libs/update_modules.sh mpi $name $version

exit 0
