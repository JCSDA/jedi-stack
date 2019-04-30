#!/bin/bash

# This script creates a module file for a given package
# based on a pre-existing template
#
# Arguments:
# $1 = module path: valid options are core, compiler, or mpi
# $2 = package name
# $3 = package version

case $1 in
    core     )
        tmpl_file=$JEDI_STACK_ROOT/modulefiles/core/$2/$2.lua
        to_dir=$OPT/modulefiles/core ;;
    compiler )
        tmpl_file=$JEDI_STACK_ROOT/modulefiles/compiler/compilerName/compilerVersion/$2/$2.lua
        to_dir=$OPT/modulefiles/compiler/$COMPILER ;;
    mpi      )
        tmpl_file=$JEDI_STACK_ROOT/modulefiles/mpi/compilerName/compilerVersion/mpiName/mpiVersion/$2/$2.lua
        to_dir=$OPT/modulefiles/mpi/$COMPILER/$MPI ;;
    *) echo "ERROR: INVALID MODULE PATH, ABORT!"; exit 1 ;;
esac

[[ -e $tmpl_file ]] || ( echo "ERROR: $tmpl_file NOT FOUND!  ABORT!"; exit 1 )

[[ -d $to_dir ]] || ( echo "ERROR: $mod_dir MODULE DIRECTORY NOT FOUND!  ABORT!"; exit 1 )

cd $to_dir
$SUDO mkdir -p $2; cd $2
$SUDO cp $tmpl_file $3.lua


