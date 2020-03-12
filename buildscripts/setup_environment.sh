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
supported_options=("ubuntu/18.04","cheyenne","orion","rhel7emc","gentoo")

JEDI_BUILDSCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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
    sudo apt-get install -y --no-install-recommends \
                         build-essential tcsh csh ksh \
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
    sudo apt-get install -y --no-install-recommends \
                         graphviz doxygen

    # for debugging
    sudo apt-get install -y --no-install-recommends \
                         ddd gdb kdbg valgrind

    # python
    sudo apt-get install -y --no-install-recommends \
                         python3-pip python3-dev \
                         python3-yaml python3-numpy python3-scipy

    # install and deploy lmod from source
    sudo apt-get install -y tcllib tcl-dev
    prefix=/opt
    libs/build_lmod.sh $prefix
    source $prefix/lmod/lmod/init/profile

    # The module files will be installed in $OPT/modulefiles
    JEDI_OPT=/opt/modules

    sudo ln -s $MODULESHOME/init/profile /etc/profile.d/z00_lmod.sh
    echo "export JEDI_OPT=$JEDI_OPT" | sudo tee -a /etc/profile.d/z00_lmod.sh
    echo "module use $JEDI_OPT/modulefiles/core" | sudo tee -a /etc/profile.d/z00_lmod.sh

    sudo ln -s $MODULESHOME/init/cshrc   /etc/profile.d/z00_lmod.csh
    echo "setenv JEDI_OPT $JEDI_OPT" | sudo tee -a /etc/profile.d/z00_lmod.csh
    echo "module use $JEDI_OPT/modulefiles/core" | sudo tee -a /etc/profile.d/z00_lmod.csh

    ;;
#==========================================================================================
"rhel7emc")
    set +x; echo "Installing JEDI environment on RHEL7 EMC workstations"; set -x
    if [[ ! -d $HOME/.linuxbrew ]]; then
      set +x
      echo "Homebrew on Linux is required for EMC Linux machines"
      echo "Follow instructions to install Homebrew on Linux from"
      echo "https://docs.brew.sh/Homebrew-on-Linux"
      echo "At a minimum, install the following packages from Homebrew"
      echo "cmake, lmod, sphinx-doc, git, git-lfs"
      echo "ABORT!"
      set -x
      exit 1
    fi
    # The module files will be installed in $OPT/modulefiles
    export JEDI_OPT="$HOME/opt"
    echo "export JEDI_OPT=$JEDI_OPT" >> $HOME/.bashrc
    echo "module use $JEDI_OPT/modulefiles/core" >> $HOME/.bashrc
    ;;
#==========================================================================================
"cheyenne")
    export JEDI_OPT="/glade/work/miesch/modules"
    echo "export JEDI_OPT=$JEDI_OPT" >> $HOME/.bashrc
    echo "module use $JEDI_OPT/modulefiles/core" >> $HOME/.bashrc
    ;;
#==========================================================================================
"orion")
    export JEDI_OPT="$HOME/opt"
    echo "export JEDI_OPT=$JEDI_OPT" >> $HOME/.bashrc
    echo "module use $JEDI_OPT/modulefiles/core" >> $HOME/.bashrc

    ;;
#==========================================================================================
"gentoo")
    set +ex
    LMOD_VERSION=$( { module --version; } 2>&1)
    if [[ ! $? == 0 ]]; then
        echo "Unable to find 'module' command.  Check lmod exists and is configured.  Must source  '/usr/lib/lmod/lmod/init/bash' in shell to activate. "
        exit 1
    fi
    echo "Found lmod version: ${LMOD_VERSION}"
    export JEDI_OPT=${JEDI_OPT:-$OPT}
    if [[ -z $JEDI_OPT ]]; then
        echo "ERROR: must set JEDI_OPT to path to user modules directory."
        echo "Suggested location is $HOME/opt/modules"
        exit 1
    fi
    echo "Using JEDI_OPT=$JEDI_OPT"
    [[ ! -d $JEDI_OPT ]] && mkdir -p $JEDI_OPT
    echo "export JEDI_OPT=$JEDI_OPT" > $HOME/.jedi-stack-bashrc
    echo "export JEDI_APP_MODULES=\"\$JEDI_OPT/modulefiles/apps\"" >> $HOME/.jedi-stack-bashrc
    echo "export JEDI_MODULES=\"\$JEDI_OPT/modulefiles/core\"" >> $HOME/.jedi-stack-bashrc
    echo "export SYSTEM_MODULES=\"\$JEDI_OPT/modulefiles/system\"" >> $HOME/.jedi-stack-bashrc
    echo "export MODULEPATH=\"\$SYSTEM_MODULES:\$JEDI_APP_MODULES:\$JEDI_MODULES\"" >> $HOME/.jedi-stack-bashrc
    echo "source /usr/lib/lmod/lmod/init/bash" >> $HOME/.jedi-stack-bashrc
    echo "module use \$JEDI_APP_MODULES" >> $HOME/.jedi-stack-bashrc
    echo "module use \$JEDI_MODULES" >> $HOME/.jedi-stack-bashrc
    echo "module use \$SYSTEM_MODULES" >> $HOME/.jedi-stack-bashrc
    source $HOME/.jedi-stack-bashrc
    mkdir -p $JEDI_OPT/modulefiles/system
    mkdir -p $JEDI_OPT/modulefiles/apps
    cp -a $JEDI_BUILDSCRIPTS_DIR/../modulefiles/system/gentoo/* $JEDI_OPT/modulefiles/system/
    cp -a $JEDI_BUILDSCRIPTS_DIR/../modulefiles/apps/gentoo/* $JEDI_OPT/modulefiles/apps/

    echo "jedi-stack: setup_environment: gentoo -- Success!"
    echo "To permanently enable the jedi-stack environment add 'source .jedi-stack-bashrc' to your .bashrc"
    ;;
#==========================================================================================
*)
    set +x
    echo "supported options:"
    echo ${supported_options[*]}
    set -x
    ;;
esac

set +x
echo "setup_environment.sh $1: success!"
echo "To proceed run: setup_modules.sh $1"
