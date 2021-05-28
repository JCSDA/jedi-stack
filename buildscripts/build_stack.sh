#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

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

# Choose which modules you wish to install
$MODULES && source ${JEDI_BUILDSCRIPTS_DIR}/config/choose_modules.sh

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
build_lib CMAKE cmake 3.20.0
build_lib UDUNITS udunits 2.2.28
build_lib JPEG jpeg 9.1.0
build_lib ZLIB zlib 1.2.11
build_lib PNG png 1.6.35
build_lib SZIP szip 2.1.1
build_lib LAPACK lapack 3.8.0
build_lib BOOST_HDRS boost 1.68.0 headers-only
build_lib EIGEN3 eigen 3.3.7
build_lib BUFR bufr noaa-emc 11.5.0
build_lib ECBUILD ecbuild ecmwf 3.6.1
build_lib CGAL cgal 5.0.4
build_lib GITLFS git-lfs 2.11.0

#----------------------
# These must be rebuilt for each MPI implementation
build_lib HDF5 hdf5 1.12.0
build_lib PNETCDF pnetcdf 1.12.1
build_lib NETCDF netcdf 4.7.4 4.5.3 4.3.0
build_lib NCCMP nccmp 1.8.7.0
build_lib ECKIT eckit ecmwf 1.16.0
build_lib FCKIT fckit ecmwf 0.9.2
build_lib ATLAS atlas ecmwf 0.24.1
build_lib ODB odb 0.18.1.r2
build_lib ODC odc ecmwf 2021.03.0

# ===============================================================================
# Optional Extensions to the JEDI Stack

#----------------------
# MPI-independent
build_lib JASPER jasper 1.900.1
build_lib ARMADILLO armadillo 1.900.1
build_lib XERCES xerces 3.1.4
build_lib NCEPLIBS nceplibs fv3
build_lib TKDIFF tkdiff 4.3.5
build_lib PYJEDI pyjedi
build_lib PYBIND11 pybind11 2.5.0
build_lib GSL_LITE gsl_lite 0.37.0
build_lib GEOS geos 3.8.1
build_lib SQLITE sqlite 3.32.3
build_lib PROJ proj 7.1.0
build_lib JSON json 3.9.1
build_lib JSON_SCHEMA_VALIDATOR json-schema-validator 2.1.0
build_lib ECFLOW ecflow ecmwf 5.5.3 boost 1.68.0

#----------------------
# These must be rebuilt for each MPI implementation
build_lib GPTL gptl 8.0.3
build_lib NCO nco 4.9.9
build_lib PIO pio 2.5.1
build_lib FFTW fftw 3.3.8
build_lib BOOST_FULL boost 1.68.0
build_lib ESMF esmf 8_0_1
build_lib BASELIBS baselibs 5.2.2
build_lib PDTOOLKIT pdtoolkit 3.25.1
build_lib TAU2 tau2 3.25.1
build_lib FMS fms jcsda release-stable

# ===============================================================================
# optionally clean up
[[ $MAKE_CLEAN =~ [yYtT] ]] && \
    ( $SUDO rm -rf $pkgdir; $SUDO rm -rf $logdir )

# ===============================================================================
echo "build_stack.sh $1: success!"
