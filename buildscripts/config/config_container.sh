#!/bin/bash

# Compiler/MPI combination
export COMPILER="gnu/7.3.0"
export MPI="openmpi/3.1.2"
#export MPI="mpich/3.2.1"

# Build options
export PREFIX=/opt/modules 
export USE_SUDO=Y
export PKGDIR=pkg
export LOGDIR=buildscripts/log
export OVERWRITE=N
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=N

# Minimal JEDI Stack
export       STACK_BUILD_SZIP=Y
export    STACK_BUILD_UDUNITS=Y
export       STACK_BUILD_ZLIB=Y
export     STACK_BUILD_LAPACK=Y
export    STACK_BOOST_HEADERS=Y
export     STACK_BUILD_EIGEN3=Y
export       STACK_BUILD_HDF5=Y
export    STACK_BUILD_PNETCDF=Y
export     STACK_BUILD_NETCDF=Y
export      STACK_BUILD_NCCMP=Y
export    STACK_BUILD_ECBUILD=Y
export      STACK_BUILD_ECKIT=Y
export      STACK_BUILD_FCKIT=Y
export        STACK_BUILD_ODB=Y

# Optional Additions
export        STACK_BUILD_JASPER=N
export     STACK_BUILD_ARMADILLO=N
export          STACK_BOOST_FULL=N
export          STACK_BUILD_ESMF=N
export      STACK_BUILD_BASELIBS=N

