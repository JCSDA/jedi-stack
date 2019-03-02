#!/bin/sh

set -ex

compilerName=$(echo $COMPILER | cut -d- -f1)
compilerVersion=$(echo $COMPILER | cut -d- -f2)
mpiName=$(echo $MPI | cut -d- -f1)
mpiVersion=$(echo $MPI | cut -d- -f2)

cp -R ../modulefiles $PREFIX

cd $PREFIX/modulefiles/compiler

mv compilerName $compilerName       ; cd $compilerName
mv compilerVersion $compilerVersion ; cd $compilerVersion

cd $PREFIX/modulefiles/mpi

mv compilerName $compilerName       ; cd $compilerName
mv compilerVersion $compilerVersion ; cd $compilerVersion
mv mpiName $mpiName       ; cd $mpiName
mv mpiVersion $mpiVersion ; cd $mpiName

exit
