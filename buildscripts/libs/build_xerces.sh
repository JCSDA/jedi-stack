#!/bin/bash

set -ex

name="xerces"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $COMPILER | sed 's/\//-/g')

# manage package dependencies here
if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$COMPILER
    module list
    set -x
    
    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
    if [[ -d $prefix ]]; then
	[[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${XERCES_ROOT:-"/usr/local"}
fi

export FC=$SERIAL_FC
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX

export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="-fPIC"

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-c-$version
vnum=$(echo $version | cut -d. -f1)
url=https://archive.apache.org/dist/xerces/c/$vnum/sources/$software.tar.gz
[[ -d $software ]] || ( $WGET $url; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix --with-curl --without-icu

make -j${NTHREADS:-4} 
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version \
	 || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log

exit 0
