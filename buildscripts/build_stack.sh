#!/bin/bash
# The purpose of this script is to build the software stack using
# the compiler/MPI combination defined by setup_modules.sh
# 
# Arguments:
# configuration: Determines which libraries will be installed.  
#     Each supported option will have an associated config_<option>.sh 
#     file that will be used to 
#
# sample usage:
# build_stack.sh "container"
# build_stack.sh "custom"

# currently supported configuration options
supported_options=("container" "custom")

# root directory for the repository
export JEDI_STACK_ROOT=$PWD/..

set -x

# ===============================================================================
# configure build

if [[ $# -ne 1 ]]; then
    source config/config_custom.sh
else
    config_file="config/config_$1.sh"
    if [[ -e $config_file ]]; then
	source $config_file
    else
	set +x
	echo "ERROR: CONFIG FILE $config_file DOES NOT EXIST!"
	echo "Currently supported options: "
	echo ${supported_options[*]}
	exit 1
    fi
fi    

# This is for the log files
logdir=$JEDI_STACK_ROOT/$LOGDIR
mkdir -p $logdir

# ===============================================================================
# Minimal JEDI Stack

# start with a clean slate
set +x; module purge; set -x

#----------------------
# MPI-independent
# - should add a check at some point to see if they are already there.
# this can be done in each script individually
# it might warrant a --force flag to force rebuild when desired

[[ $STACK_BUILD_UDUNITS =~ [yYtT] ]] && \
    libs/build_udunits.sh "2.2.26" 2>&1 | tee "$logdir/udunits.log"

[[ $STACK_BUILD_ZLIB =~ [yYtT] ]] && \
    libs/build_zlib.sh "1.2.11" 2>&1 | tee "$logdir/zlib.log"

[[ $STACK_BUILD_SZIP =~ [yYtT] ]] && \
    libs/build_szip.sh "2.1.1" 2>&1 | tee "$logdir/szip.log"

[[ $STACK_BUILD_LAPACK =~ [yYtT] ]] && \
    libs/build_lapack.sh "3.7.0" 2>&1 | tee "$logdir/lapack.log"

[[ $STACK_BOOST_HEADERS  =~ [yYtT] ]] && \
    libs/build_boost.sh "1.68.0" "headers-only" 2>&1 | tee "$logdir/boost-headers.log"

[[ $STACK_BUILD_EIGEN3 =~ [yYtT] ]] && \
    libs/build_eigen.sh "3.3.5" 2>&1 | tee "$logdir/eigen3.log"

[[ $STACK_BUILD_ECBUILD =~ [yYtT] ]] && \
    libs/build_ecbuild.sh "2.9.0" 2>&1 | tee "$logdir/ecbuild.log"

#----------------------
# These must be rebuilt for each MPI implementation

[[ $STACK_BUILD_HDF5  =~ [yYtT] ]] && \
    libs/build_hdf5.sh "1.10.3" 2>&1 | tee "$logdir/hdf5.log"

[[ $STACK_BUILD_PNETCDF =~ [yYtT] ]] && \
    libs/build_pnetcdf.sh "1.11.1" 2>&1 | tee "$logdir/pnetcdf.log"

# enter versions for C, Fortran, anc CXX
[[ $STACK_BUILD_NETCDF =~ [yYtT] ]] && \
    libs/build_netcdf.sh "4.6.1" "4.4.4" "4.3.0" 2>&1 | tee "$logdir/netcdf.log"

[[ $STACK_BUILD_ECKIT =~ [yYtT] ]] && \
    libs/build_eckit.sh "0.23.0" 2>&1 | tee "$logdir/eckit.log"

# The first argument is the source, either "ecmwf" or "jcsda" (fork)
[[ $STACK_BUILD_FCKIT =~ [yYtT] ]] && \
    libs/build_fckit.sh "jcsda" "develop" 2>&1 | tee "$logdir/fckit.log"

#[[ $STACK_BUILD_ODB      =~ [yYtT] ]] && \
#    libs/build_odb.sh 2>&1 | tee "$logdir/odb.log"

# ===============================================================================
# Optional Extensions to the JEDI Stack

#----------------------
# MPI-independent
[[ $STACK_BUILD_NCCMP     =~ [yYtT] ]] && \
    libs/build_nccmp.sh "1.8.2.1" 2>&1 | tee "$logdir/nccmp.log"

[[ $STACK_BUILD_JASPER    =~ [yYtT] ]] && \
    libs/build_jasper.sh "1.900.1" 2>&1 | tee "$logdir/jasper.log"

[[ $STACK_BUILD_ARMADILLO =~ [yYtT] ]] && \
    libs/build_armadillo.sh "1.900.1" 2>&1 | tee "$logdir/armadillo.log"

[[ $STACK_BUILD_XERCES    =~ [yYtT] ]] && \
    libs/build_xerces.sh "3.1.4" 2>&1 | tee "$logdir/xerces.log"

#----------------------
# These must be rebuilt for each MPI implementation
[[ $STACK_BUILD_FFTW     =~ [yYtT] ]] && \
    libs/build_fftw.sh "3.3.8" 2>&1 | tee "$logdir/fftw.log"

[[ $STACK_BOOST_FULL     =~ [yYtT] ]] && \
    libs/build_boost.sh "1.68.0" 2>&1 | tee "$logdir/boost.log"

[[ $STACK_BUILD_ESMF     =~ [yYtT] ]] && \
    libs/build_esmf "7_1_0r" 2>&1 | tee "$logdir/esmf.log"

[[ $STACK_BUILD_BASELIBS =~ [yYtT] ]] && \
    libs/build_baselibs.sh "5.2.2" 2>&1 | tee "$logdir/baselibs.log"

# ===============================================================================

exit 0
