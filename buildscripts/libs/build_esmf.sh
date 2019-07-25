#!/bin/bash

set -ex

name="esmf"
version=$1

software=${name}_$version

# Hyphenated versions used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')
mpi=$(echo $MPI | sed 's/\//-/g')

[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

if $MODULES; then
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

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
    if [[ -d $prefix ]]; then
	[[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
            || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix="/usr/local"
fi

if [[ ! -z $mpi ]]; then
    export FC=$MPI_FC
    export CC=$MPI_CC
    export CXX=$MPI_CXX
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
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
export ESMF_DIR=$PWD

export ESMF_INSTALL_PREFIX=$prefix

make -j${NTHREADS:-4}
$SUDO make install
[[ $MAKE_CHECK =~ [yYtT] ]] && make installcheck

# generate modulefile from template
[[ -z $mpi ]] && modpath=mpi || modpath=compiler
$MODULES update_modules $modpath $name $c_version

exit 0
