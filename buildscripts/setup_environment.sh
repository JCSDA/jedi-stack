#!/bin/bash

# The purpose of this script is to install lmod (if needed)
# along with some other fundamental tools such as:
# git, wget, curl, etc. For an up-to-date list, see the README.md
# file at the top level of this repository.
#
# build cmake seperately as part of the module setup
#
# These installations are typically done my means of package installs,
# Basically, anything that you may want to install with package installers
# belongs here as opposed to build_stack.sh.
# However, there are a few packages such as Lmod that you might
# want to install from source because the versions available from the
# package managers are too old or otherwise insufficient.  For these
# cases you can use the corresponding build scripts (see below for examples).
#
# This script only needs to be called once.  It is mainly intended for use
# with bare OS platforms such as base Docker images or Amazon Machine Images
# (AMIs).  On other systems (such as Mac laptops), the user may wish to install
# Lmod and supporting applications manually through package installers
# (such as Homebrew).
#
# This script can be bypassed if you are building a container because
# all the software packages installed here are installed in the
# jcsda/docker_base container via the Dockerfile
#
# Arguments:
# configuration name (leave blank to print list of supported values)
#
# sample usage
# ./setup_environment.sh "ubuntu/18.04"
#

# currently supported options
supported_options=("ubuntu/18.04","cheyenne","orion")

export JEDI_STACK_ROOT=$PWD/..

set -ex

#================================================================================

case $1 in
"ubuntu/18.04")

    set +x; echo "Installing JEDI environment for ubuntu/18.04"; set -x

    sudo apt-get update

    # this is currently configured for AWS where standard AMIs come with some basic
    # software pre-installed, such as git, make, wget, curl, etc.

    # package install of gnu compilers
    # needed here to install lmod from source
    # the defaults are sufficiently up-to-date (v7.3 as of April, 2018) but we may want
    # to switch between alternatives in the future.
    sudo apt-get install -y --no-install-recommends gcc gfortran g++

    # some basic tools - the default versions should be recent enough for ununtu/18.04
    # for further information see the docker-devel section
    sudo apt-get install -y --no-install-recommends software-properties-common
    sudo apt-get install -y --no-install-recommends build-essential tcsh csh ksh \
                    openssh-server libncurses-dev libssl-dev libx11-dev less \
                    man-db tk tcl swig bc locales file flex bison \
                    libexpat1-dev libxml2-dev unzip wish
    sudo apt-get install -y --no-install-recommends curl wget libcurl4-openssl-dev
    sudo apt-get install -y --no-install-recommends autoconf pkg-config

    # git and git-lfs
    sudo apt-get install -y git git-flow
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
    sudo apt-get install -y git-lfs
    git lfs install

    # for documentation
    sudo apt-get install -y --no-install-recommends graphviz doxygen

    # for debugging
    sudo apt-get install -y --no-install-recommends ddd gdb kdbg valgrind

    # python
    sudo apt-get install -y --no-install-recommends python-pip python-dev python-yaml \
                   python-numpy python-scipy
    sudo apt-get install -y --no-install-recommends python3-pip python3-dev \
                   python3-yaml python3-numpy python3-scipy

    # install and deploy lmod from source
    sudo apt-get install -y tcllib tcl-dev
    prefix=/opt
    libs/build_lmod.sh $prefix
    source $prefix/lmod/lmod/init/profile

    # The module files will be installed in $OPT/modulefiles
    OPT=/opt/modules

    sudo ln -s $MODULESHOME/init/profile /etc/profile.d/z00_lmod.sh
    echo "export OPT=$OPT" | sudo tee -a /etc/profile.d/z00_lmod.sh
    echo "module use $OPT/modulefiles/core" | sudo tee -a /etc/profile.d/z00_lmod.sh

    sudo ln -s $MODULESHOME/init/cshrc   /etc/profile.d/z00_lmod.csh
    echo "setenv OPT $OPT" | sudo tee -a /etc/profile.d/z00_lmod.csh
    echo "module use $OPT/modulefiles/core" | sudo tee -a /etc/profile.d/z00_lmod.csh

    ;;
#==========================================================================================
"cheyenne")

    # Cheyenne compiler modules define the environment variable MODULE so in order for
    # the build scripts to function properly we need to replace it with something else
    cd ${JEDI_STACK_ROOT}/buildscripts
    sed -i -e 's/COMPILER/JEDI_COMPILER/g' setup_modules.sh build_stack.sh
    cd libs
    sed -i -e 's/COMPILER/JEDI_COMPILER/g' *.sh

    export OPT="/glade/work/miesch/modules"
    echo "export OPT=$OPT" >> $HOME/.bashrc
    echo "module use $OPT/modulefiles/core" >> $HOME/.bashrc

    ;;
#==========================================================================================
"orion")

    # Orion compiler modules define the environment variable COMPILER so in order for
    # the build scripts to function properly we need to replace it with something else
    cd ${JEDI_STACK_ROOT}/buildscripts
    sed -i -e 's/COMPILER/JEDI_COMPILER/g' setup_modules.sh build_stack.sh
    cd libs
    sed -i -e 's/COMPILER/JEDI_COMPILER/g' *.sh

    export OPT="$HOME/opt"
    echo "export OPT=$OPT" >> $HOME/.bashrc
    echo "module use $OPT/modulefiles/core" >> $HOME/.bashrc

    ;;
#==========================================================================================
*)
    set +x
    echo "supported options:"
    echo ${supported_options[*]}
    set -x
    ;;
esac

exit 0
