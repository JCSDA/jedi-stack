#!/bin/sh --login

#-----------------------------------------------------
# Build the nemsio library on wcoss phase 1/2 or
# wcoss-cray.  Invoke with no arguments:
#
# $> build.wcoss.sh
#-----------------------------------------------------

#set -x

export VER="v2.2.3"
module purge

mac=$(hostname -f)

case $mac in

  g????.ncep.noaa.gov | t????.ncep.noaa.gov)  # wcoss phase 1/2

    echo BUILD WITH INTEL COMPILER. 

    module load ics/14.0.1
#    module load nemsio/v2.2.2
    module list

    export LIBDIR='..'
    export INC='include'
    export FCOMP=mpiifort
#    export FCFLAGS='-O3 -FR -I$(NEMSIO_INC)'
    export FFLAGS='-O -g'
    export AR='ar'
    export ARFLAGS='-rvu'
    export RM='rm'
    make clean
    make;;

  llogin? | slogin?)  # wcoss cray

    echo BUILD WITH INTEL COMPILER. 

    module load PrgEnv-intel
    module load craype-sandybridge
#    module load nemsio-intel/2.2.2
    module list

    export LIBDIR='../intel'
    export INC='include'
    export FCOMP=ftn
#    export FCFLAGS='-O3 -FR -I$(NEMSIO_INC) -axCore-AVX2 -craype-verbose'
    export FFLAGS='-O -g'
    export AR='ar'
    export ARFLAGS='-rvu'
    export RM='rm'

    make clean
    make 
 
    echo BUILD WITH CRAY COMPILER.

    module swap PrgEnv-intel PrgEnv-cray
    module swap craype-sandybridge craype-haswell
#    module swap nemsio-intel/2.2.2 nemsio-cray-haswell/2.2.2
    module list

    export LIBDIR='../cray'
    export INC='include'
    export FCOMP=ftn
#    export FCFLAGS='-O2 -ffree -I$(NEMSIO_INC) -craype-verbose'
    export FFLAGS='-O -g'
    export AR='ar'
    export ARFLAGS='-rvu'
    export RM='rm'

    make clean
    make ;;

tfe??)  # theia

    echo BUILD WITH INTEL COMPILER. 

    module use -a /scratch3/NCEPDEV/nwprod/lib/modulefiles
    module load intel/15.1.133 impi/5.0.3.048
    export FCOMP='mpiifort'
    export LIBDIR='..'
    export INC='include'
    export FFLAGS='-O -g'
    export AR='ar'
    export ARFLAGS='-rvu'
    export RM='rm'

    make clean
    make ;;

esac

exit
