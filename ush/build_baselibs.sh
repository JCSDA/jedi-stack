#!/bin/sh

set -ex

name="baselibs"
version=$1

compiler=${COMPILER:-"gnu-7.3.0"}
mpi=${MPI:-"openmpi-3.1.2"}

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module load $(echo $mpi | sed 's/-/\//g')
module list
set -x

gitURL="https://developer.nasa.gov/GMAO/ESMA-Baselibs.git"

cd ${PKGDIR:-"../pkg"}

software=$name-$version
[[ -d $software ]] || ( git clone -b $version $gitURL $software )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$mpi/$name/$version"
[[ -d $prefix ]] && ( echo "$prefix exists, ABORT!"; exit 1 )

compilerD=$(echo $compiler | sed 's/-/_/g')
mpiD=$(echo $mpi | sed 's/-/_/g')
mpiN=$(echo $mpi | sed 's/-/\//g')

case "$mpiN" in
    openmpi ) ESMF_COMM="openmpi" ;;
    mpich   ) ESMF_COMM="mpich2" ;;
    *       ) echo "Invalid option for MPI = $name, ABORT!"; exit 1 ;;
esac

make install F90=$FC ESMF_COMM=$ESMF_COMM CONFIG="${compilerD}-${mpiD}" prefix=$prefix

exit 0
