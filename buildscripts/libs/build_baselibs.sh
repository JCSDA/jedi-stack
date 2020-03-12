#!/bin/bash

set -ex

name="baselibs"
version=$1

# Hyphenated versions used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')
mpi=$(echo $JEDI_MPI | sed 's/\//-/g')

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    module load jedi-$JEDI_MPI
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
    if [[ -d $prefix ]]; then
	[[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${BASELIBS_ROOT:-"/usr/local"}
fi

export FC=$MPI_FC
export CC=$MPI_CC
export CXX=$MPI_CXX

gitURL="https://developer.nasa.gov/GMAO/ESMA-Baselibs.git"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
[[ -d $software ]] || ( git clone -b $version $gitURL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

compilerD=$(echo $compiler | sed 's/-/_/g')
mpiD=$(echo $mpi | sed 's/-/_/g')
mpiN=$(echo $mpi | sed 's/-/\//g')

case "$mpiN" in
    openmpi ) ESMF_COMM="openmpi" ;;
    mpich   ) ESMF_COMM="mpich2" ;;
    *       ) echo "Invalid option for MPI = $name, ABORT!"; exit 1 ;;
esac

$SUDO make install F90=$FC ESMF_COMM=$ESMF_COMM CONFIG="${compilerD}-${mpiD}" prefix=$prefix

# generate modulefile from template
$MODULES && update_modules mpi $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log			   
