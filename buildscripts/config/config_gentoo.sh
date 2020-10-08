#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.


# Compiler/MPI combination
export JEDI_COMPILER=${JEDI_COMPILER:-"intel/20.0"}
export JEDI_MPI=${JEDI_MPI:-"impi/20.0"}
export JEDI_STACK_DISABLE_COMPILER_VERSION_CHECK=1

# This tells jedi-stack how you want to build the compiler and mpi modules
# valid options include:
# native-module: load a pre-existing module (common for HPC systems)
# native-pkg: use pre-installed executables located in /usr/bin or /usr/local/bin,
#             as installed by package managers like apt-get or homebrew.
#             This is a common option for, e.g., gcc/g++/gfortran
# from-source: This is to build from source
export COMPILER_BUILD="native-module"
if [[ "$JEDI_MPI" == "impi"* ]]; then
    export MPI_BUILD="native-module"
else
    export MPI_BUILD="from-source"
fi

#Cross-platform get number of processors
if [ -z $NUM_PROCS ]; then
    case $(uname -s) in
        Linux*) NUM_PROCS=$(grep -c ^processor /proc/cpuinfo);;
        Darwin*) NUM_PROCS=$(sysctl -n hw.logicalcpu);;
        *) NUM_PROCS=1
    esac
fi

# For nccmp. This magically fixes the make install command.
export MKDIR_P="mkdir -p"

# Build options
export PREFIX=${JEDI_OPT}
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=buildscripts/log
export OVERWRITE=Y
export NTHREADS=${NUM_PROCS}
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

#Provided system package roots
export SZIP_ROOT=/usr
export ZLIB_ROOT=/usr
export PNG_ROOT=/usr
export JPEG_ROOT=/usr

# Minimal JEDI Stack
export      STACK_BUILD_CMAKE=N
export       STACK_BUILD_SZIP=N
export    STACK_BUILD_UDUNITS=N
export       STACK_BUILD_ZLIB=N
export     STACK_BUILD_LAPACK=N
export STACK_BUILD_BOOST_HDRS=N
export     STACK_BUILD_EIGEN3=N
export    STACK_BUILD_BUFRLIB=Y
export       STACK_BUILD_HDF5=Y
export    STACK_BUILD_PNETCDF=Y
export     STACK_BUILD_NETCDF=Y
export      STACK_BUILD_NCCMP=N
export        STACK_BUILD_NCO=N
export    STACK_BUILD_ECBUILD=N
export      STACK_BUILD_ECKIT=Y
export      STACK_BUILD_FCKIT=N
export      STACK_BUILD_ATLAS=N
export        STACK_BUILD_ODC=Y

# Optional Additions
export           STACK_BUILD_PIO=Y
export          STACK_BUILD_GPTL=N
export        STACK_BUILD_PYJEDI=N
export      STACK_BUILD_PYBIND11=N
export      STACK_BUILD_GSL_LITE=N
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
export          STACK_BUILD_CGAL=N
export          STACK_BUILD_GEOS=Y
export        STACK_BUILD_SQLITE=Y
export          STACK_BUILD_PROJ=Y
export          STACK_BUILD_JSON=N
export STACK_BUILD_JSON_SCHEMA_VALIDATOR=N
