#!/bin/bash
# © Copyright 2020 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.
#
# These are python tools for use with JEDI

set -ex

name="pyjedi"

if [[ $MODULES ]]; then
  set +x
  source $MODULESHOME/init/bash
  # Tell the module to skip activating the pyjedi
  # environment, since it doesn't exist yet
  #SKIP_ACTIVATE_PYJEDI="Y" module load jedi-$JEDI_PYTHON
  module load jedi-$JEDI_PYTHON
  module list
  set -x
fi

# Convert pythonName to lower case, stay posix compliant
pythonName=$(echo $JEDI_PYTHON | cut -d/ -f1 | tr '[:upper:]' '[:lower:]')
pythonVersion=$(echo $JEDI_PYTHON | cut -d/ -f2)
version=$pythonVersion

# Skip version for now ...
prefix="${PREFIX:-"/opt/modules"}/$name/$version"

if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                               || ( echo "ERROR: $prefix EXISTS, ABORT!"; exit 1 )
fi

# Are we using some flavor of conda or not?
[[ ${pythonName} = *conda* ]] && USE_CONDA=true || USE_CONDA=false

if [[ "$USE_CONDA" = true ]]; then
  # For conda, use uppercase PREFIX, the environment gets installed in prefix=PREFIX/pyjedi
  export CONDA_ENVS_PATH=$PREFIX
  set +x
  source ${CONDA_ROOT}/etc/profile.d/conda.sh
  conda activate
  $SUDO conda create --name pyjedi --yes
  conda activate pyjedi
  set -x
else
  # For pip, use lowercase prefix which is PREFIX/pyjedi
  export PYTHONPATH="${prefix}:${PYTHONPATH}"
fi

#####################################################################
# Python Package installs
#####################################################################

if [[ "$USE_CONDA" = true ]]; then
  $SUDO conda install numpy --yes
  $SUDO conda install pandas --yes
  $SUDO conda install pycodestyle --yes
  $SUDO conda install autopep8 --yes
  $SUDO conda install cffi --yes
  $SUDO conda install pycparser --yes
  $SUDO conda install pytest --yes
  # Conda version of ford does not work with the latest Python, use conda's pip
  $SUDO pip install ford
  $SUDO conda install xarray --yes
  # pyodc not available via conda channels, use conda's pip
  $SUDO pip install pyodc
else
  $SUDO python3 -m pip install -t $prefix pip setuptools
  $SUDO python3 -m pip install -t $prefix numpy
  $SUDO python3 -m pip install -t $prefix wheel netCDF4 matplotlib
  $SUDO python3 -m pip install -t $prefix pandas
  $SUDO python3 -m pip install -t $prefix pycodestyle
  $SUDO python3 -m pip install -t $prefix autopep8
  $SUDO python3 -m pip install -t $prefix cffi
  $SUDO python3 -m pip install -t $prefix pycparser
  $SUDO python3 -m pip install -t $prefix pytest
  $SUDO python3 -m pip install -t $prefix ford
  $SUDO python3 -m pip install -t $prefix xarray
  $SUDO python3 -m pip install -t $prefix pyodc
fi

# generate modulefile from template
$MODULES && update_modules python $name $version \
         || echo $software >> ${JEDI_STACK_ROOT}/jedi-stack-contents.log
