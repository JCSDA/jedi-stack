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
export HWLOC_ROOT=/usr

## Gentoo provides all non-Fortran non-ECMWF packages on the base system
## Don't add any new dependencies to this file

# Packages that produce Fortran modules
export    STACK_BUILD_BUFRLIB=Y
export       STACK_BUILD_HDF5=Y
export    STACK_BUILD_PNETCDF=Y
export     STACK_BUILD_NETCDF=Y
export        STACK_BUILD_PIO=Y

# ECMWF dependencies
export      STACK_BUILD_ECKIT=Y
export      STACK_BUILD_FCKIT=Y
export      STACK_BUILD_ATLAS=Y
