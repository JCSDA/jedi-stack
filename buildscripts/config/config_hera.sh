#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

# Compiler/MPI combination

# Intel (default)
export JEDI_COMPILER="intel/2020.2"
export JEDI_MPI="impi/2020.2"

# GNU / OpenMPI
#export JEDI_COMPILER="gnu/9.2.0"
#export JEDI_MPI="openmpi/3.1.4"

# This tells jedi-stack how you want to build the compiler and mpi modules
# valid options include:
# native-module: load a pre-existing module (common for HPC systems)
# native-pkg: use pre-installed executables located in /usr/bin or /usr/local/bin,
#             as installed by package managers like apt-get or hombrewo.
#             This is a common option for, e.g., gcc/g++/gfortrant
# from-source: This is to build from source
export JEDI_COMPILER_BUILD="native-module"
export MPI_BUILD="native-module"

# Build options
export PREFIX=${JEDI_OPT:-/scratch1/NCEPDEV/jcsda/jedipara/opt/modules}
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=buildscripts/log
export OVERWRITE=N
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=Y
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv"
#Global compiler flags
export FFLAGS=""
export CFLAGS=""

# C++-14 compliant compiler settings
# set / export these variables when building for Intel compiler(s)
if [[ "$JEDI_COMPILER" =~ .*"intel"* ]]; then
    export CXXFLAGS="-gxx-name=/apps/gnu/gcc-9.2.0/bin/g++ -Wl,-rpath,/apps/gnu/gcc-9.2.0/lib64"
    export LDFLAGS="-gxx-name=/apps/gnu/gcc-9.2.0/bin/g++ -Wl,-rpath,/apps/gnu/gcc-9.2.0/lib64"
fi
