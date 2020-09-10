#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

set -ex

name="git-lfs"
version=$1

# this is only needed if MAKE_CHECK is enabled
if $MODULES; then

    set +x
    source $MODULESHOME/init/bash
    module try-load git
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/core/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${GITLFS_ROOT:-"/usr/local"}
fi

cd $JEDI_STACK_ROOT/${PKGDIR:-"pkg"}

software=git-lfs-linux-386-v$version
mkdir -p $software
cd $software
wget https://github.com/git-lfs/git-lfs/releases/download/v$version/$software.tar.gz
tar xvf $software.tar.gz
$SUDO mkdir -p $prefix/bin
$SUDO rm -rf $prefix/bin/git-lfs*
install git-lfs $prefix/bin/git-lfs

# generate modulefile from template
$MODULES && update_modules core $name $version \
         || echo $name $version >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log

exit 0
