#!/bin/sh

set -ex

name="baselibs"
version=$1

compiler=${COMPILER:-"gnu-7.3.0"}
mpi=${MPI:-"openmpi-3.1.2"}

set +x
source $MODULESHOME/init/sh
module load $(echo $compiler | sed 's/-/\//g')
module load szip
module load $(echo $mpi | sed 's/-/\//g')
module list
set -x

gitNASA="https://developer.nasa.gov/"

[[ -d $name ]] && cd $name || (git clone -b "$version" $gitNASA/GMAO/ESMA-Baselibs.git $name && cd $name || (echo "git clone failed, ABORT!"; exit 1))

prefix="${PREFIX:-"$HOME/opt"}/$compiler/$mpi/$name/$version"

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
