#!/bin/bash

# Compiler/MPI combination
#export COMPILER="gnu/7.4.0"
#export MPI="openmpi/3.1.2"
#export MPI="mpich/3.2.1"

#export COMPILER="intel/17.0.1"
#export MPI="impi/17.0.1"

export COMPILER="clang/6.0.1"
export MPI="openmpi/3.1.2"

# This tells jedi-stack how you want to build the compiler and mpi modules
# valid options include:
# native-module: load a pre-existing module (common for HPC systems)
# native-pkg: use pre-installed executables located in /usr/bin or /usr/local/bin,
#             as installed by package managers like apt-get or hombrewo.
#             This is a common option for, e.g., gcc/g++/gfortrant
# from-source: This is to build from source
export COMPILER_BUILD="native-pkg"
export MPI_BUILD="from-source"

# Build options
export PREFIX=/opt/modules 
export USE_SUDO=Y
export PKGDIR=pkg
export LOGDIR=buildscripts/log
export OVERWRITE=Y
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=Y
export   MAKE_CLEAN=N

# Minimal JEDI Stack
export      STACK_BUILD_CMAKE=N
export       STACK_BUILD_SZIP=N
export    STACK_BUILD_UDUNITS=N
export       STACK_BUILD_ZLIB=N
export     STACK_BUILD_LAPACK=N
export    STACK_BOOST_HEADERS=N
export     STACK_BUILD_EIGEN3=N
export       STACK_BUILD_HDF5=N
export    STACK_BUILD_PNETCDF=N
export     STACK_BUILD_NETCDF=N
export      STACK_BUILD_NCCMP=N
export        STACK_BUILD_NCO=N
export    STACK_BUILD_ECBUILD=Y
export      STACK_BUILD_ECKIT=N
export      STACK_BUILD_FCKIT=N
export        STACK_BUILD_ODB=N

# Optional Additions
export           STACK_BUILD_PIO=N
export        STACK_BUILD_PYJEDI=N
export      STACK_BUILD_NCEPLIBS=N
export        STACK_BUILD_JASPER=N
export     STACK_BUILD_ARMADILLO=N
export        STACK_BUILD_XERCES=N
export        STACK_BUILD_TKDIFF=N
export          STACK_BOOST_FULL=N
export          STACK_BUILD_ESMF=N
export      STACK_BUILD_BASELIBS=N

