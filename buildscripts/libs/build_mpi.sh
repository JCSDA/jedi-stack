#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

set -ex

name=$1
version=$2

mm=$(echo $version | cut -d. -f-2)
patch=$(echo $version | cut -d. -f3)

case "$name" in
    openmpi ) url="https://download.open-mpi.org/release/open-mpi/v$mm/openmpi-$version.tar.gz" ;;
    mpich   ) url="http://www.mpich.org/static/downloads/$version/mpich-$version.tar.gz" ;;
    *       ) echo "Invalid option for MPI = $name, ABORT!"; exit 1 ;;
esac

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')

set +x
source $MODULESHOME/init/bash
module load jedi-$JEDI_COMPILER
module list
set -x

[[ -n $FC && `$FC --version` =~ GNU\ Fortran.*\ 1[0-9]\.[0-9]+ ]] && FC_GFORTRAN_10=1

export CC=$SERIAL_CC
export CXX=$SERIAL_CXX
export FC=$SERIAL_FC

export FFLAGS+=" -fPIC"
export CFLAGS+=" -fPIC"
export CXXFLAGS+=" -fPIC"
export FCFLAGS=${FFLAGS}

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"../pkg"}

software=$name-$version
[[ -d $software ]] || ( $WGET $url; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                               || ( echo "ERROR: $prefix EXISTS, ABORT!"; exit 1 )
fi

# If on a Mac, need to disable -flat_namespace for the link step. This is so because
# we have mixed C/C++ and Fortran in several libraries, and -flat_namespace leads
# to aborts when exceptions are thrown. (See the ZenHub issue JCSDA/oops#649 for details.)
# Fortunately, mpich provides a configure control (--enable-two-level-namespace) for doing
# this. Unfortunately, openmpi has -flat_namepace harwired into its configure script. A
# workaround for openmpi is to strip off the -flat_namespace settings in the configure
# script using sed.
host=$(uname -s)
case "$name" in
    openmpi )
       extra_conf="--enable-mpi-fortran --enable-mpi-cxx"
       if [[ "$host" == "Darwin" ]]
       then
           # On a Mac, use the sed hack to disable -flat_namespace
           sed -i '.bak' -e's/-Wl,-flat_namespace//g' ../configure
           # On a Mac, use Open MPI internal versions of hwloc and libevent
           # see: https://www.open-mpi.org/faq/?category=building#libevent-or-hwloc-errors-when-linking-fortran
           openmpi_conf="--with-hwloc=internal --with-libevent=internal"
           extra_conf="$extra_conf $openmpi_conf --with-wrapper-ldflags=-Wl,-commons,use_dylibs"
       fi
       ;;
    mpich   )
       if [[ "$host" == "Darwin" ]]
       then
           # On a Mac, use the control to disable -flat_namespace
           extra_conf="--enable-fortran --enable-cxx --enable-two-level-namespace"
       else
           extra_conf="--enable-fortran --enable-cxx"
       fi
       # gfortran-10+ compatibility flags
       if [[ -n $FC_GFORTRAN_10 ]]; then
           # Use these flags to build MPICH itself, but don't add to WRAPPER_FCFLAGS
           export MPICHLIB_FCFLAGS+=" -fallow-argument-mismatch -fallow-invalid-boz"
           export MPICHLIB_FFLAGS=${MPICHLIB_FCFLAGS}
           # Disable check for mismatched args flags in confdb/aclocal_f77.ac
           export pac_cv_prog_f77_mismatched_args=yes
       fi
       [[ -n $HWLOC_ROOT ]] && extra_conf+=" --with-hwloc-prefix=${HWLOC_ROOT}"
       ;;
    *       )
       echo "Invalid option for MPI = $software, ABORT!"
       exit 1
       ;;
esac

../configure --prefix=$prefix $extra_conf
make V=$MAKE_VERBOSE -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
