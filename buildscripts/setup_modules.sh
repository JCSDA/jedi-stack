#!/bin/bash

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
export JEDI_STACK_ROOT=$PWD/..

# define update_modules function
source libs/update_modules.sh

# create build directory if needed
mkdir -p ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

#===============================================================================
# First get the compiler+mpi names and versions from the config file

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

compilerName=$(echo $COMPILER | cut -d/ -f1)
compilerVersion=$(echo $COMPILER | cut -d/ -f2)

mpiName=$(echo $MPI | cut -d/ -f1)
mpiVersion=$(echo $MPI | cut -d/ -f2)

echo $compilerName
echo $compilerVersion
echo $mpiName
echo $mpiVersion

# install with root permissions?
[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

#===============================================================================
# Deploy directory structure for modulefiles

[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

$SUDO mkdir -p $OPT/modulefiles/core
$SUDO mkdir -p $OPT/modulefiles/compiler/$compilerName/$compilerVersion
$SUDO mkdir -p $OPT/modulefiles/mpi/$compilerName/$compilerVersion/$mpiName/$mpiVersion

$SUDO mkdir -p $OPT/modulefiles/core/jedi-$compilerName
$SUDO cp $JEDI_STACK_ROOT/modulefiles/core/jedi-$compilerName/jedi-$compilerName.lua \
         $OPT/modulefiles/core/jedi-$compilerName/$compilerVersion.lua

$SUDO mkdir -p $OPT/modulefiles/compiler/$compilerName/$compilerVersion/jedi-$mpiName
$SUDO cp $JEDI_STACK_ROOT/modulefiles/compiler/compilerName/compilerVersion/jedi-$mpiName/jedi-$mpiName.lua \
         $OPT/modulefiles/compiler/$compilerName/$compilerVersion/jedi-$mpiName/$mpiVersion.lua

#===============================================================================
# Make sure compiler is available
#
# The compilers are typically set up seperately, either by package installs
# (e.g. gnu, clang) or by install scripts (e.g. intel).  In the case of gnu,
# we can optionally install the compiler from source if it is not already there
#

case ${COMPILER_BUILD} in
    "native-module")
	echo "USING NATIVE COMPILER MODULE"
	module load $COMPILER
	;;
    "native-pkg")
	echo "USING NATIVE COMPILER"
	cd $OPT/modulefiles/core/jedi-$compilerName            
	$SUDO sed -i -e '/load(compiler)/d' $compilerVersion.lua
	$SUDO sed -i -e '/prereq(compiler)/d' $compilerVersion.lua
	;;
    "from-source")
	echo "INSTALLING COMPILER FROM SOURCE"
	if [[ -n $(grep -i gnu <<< $COMPILER) ]]; then
	    libs/build_gnu.sh $compilerVersion  
	else
	    echo "ERROR: COMPILER $COMPILER NOT FOUND: ABORT!"
	    exit 1
	fi
	;;
esac

#===============================================================================
# Set up compiler modules

# Check that the compiler version number given by the user is consistent
# with what is actually installed

case $compilerName in
    gnu   ) CC=gcc ;;
    intel ) CC=icc ;;
    clang ) CC=clang ;;
    *     ) echo "Invalid compiler option = $compilerName, ABORT!"; exit 1 ;;
esac

if [[ -z $($CC --version | grep $compilerVersion) ]]; then
    echo "WARNING: COMPILER VERSION $COMPILER APPEARS TO BE INCORRECT!"
    echo "CONTINUE ANYWAY? ANSWER Y OR N"
    read ans < /dev/stdin
    echo $ans
    [[ $ans =~ ([^YyTt]) ]] && exit 1
fi

#===============================================================================
# Next build szip.  It's helpful to do this before building MPI because the MPI
# libraries may exploit szip compression to improve performance.

logdir=$JEDI_STACK_ROOT/$LOGDIR
mkdir -p $logdir
cd $JEDI_STACK_ROOT/buildscripts

[[ $STACK_BUILD_SZIP =~ [yYtT] ]] && \
    libs/build_szip.sh "2.1.1" 2>&1 | tee "$logdir/szip.log"

#===============================================================================
# Now build the MPI library from source, if needed.  However, if there is
# a native installation available, it's usually better to use that

case ${MPI_BUILD} in
    "native-module")
	echo -e "==========================\n USING NATIVE MPI MODULE"
        module load jedi-$COMPILER
	module load $MPI
	;;
    "native-pkg")
	echo -e "===========================\n USING NATIVE MPI"
	cd $OPT/modulefiles/compiler/$compilerName/$compilerVersion/jedi-$mpiName
	$SUDO sed -i -e '/load(mpi)/d' $mpiVersion.lua
	$SUDO sed -i -e '/prereq(mpi)/d' $mpiVersion.lua
	;;
    "from-source")
	echo -e "============================\n INSTALLING MPI FROM SOURCE"
	cd $JEDI_STACK_ROOT/buildscripts
	libs/build_mpi.sh $mpiName $mpiVersion 2>&1 | tee "$logdir/$mpiName.log"
esac

#===============================================================================
# optionally clean up
[[ $MAKE_CLEAN =~ [yYtT] ]] && rm -rf ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

#===============================================================================

exit 0
