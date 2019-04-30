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
export OVERWRITE=Y
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=Y

# Minimal JEDI Stack
export       STACK_BUILD_SZIP=N
export    STACK_BUILD_UDUNITS=N
export       STACK_BUILD_ZLIB=N
export     STACK_BUILD_LAPACK=N
export    STACK_BOOST_HEADERS=N
export     STACK_BUILD_EIGEN3=N
export       STACK_BUILD_HDF5=N
export    STACK_BUILD_PNETCDF=N
export     STACK_BUILD_NETCDF=N
export      STACK_BUILD_NCCMP=Y
export    STACK_BUILD_ECBUILD=N
export      STACK_BUILD_ECKIT=N
export      STACK_BUILD_FCKIT=N
export        STACK_BUILD_ODB=N

# Optional Additions
export        STACK_BUILD_JASPER=N
export     STACK_BUILD_ARMADILLO=N
export          STACK_BOOST_FULL=N
export          STACK_BUILD_ESMF=N
export      STACK_BUILD_BASELIBS=N

