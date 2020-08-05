#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.


set -ex

name="odb-api"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')
mpi=$(echo $JEDI_MPI | sed 's/\//-/g')

[[ $MAKE_VERBOSE =~ [yYtT] ]] && verb="VERBOSE=1" || unset verb

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    module load jedi-$JEDI_MPI 
    module try-load ecbuild
    module load netcdf
    module try-load eckit
    
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix=${ODB_ROOT:-"/usr/local"}
fi

export FC=$MPI_FC
export CC=$MPI_CC
export CXX=$MPI_CXX

export F9X=$FC
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC -std=c++11"
export FCFLAGS="$FFLAGS"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=odb_api_bundle-$version-Source_Jedi
[[ -d $software ]] || ( curl -s http://data.jcsda.org/downloads/odb_api_bundle-$version-Source_Jedi.tar.gz | tar xvz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build_metkit ]] && $SUDO rm -rf build_metkit
[[ -d build_odb ]] && $SUDO rm -rf build_odb
mkdir -p build_metkit build_odb
cd build_metkit
ecbuild --build=Release --prefix=$prefix -DENABLE_GRIB=OFF -DCMAKE_CXX_FLAGS=${CXXFLAGS} \
         -DHAVE_CXX11=1 ../metkit
make $verb -j${NTHREADS:-4}
$SUDO make install
cd ../build_odb
ecbuild --build=Release --prefix=$prefix -DENABLE_FORTRAN=1 -DENABLE_PYTHON=1 -DHAVE_CXX11=1 \
        -DMETKIT_PATH=$prefix --DCMAKE_CXX_FLAGS=${CXXFLAGS} ..
make $verb -j${NTHREADS:-4}
$SUDO make install

# generate modulefile from template
$MODULES && update_modules mpi $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log			   
