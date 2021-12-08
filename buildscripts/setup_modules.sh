#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.


# The purpose of this script is to define the compiler and MPI library to be
# used and to set up and deploy the associated modules.  This needs to be each
# time a different compiler/MPI build is initiated.
#
# Arguments:
# compiler name/version and MPI Library/version: these are the names of the
# modules that this script is responsible for creating and that build_stack.sh
# will use to build the software stack.
#
# sample usage
# setup_modules.sh "custom"
#

set -ex

# root directory for the repository
JEDI_BUILDSCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export JEDI_STACK_ROOT=$JEDI_BUILDSCRIPTS_DIR/..
JEDI_OPT=${JEDI_OPT:-$OPT}
if [ -z "$JEDI_OPT" ]; then
    echo "Set JEDI_OPT to modules directory (suggested: $HOME/opt/modules)"
    exit 1
fi

logdir=$JEDI_STACK_ROOT/log

# define update_modules function
source ${JEDI_BUILDSCRIPTS_DIR}/libs/update_modules.sh

# create build directory if needed
pkgdir=${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
mkdir -p $pkgdir

#===============================================================================
# First get the compiler+mpi names and versions from the config file

if [[ $# -ne 1 ]]; then
  source ${JEDI_BUILDSCRIPTS_DIR}/config/config_custom.sh
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
fi

compilerName=$(echo $JEDI_COMPILER | cut -d/ -f1)
compilerVersion=$(echo $JEDI_COMPILER | cut -d/ -f2)

mpiName=$(echo $JEDI_MPI | cut -d/ -f1)
mpiVersion=$(echo $JEDI_MPI | cut -d/ -f2)

pythonName=$(echo $JEDI_PYTHON | cut -d/ -f1)
pythonVersion=$(echo $JEDI_PYTHON | cut -d/ -f2)

set +x
echo "Compiler: $compilerName/$compilerVersion"
echo "Mpi: $mpiName/$mpiVersion"
echo "Python: $pythonName/$pythonVersion"
set -x

# install with root permissions?
[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

#===============================================================================
# Deploy directory structure for modulefiles

[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

$SUDO mkdir -p $JEDI_OPT/modulefiles/core
$SUDO mkdir -p $JEDI_OPT/modulefiles/compiler/$compilerName/$compilerVersion
$SUDO mkdir -p $JEDI_OPT/modulefiles/mpi/$compilerName/$compilerVersion/$mpiName/$mpiVersion
$SUDO mkdir -p $JEDI_OPT/modulefiles/python/$pythonName/$pythonVersion

$SUDO mkdir -p $JEDI_OPT/modulefiles/core/jedi-$compilerName
$SUDO cp $JEDI_STACK_ROOT/modulefiles/core/jedi-$compilerName/jedi-$compilerName.lua \
         $JEDI_OPT/modulefiles/core/jedi-$compilerName/$compilerVersion.lua

$SUDO mkdir -p $JEDI_OPT/modulefiles/compiler/$compilerName/$compilerVersion/jedi-$mpiName
$SUDO cp $JEDI_STACK_ROOT/modulefiles/compiler/compilerName/compilerVersion/jedi-$mpiName/jedi-$mpiName.lua \
         $JEDI_OPT/modulefiles/compiler/$compilerName/$compilerVersion/jedi-$mpiName/$mpiVersion.lua

$SUDO mkdir -p $JEDI_OPT/modulefiles/core/jedi-$pythonName
$SUDO cp $JEDI_STACK_ROOT/modulefiles/core/jedi-$pythonName/jedi-$pythonName.lua \
         $JEDI_OPT/modulefiles/core/jedi-$pythonName/$pythonVersion.lua

#===============================================================================
# Make sure compiler is available
#
# The compilers are typically set up separately, either by package installs
# (e.g. gnu, clang) or by install scripts (e.g. intel).  In the case of gnu,
# we can optionally install the compiler from source if it is not already there
#

case ${COMPILER_BUILD} in
  "native-module")
    echo -e "==========================\n USING NATIVE COMPILER MODULE"
    set +x
    source $MODULESHOME/init/bash
    module load $JEDI_COMPILER
    module list
    set -x
    ;;
  "native-pkg")
    echo -e "==========================\n USING NATIVE COMPILER"
    cd $JEDI_OPT/modulefiles/core/jedi-$compilerName
    $SUDO sed -i -e '/load(compiler)/d' $compilerVersion.lua
    $SUDO sed -i -e '/prereq(compiler)/d' $compilerVersion.lua
    ;;
  "from-source")
    echo -e "==========================\n INSTALLING COMPILER FROM SOURCE"
    if [[ -n $(grep -i gnu <<< $JEDI_COMPILER) ]]; then
        ${JEDI_BUILDSCRIPTS_DIR}/libs/build_gnu.sh $compilerVersion
    else
        echo "ERROR: COMPILER $JEDI_COMPILER NOT FOUND: ABORT!"
        exit 1
    fi
    ;;
esac

#===============================================================================
# Set up compiler modules

# Check that the compiler version number given by the user is consistent
# with what is actually installed
set +x
case $compilerName in
    gnu   ) CC=gcc ;;
    intel ) CC=icc ;;
    clang ) CC=clang ;;
    *     ) echo "Invalid compiler option = $compilerName, ABORT!"; exit 1 ;;
esac

if [[ -z $JEDI_STACK_DISABLE_COMPILER_VERSION_CHECK  && \
       -z $($CC --version | grep $compilerVersion) ]]; then
    echo "WARNING: COMPILER VERSION $JEDI_COMPILER APPEARS TO BE INCORRECT!"
    echo "CONTINUE ANYWAY? ANSWER Y OR N"
    read ans < /dev/stdin
    echo $ans
    [[ $ans =~ ([^YyTt]) ]] && exit 1
fi
set -x

#===============================================================================
# Now build the MPI library from source, if needed.  However, if there is
# a native installation available, it's usually better to use that

case ${MPI_BUILD} in
  "native-module")
    set +x
    echo -e "==========================\n USING NATIVE MPI MODULE"
    source $MODULESHOME/init/bash
    module load $JEDI_COMPILER
    module load $JEDI_MPI
    module list
    set -x
    ;;
  "native-pkg")
    echo -e "===========================\n USING NATIVE MPI"
    cd $JEDI_OPT/modulefiles/compiler/$compilerName/$compilerVersion/jedi-$mpiName
    $SUDO sed -i -e '/load(mpi)/d' $mpiVersion.lua
    $SUDO sed -i -e '/prereq(mpi)/d' $mpiVersion.lua
    ;;
  "from-source")
    echo -e "============================\n INSTALLING MPI FROM SOURCE"

    logdir=$JEDI_STACK_ROOT/$LOGDIR
    mkdir -p $logdir

    ${JEDI_BUILDSCRIPTS_DIR}/libs/build_mpi.sh $mpiName $mpiVersion 2>&1 | tee "$logdir/$mpiName.log"

    RetCode=${PIPESTATUS[0]}
    if [[ $RetCode > 0 ]]
    then
        echo "MPI BUILD FAIL! Error:$RetCode"
        exit $RetCode
    fi
    echo "MPI BUILD SUCCESS!"
    ;;
esac

#===============================================================================
# Make sure Python is available
#

case ${PYTHON_BUILD} in
  "native-module")
    echo -e "==========================\n USING NATIVE PYTHON MODULE"
    set +x
    source $MODULESHOME/init/bash
    module load $JEDI_PYTHON
    module list
    set -x
    ;;
  "native-pkg")
    echo -e "==========================\n USING NATIVE PYTHON"
    cd $JEDI_OPT/modulefiles/core/jedi-$pythonName
    $SUDO sed -i -e '/load(python)/d' $pythonVersion.lua
    $SUDO sed -i -e '/prereq(python)/d' $pythonVersion.lua
    ;;
  "from-source")
    echo "ERROR: INSTALLING PYTHON FROM SOURCE IS NOT SUPPORTED AT THIS TIME, ABORT!"
    exit 1
    ;;
esac

#===============================================================================
# optionally clean up
[[ $MAKE_CLEAN =~ [yYtT] ]] && rm -rf $pkgdir

#===============================================================================

set +x
echo "setup_modules.sh $1: success!"
echo "To proceed run: build_stack.sh $1"
