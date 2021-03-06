#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.


# Compiler/MPI combination
export JEDI_COMPILER="intel/2021.1"
export JEDI_MPI="impi/2021.1"
export PATH=/usr/local/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=/usr/local/lib:$LIBRARY_PATH
export CPATH=/usr/local/include:$CPATH

# This tells jedi-stack how you want to build the compiler and mpi modules
# valid options include:
# native-module: load a pre-existing module (common for HPC systems)
# native-pkg: use pre-installed executables located in /usr/bin or /usr/local/bin,
#             as installed by package managers like apt-get or hombrewo.
#             This is a common option for, e.g., gcc/g++/gfortran
# from-source: This is to build from source
export COMPILER_BUILD="native-pkg"
export MPI_BUILD="native-pkg"

# Build options
export PREFIX=/usr/local
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=buildscripts/log
export OVERWRITE=N
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=Y
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=F
export STACK_EXIT_ON_FAIL=T
export WGET="wget -nv"
#Global compiler flags
export FFLAGS=""
export CFLAGS=""
export CXXFLAGS=""
export LDFLAGS=""

# Minimal JEDI Stack
export      STACK_BUILD_CMAKE=Y
export     STACK_BUILD_GITLFS=N
export       STACK_BUILD_SZIP=Y
export    STACK_BUILD_UDUNITS=Y
export       STACK_BUILD_ZLIB=Y
export     STACK_BUILD_LAPACK=N
export STACK_BUILD_BOOST_HDRS=Y
export     STACK_BUILD_EIGEN3=Y
export       STACK_BUILD_BUFR=Y
export       STACK_BUILD_HDF5=Y
export    STACK_BUILD_PNETCDF=Y
export     STACK_BUILD_NETCDF=Y
export      STACK_BUILD_NCCMP=Y
export        STACK_BUILD_NCO=N
export    STACK_BUILD_ECBUILD=Y
export      STACK_BUILD_ECKIT=Y
export      STACK_BUILD_FCKIT=Y
export      STACK_BUILD_ATLAS=Y
export   STACK_BUILD_PYBIND11=Y
export   STACK_BUILD_GSL_LITE=Y

# Optional Additions
export           STACK_BUILD_ODC=Y
export           STACK_BUILD_PIO=Y
export          STACK_BUILD_GPTL=N
export        STACK_BUILD_PYJEDI=Y
export      STACK_BUILD_NCEPLIBS=N
export          STACK_BUILD_JPEG=N
export           STACK_BUILD_PNG=N
export        STACK_BUILD_JASPER=N
export     STACK_BUILD_ARMADILLO=N
export        STACK_BUILD_XERCES=N
export        STACK_BUILD_TKDIFF=N
export    STACK_BUILD_BOOST_FULL=N
export          STACK_BUILD_ESMF=N
export      STACK_BUILD_BASELIBS=N
export     STACK_BUILD_PDTOOLKIT=N
export          STACK_BUILD_TAU2=N
export          STACK_BUILD_CGAL=Y
export          STACK_BUILD_JSON=Y
export STACK_BUILD_JSON_SCHEMA_VALIDATOR=Y
export           STACK_BUILD_FMS=N
