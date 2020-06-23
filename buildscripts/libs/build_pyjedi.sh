#!/bin/bash

# These are python tools for use with JEDI

set -ex

name="pyjedi"

[[ $USE_SUDO =~ [yYtT] ]] || ! $MODULES && prefix=${PYJEDI_ROOT:-"/usr/local"} \
	                  || prefix="$HOME/.local"

#####################################################################
# Python Package installs
#####################################################################

$SUDO python3 -m pip install -U pip setuptools
$SUDO python3 -m pip install -U numpy
$SUDO python3 -m pip install -U wheel netCDF4 matplotlib
$SUDO python3 -m pip install -U pandas
$SUDO python3 -m pip install -U pycodestyle
$SUDO python3 -m pip install -U autopep8
$SUDO python3 -m pip install -U cffi
$SUDO python3 -m pip install -U pycparser
$SUDO python3 -m pip install -U pytest
$SUDO python3 -m pip install -U ford
$SUDO python3 -m pip install -U xarray
$SUDO python3 -m pip install -U pyodc

#####################################################################
# ncepbufr for python
#####################################################################

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
git clone https://github.com/JCSDA/py-ncepbufr.git 
cd py-ncepbufr 

CC=gcc python3 setup.py build 
$SUDO python3 setup.py install 
