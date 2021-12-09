#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.


# Compiler/MPI combination
export JEDI_COMPILER="intel/2020.2"
export JEDI_MPI="impi/2020.2"
export JEDI_PYTHON="python/3.9.2"

# This tells jedi-stack how you want to build the compiler and mpi modules
# valid options include:
# native-module: load a pre-existing module (common for HPC systems)
# native-pkg: use pre-installed executables located in /usr/bin or /usr/local/bin,
#             as installed by package managers like apt-get or homebrew.
#             This is a common option for, e.g., gcc/g++/gfortran
# from-source: This is to build from source, not supported for Python"
export COMPILER_BUILD="native-module"
export MPI_BUILD="native-module"
export PYTHON_BUILD="native-module"

# Build options
export PREFIX=${JEDI_OPT:-/work/noaa/da/jedipara/opt/modules}
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=buildscripts/log
export OVERWRITE=Y
export NTHREADS=8
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=F
export STACK_EXIT_ON_FAIL=T
export WGET="wget -nv"

#Global compiler flags
export FFLAGS=""
export CFLAGS=""
# These don't work for some of the packages (when the OS GNU compiler is used)
#export CXXFLAGS="-std=c++14"
#export LDFLAGS="-std=c++14"
