#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

# Compiler/MPI combination
#export JEDI_COMPILER="gnu/9.1.0"
#export JEDI_MPI="openmpi/4.0.3"
export JEDI_COMPILER="intel/2021.2"
export JEDI_MPI="impi/2021.2"
export JEDI_PYTHON="conda/latest"

# This tells jedi-stack how you want to build the compiler and mpi modules
# valid options include:
# native-module: load a pre-existing module (common for HPC systems)
# native-pkg: use pre-installed executables located in /usr/bin or /usr/local/bin,
#             as installed by package managers like apt-get or homebrew.
#             This is a common option for, e.g., gcc/g++/gfortran
# from-source: This is to build from source, not supported for Python
export COMPILER_BUILD="native-module"
export MPI_BUILD="native-module"
export PYTHON_BUILD="native-module"

# Build options
export PREFIX=${JEDI_OPT:-/glade/work/jedipara/cheyenne/opt/modules}
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=buildscripts/log
export OVERWRITE=Y
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=Y
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=F
export STACK_EXIT_ON_FAIL=T
export WGET="wget -nv"

# Global compiler flags
export FFLAGS=""
export CFLAGS=""
export CXXFLAGS="-gxx-name=/glade/u/apps/ch/opt/gnu/9.1.0/bin/g++ -Wl,-rpath,/glade/u/apps/ch/opt/gnu/9.1.0/lib64"
export LDFLAGS="-gxx-name=/glade/u/apps/ch/opt/gnu/9.1.0/bin/g++ -Wl,-rpath,/glade/u/apps/ch/opt/gnu/9.1.0/lib64"

# The nasty stuff ... get rid of the CISL compiler modules that interfere with our stack
module purge
module unuse /glade/u/apps/ch/modulefiles/default/compilers
module use   /glade/p/ral/jntp/GMTB/tools/compiler_mpi_modules/compilers
export MODULEPATH_ROOT=/glade/p/ral/jntp/GMTB/tools/compiler_mpi_modules
