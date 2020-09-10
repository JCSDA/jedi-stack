#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.


# Compiler/MPI combination
export JEDI_COMPILER="clang/11.0.3"
export FC=gfortran #Set the initial fortran compiler to build MPI distribution
#export JEDI_MPI="openmpi/4.0.3"
export JEDI_MPI="mpich/3.3.2"
# This tells jedi-stack how you want to build the compiler and mpi modules
# valid options include:
# native-module: load a pre-existing module (common for HPC systems)
# native-pkg: use pre-installed executables located in /usr/bin or /usr/local/bin,
#             as installed by package managers like apt-get or hombrewo.
#             This is a common option for, e.g., gcc/g++/gfortrant
# from-source: This is to build from source
export COMPILER_BUILD="native-pkg"
export MPI_BUILD="from-source"

#Determine number of processors: valid on OSX
if [[ -x sysctl ]]; then
    NUM_PROCS=$(sysctl -n hw.logicalcpu)
else
    NUM_PROCS=4
fi

# Build options
export PREFIX=${JEDI_OPT:-/opt/modules}
export USE_SUDO=Y
export PKGDIR=pkg
export LOGDIR=buildscripts/log
export OVERWRITE=Y
export NTHREADS=$NUM_PROCS
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
