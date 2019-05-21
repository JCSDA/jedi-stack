#!/bin/bash

# These are python tools for use with JEDI

set -ex

name="pyjedi"

[[ $USE_SUDO =~ [yYtT] ]] && prefix="/usr/local/lib" \
	                  || prefix="$HOME/.local/lib"

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

[[ $USE_SUDO =~ [yYtT] ]] && unset args || args="--user"
cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
git clone https://github.com/JCSDA/py-ncepbufr.git 
cd py-ncepbufr 

CC=gcc python setup.py build 
[[ $USE_SUDO =~ [yYtT] ]] && sudo python setup.py install \
                          || python setup.py --user install 

CC=gcc python3 setup.py build 
[[ $USE_SUDO =~ [yYtT] ]] && sudo python setup.py install \
                          || python setup.py --user install 

$SUDO cp src/libbufr.a $prefix/lib 

exit 0
