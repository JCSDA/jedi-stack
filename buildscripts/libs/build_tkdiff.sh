#!/bin/bash

set -ex

# tkdiff is a side-by-side diff viewer, editor, and merge provider
# this script installs into /usr/local/bin so it requires root privileges

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}

software=tkdiff-4-3-5
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

wget https://sourceforge.net/projects/tkdiff/files/tkdiff/4.3.5/$software.zip
unzip $software.zip
sudo mv $software/tkdiff /usr/local/bin

exit 0
