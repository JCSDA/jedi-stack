#!/bin/bash

# The purpose of this script is to install lmod (if needed)
# along with some other fundamental tools such as:
# git, wget, cmake, curl, etc. For an up-to-date list, see the README.md
# file at the top level of this repository.
# 
# These installations are typically done my means of package installs, 
# Basically, anything that you may want to install with package installers
# belongs here as opposed to build_stack.sh.
# However, there are a few packages such as Lmod and CMake that you might
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
# Arguments:
# configuration name (leave blank to print list of supported values)
# 
# sample usage
# ./setup_environment.sh "ubuntu/18.04"
#

# currently supported options
supported_options=("docker-devel" "ubuntu/18.04")

export JEDI_STACK_ROOT=$PWD/..

set -ex

#================================================================================

case $1 in
"docker-devel")
    
    # this is currently configured for use with the JEDI Docker container,
    # which is built from ubuntu 16.04.  It is run with root privileges
    # so no need for sudo's.
    #
    # This includes developer tools such as gnu compilers and debuggers
    # That makes it a "devel" container, as opposed to a more streamlined
    # application container, which we will call "docker-release"

    set +x; echo "Installing JEDI environment for docker"; set -x
    
    apt-get clean
    apt-get update

    # Add external repos here

    # This one provides some package builds for gcc, doxygen
    apt-add-repository ppa:ubuntu-toolchain-r/test    

    # this repo is used for cmake but it hasn't been updated since 2016
    # only goes up to v 3.5 - it may be worth reconsidering
    apt-add-repository ppa:george-edison55/cmake-3.x

    apt-get update
    
    # useful system tools 
    # libexpat is required by udunits
    apt-get install -y --no-install-recommends software-properties-common
    apt-get install -y --no-install-recommends build-essential tcsh csh ksh \	    
                    openssh-server libncurses-dev libssl-dev libx11-dev less \
                    man-db tk tcl swig bc locales file flex bison \
                    libexpat1-dev libxml2-dev unzip wish
		    
    # editors
    apt-get install -y --no-install-recommends emacs vim nedit
    
    # curl and wget
    apt-get install -y --no-install-recommends curl wget libcurl4-openssl-dev 
    
    # This is needed because the default gnu compilers and other tools are ancient
    # we might want to purge other installations first to keep the size of the
    # docker image down.
    apt-get install gcc-7 gfortran-7 g++-7
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 10
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 10
    update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-7 10
    update-alternatives --set gcc /usr/bin/gcc-7
    update-alternatives --set g++ /usr/bin/g++-7
    update-alternatives --set gfortran /usr/bin/gfortran-7

    # autoconfig
    apt-get install -y --no-install-recommends autoconf pkg-config
    		
    # cmake
    apt-get install -y --no-install-recommends cmake
    
    # git and git-lfs
    apt-get install -y --no-install-recommends git git-flow
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash 
    apt-get install -y --no-install-recommends git-lfs 
    git lfs install 

    # python
    apt-get install -y --no-install-recommends python-pip python-dev python-yaml \
	            python-numpy python-scipy
    apt-get install -y --no-install-recommends python3-pip python3-dev \
	            python3-yaml python3-numpy python3-scipy
    
    # for documentation
    apt-get install -y --no-install-recommends graphviz doxygen

    # latex
    apt-get install -y --no-install-recommends texlive-latex-recommended texinfo
    
    # for debugging
    apt-get install -y --no-install-recommends ddd gdb kdbg valgrind   
        
    # lynx non-graphical web browser - we may want to get rid of this
    apt-get install -y --no-install-recommends lynx

    # tkdiff diff viewer, editor, and merge preparer
    libs/build_tkdiff.sh 
    
    apt-get clean
    rm -rf /var/lib/apt/lists/*

    ;;
#==========================================================================================
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
    sudo apt-get install -y --no-install-recommends cmake

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
*)
    set +x
    echo "supported options:"
    echo ${supported_options[*]}
    set -x
    ;;
esac
    
exit 0
