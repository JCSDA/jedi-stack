#!/bin/bash

set -ex

name="lapack"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')

[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

# manage package dependencies here
set +x
source $MODULESHOME/init/bash
module load jedi-$COMPILER
module list
set -x

export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="-fPIC"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
url="http://www.netlib.org/lapack/$software.tgz"
[[ -d $software ]] || ( wget $url; tar -xf $software.tgz )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                      || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
fi

# Add CMAKE_INSTALL_LIBDIR to make sure it will be installed under lib not lib64
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_LIBDIR:PATH=$prefix/lib \
      -DCMAKE_Fortran_COMPILER=$FC -DCMAKE_Fortran_FLAGS=$FCFLAGS ..

make -j${NTHREADS:-4} 
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
cd $JEDI_STACK_ROOT/buildscripts
libs/update_modules.sh compiler $name $version

exit 0
