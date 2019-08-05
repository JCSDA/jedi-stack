#!/bin/bash

# Note - the compilers and install paths for this are currently hardwired in,
# including some in /usr/local.  This might work for the container but it
# needs more work to fully integrate into the build system

set -ex

name="nceplibs"

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
    prefix=${NCEPLIBS:-"/usr/local"}
fi

cd ${JEDI_STACK_ROOT}/buildscripts/libs/nceplibs
./nceplibs.bash

# generate modulefile from template
$MODULES && update_modules compiler $name $version

exit 0
