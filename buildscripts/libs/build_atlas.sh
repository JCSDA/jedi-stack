#!/bin/bash

set -ex

name="atlas"
# source should be either ecmwf or jcsda (fork)
source=$1
version=$2

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')
mpi=$(echo $JEDI_MPI | sed 's/\//-/g')

[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO
[[ $MAKE_VERBOSE =~ [yYtT] ]] && verb="VERBOSE=1" || unset verb

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    module load jedi-$JEDI_MPI
    module load ecbuild eckit fckit
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$source-$version"
    if [[ -d $prefix ]]; then
  [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${ATLAS_ROOT:-"/usr/local"}
fi


export FC=$MPI_FC
export CC=$MPI_CC
export CXX=$MPI_CXX
export F9X=$FC

software=$name
cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

[[ -d $software ]] || git clone https://github.com/$source/$software.git
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
git fetch --tags
git checkout $version
[[ -d build ]] && $SUDO rm -rf build
mkdir -p build && cd build

ecbuild --prefix=$prefix --build=Release ..
make -j${NTHREADS:-4}
$SUDO make $verb install

# generate modulefile from template
$MODULES && update_modules mpi $name $source-$version \
   || echo $name $source-$version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log

exit 0
