#!/bin/bash

# These are python tools for use with JEDI

set -ex

name="pyjedi"

[[ $USE_SUDO =~ [yYtT] ]] || ! $MODULES && prefix="/usr/local" \
	                  || prefix="$HOME/.local"

#####################################################################
# Python Package installs
#####################################################################

$SUDO python -m pip install -U pip setuptools
$SUDO python -m pip install wheel netCDF4 matplotlib

$SUDO python3 -m pip install -U pip setuptools
$SUDO python3 -m pip install wheel netCDF4 matplotlib
$SUDO python3 -m pip install pycodestyle
$SUDO python3 -m pip install autopep8

#####################################################################
# ncepbufr for python
#####################################################################

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
git clone https://github.com/JCSDA/py-ncepbufr.git 
cd py-ncepbufr 

CC=gcc python setup.py build 
$SUDO python setup.py install 

CC=gcc python3 setup.py build 
$SUDO python3 setup.py install 

$SUDO cp src/libbufr.a $prefix/lib 

exit 0
