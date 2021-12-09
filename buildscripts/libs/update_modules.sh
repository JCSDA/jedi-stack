#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.
#
# This script creates a module file for a given package
# based on a pre-existing template
#
# Arguments:
# $1 = module path: valid options are core, compiler, or mpi
# $2 = package name
# $3 = package version
# $4 = python version (optional)
#
# Only specify the python version if you need to set that in the destination
# lua script. A non-empty setting of $4 will cause sed to be run on the
# destination lua script to substitue "@PYTHON_VERSION@" with the python version
# number specified in $4.

function update_modules {
    OPT="${JEDI_OPT:-$OPT}"
    case $1 in
        core     )
            tmpl_file=$JEDI_STACK_ROOT/modulefiles/core/$2/$2.lua
            to_dir=$OPT/modulefiles/core ;;
        compiler )
            tmpl_file=$JEDI_STACK_ROOT/modulefiles/compiler/compilerName/compilerVersion/$2/$2.lua
            to_dir=$OPT/modulefiles/compiler/$JEDI_COMPILER ;;
        mpi      )
            tmpl_file=$JEDI_STACK_ROOT/modulefiles/mpi/compilerName/compilerVersion/mpiName/mpiVersion/$2/$2.lua
            to_dir=$OPT/modulefiles/mpi/$JEDI_COMPILER/$JEDI_MPI ;;
        python  )
            tmpl_file=$JEDI_STACK_ROOT/modulefiles/python/pythonName/pythonVersion/$2/$2.lua
            to_dir=$OPT/modulefiles/python/$JEDI_PYTHON ;;
        *) echo "ERROR: INVALID MODULE PATH, ABORT!"; exit 1 ;;
    esac

    [[ -e $tmpl_file ]] || ( echo "ERROR: $tmpl_file NOT FOUND!  ABORT!"; exit 1 )

    [[ -d $to_dir ]] || ( echo "ERROR: $mod_dir MODULE DIRECTORY NOT FOUND!  ABORT!"; exit 1 )

    cd $to_dir
    $SUDO mkdir -p $2; cd $2
    $SUDO cp $tmpl_file $3.lua
    # Argument number 4 is python version. If not empty use sed to
    # substitue python version into placeholder marks in the lua script.
    [[ -n "$4" ]] && $SUDO sed -i -e "s/@PYTHON_VERSION@/$4/" $3.lua

    # Make the latest installed version the default
    [[ -e default ]] && $SUDO rm -f default
    $SUDO ln -s $3.lua default

}

function no_modules {

    # this function defines environment variables that are
    # normally done by the modules.  It's mainly intended
    # for use in generating the containers    

    compilerName=$(echo $JEDI_COMPILER | cut -d/ -f1)
    mpiName=$(echo $JEDI_MPI | cut -d/ -f1)

    # these can be specified in the config file
    # so these should be considered defaults

    case $compilerName in
      gnu   )
          export SERIAL_CC=${SERIAL_CC:-"gcc"}
          export SERIAL_CXX=${SERIAL_CXX:-"g++"}
          export SERIAL_FC=${SERIAL_FC:-"gfortran"}
          ;;
      intel )
          export SERIAL_CC=${SERIAL_CC:-"icc"}
          export SERIAL_CXX=${SERIAL_CXX:-"icpc"}
          export SERIAL_FC=${SERIAL_FC:-"ifort"}
          ;;
      clang )
          export SERIAL_CC=${SERIAL_CC:-"clang"}
          export SERIAL_CXX=${SERIAL_CXX:-"clang++"}
          export SERIAL_FC=${SERIAL_FC:-"gfortran"}
          ;;
      *     ) echo "Unknown compiler option = $compilerName, ABORT!"; exit 1 ;;
    esac

    case $mpiName in
      openmpi)
          export MPI_CC=${MPI_CC:-"mpicc"}
          export MPI_CXX=${MPI_CXX:-"mpicxx"}
          export MPI_FC=${MPI_FC:-"mpifort"}
          ;;
      mpich  )
          export MPI_CC=${MPI_CC:-"mpicc"}
          export MPI_CXX=${MPI_CXX:-"mpicxx"}
          export MPI_FC=${MPI_FC:-"mpifort"}
          ;;
      impi   )
          export MPI_CC=${MPI_CC:-"mpiicc"}
          export MPI_CXX=${MPI_CXX:-"mpiicpc"}
          export MPI_FC=${MPI_FC:-"mpiifort"}
          ;;
      *     ) echo "Unknown MPI option = $MPIName, ABORT!"; exit 1 ;;
    esac

    components_file="${JEDI_STACK_ROOT}/buildscripts/config/choose_modules.sh"

    set +x
    # look for build items that are set in the config file
    while IFS= read -r line ; do
        if [[ $(echo $line | grep "STACK_BUILD" | cut -d= -f2) =~ [yYtT] ]]; then
            pkg=$(echo $line | cut -d= -f1 | cut -d_ -f3)
            eval export ${pkg}_ROOT=${PREFIX:-"/usr/local"}
        fi
    done < $components_file
    set -x
}

function build_lib() {
    # Args: BUILD_SWITCH_VAR, build_script_name, version, [extra build script args]
    set +x
    var="STACK_BUILD_$1"
    if [[ ${!var} =~ [yYtT] ]]; then
        ${JEDI_BUILDSCRIPTS_DIR}/libs/build_$2.sh "${@:3}" 2>&1 | tee "$logdir/$2.log"
        ret=${PIPESTATUS[0]}
        if [[ $ret > 0 ]]; then 
            echo "BUILD FAIL!  Lib: $2-$3 Error:$ret"
            [[ ${STACK_EXIT_ON_FAIL} =~ [yYtT] ]] && exit $ret
        fi
        echo "BUILD SUCCESS! Lib: $2-$3"
    fi
    set -x
}


function _initialize_prefix() {
    # ARGS: type name version compiler mpi required_modules optional_modules
    set +x
    type=$1
    name=$2
    if $MODULES; then
        source $MODULESHOME/init/bash
        module load jedi-$JEDI_COMPILER
        if [[ $# > 5 ]]; then
            for mod in ${@:6}; do
                module load $mod
            done
        fi
        if [[ $# > 6 ]]; then
            for mod in ${@:7}; do
                module try-load $mod
            done
        fi
        module list
        case $type in
            core) prefix="${PREFIX:-"/opt/modules"}/core/$name/$version";;
            compiler) prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version";;
            mpi) prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version";;
            # python not yet implemented
        esac
        if [[ -d $prefix ]]; then
            [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!"; $SUDO rm -rf $prefix ) \
                                       || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
        fi
    else
        prefix=${${name}_ROOT:-"/usr/local"}
    fi
    export prefix
}

function initialize_prefix_core() {
    # ARGS: name version required_modules optional_modules
    set -x
    _initialize_prefix core $1 $2 "" "" ${@:3}
}

function initialize_prefix_compiler() {
    # ARGS: name version compiler required_modules optional_modules
    set -x
    echo $@
    _initialize_prefix compiler $1 $2 $3 "" ${@:4}
}

function initialize_prefix_mpi() {
    # ARGS: name version compiler mpi required_modules optional_modules
    set -x
    _initialize_prefix mpi $@
}


export -f update_modules
export -f no_modules
export -f build_lib
export -f _initialize_prefix
export -f initialize_prefix_core
export -f initialize_prefix_compiler
# Note: this isn't used anywhere
export -f initialize_prefix_mpi
