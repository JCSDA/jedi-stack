#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.
#
# Note - the compilers and install paths for this are currently hardwired in,
# including some in /usr/local.  This might work for the container but it
# needs more work to fully integrate into the build system

set -ex

name="nceplibs"
version=$1

# NCEPlibs ship with jedi-stack so there is nothing to download
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

# Hyphenated version used for install prefix
compiler=$(echo $JEDI_COMPILER | sed 's/\//-/g')

# manage package dependencies here
if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load jedi-$JEDI_COMPILER
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix=${NCEPLIBS:-"/usr/local"}
fi

cd ${JEDI_STACK_ROOT}/buildscripts/libs/NCEPlibs
rm -f *.a
rm macros.make

if [[ $(echo $compiler | cut -d- -f1) = "gnu" ]]; then
    ln -s macros.make.cheyenne.gnu macros.make
elif [[ $(echo $compiler | cut -d- -f1) = "intel" ]]; then
    ln -s macros.make.aws.intel macros.make
fi
make

# install
$SUDO mkdir -p $prefix/lib
$SUDO mv *.a $prefix/lib
$SUDO rm -rf $prefix/include
$SUDO mv include $prefix

# generate modulefile from template
$MODULES && update_modules compiler $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
