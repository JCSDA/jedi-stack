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
JEDI_BUILDSCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export JEDI_STACK_ROOT=${JEDI_BUILDSCRIPTS_DIR}/..

set -ex

# define update_modules function
source "${JEDI_BUILDSCRIPTS_DIR}/libs/update_modules.sh"

# create build directory if needed
pkgdir=${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
mkdir -p $pkgdir

# ===============================================================================
# configure build

if [[ $# -ne 1 ]]; then
    source "${JEDI_BUILDSCRIPTS_DIR}/config/config_custom.sh"
else
    config_file="${JEDI_BUILDSCRIPTS_DIR}/config/config_$1.sh"
    if [[ -e $config_file ]]; then
      source $config_file
    else
      set +x
      echo "ERROR: CONFIG FILE $config_file DOES NOT EXIST!"
      echo "Currently supported options: "
      echo ${supported_options[*]}
      exit 1
    fi

    # Currently we do not use modules in the containers
    [[ $1 =~ ^container ]] && export MODULES=false || export MODULES=true

fi

# this is needed to set environment variables if modules are not used
$MODULES || no_modules $1

# This is for the log files
logdir=$JEDI_STACK_ROOT/$LOGDIR
mkdir -p $logdir

# install with root permissions?
[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

# ===============================================================================
# Minimal JEDI Stack

# start with a clean slate
$MODULES && (set +x;  source $MODULESHOME/init/bash; module purge; set -x)

#----------------------
# MPI-independent
# - should add a check at some point to see if they are already there.
# this can be done in each script individually
# it might warrant a --force flag to force rebuild when desired
build_lib CMAKE cmake 3.13.0
build_lib UDUNITS udunits 2.2.26
build_lib JPEG jpeg 9.1.0
build_lib ZLIB zlib 1.2.11
build_lib PNG png 1.6.35
build_lib SZIP szip 2.1.1
build_lib LAPACK lapack 3.7.0
build_lib BOOST_HDRS boost 1.68.0 headers-only
build_lib EIGEN3 eigen 3.3.5
build_lib BUFRLIB bufrlib master
build_lib ECBUILD ecbuild jcsda 3.1.0.jcsda2

#----------------------
# These must be rebuilt for each MPI implementation
build_lib HDF5 hdf5 1.10.5
build_lib PNETCDF pnetcdf 1.11.2
build_lib NETCDF netcdf 4.7.0 4.4.5 4.3.0
build_lib NCCMP nccmp 1.8.6.5
build_lib ECKIT eckit jcsda 1.4.0.jcsda3
build_lib FCKIT fckit jcsda develop
build_lib ATLAS atlas ecmwf 0.19.1
build_lib ODB odb 0.18.1.r2
build_lib ODC odc jcsda develop
build_lib ODYSSEY odyssey jcsda develop

# ===============================================================================
# Optional Extensions to the JEDI Stack

#----------------------
# MPI-independent
build_lib JASPER jasper 1.900.1
build_lib ARMADILLO armadillo 1.900.1
build_lib XERCES xerces 3.1.4
build_lib NCEPLIBS nceplibs fv3
build_lib TKDIFF tkdirr 4.3.5
build_lib PYJEDI pyjedi

#----------------------
# These must be rebuilt for each MPI implementation
build_lib NCO nco 4.7.9
build_lib PIO pio 2.5.0
build_lib FFTW fftw 3.3.8
build_lib BOOST_FULL boost 1.68.0
build_lib ESMF esmf 8_0_0
build_lib BASELIBS baselibs 5.2.2
build_lib PDTOOLKIT pdtoolkit 3.25.1
build_lib TAU2 tau2 3.25.1

# ===============================================================================
# optionally clean up
[[ $MAKE_CLEAN =~ [yYtT] ]] && \
    ( $SUDO rm -rf $pkgdir; $SUDO rm -rf $logdir )

# ===============================================================================
echo "build_stack.sh $1: success!"
