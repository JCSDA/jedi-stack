#!/bin/bash

# Co-locate (via symlink) brew-installed boost / boost-python libraries and headers
#   brew installs these packages in different locations; a typical build from source
#   code would co-locate them, so that setting BOOST_ROOT for use in building other
#   software is made easier.
# Steps:
#   brew install boost boost-python3
#   run this script

# Boost libraries and headers: version and location
boostLib_version=`brew list --versions | grep "boost " | cut -d ' ' -f 2`
boostLib_cellar=`brew --cellar boost`

# Boost python libraries: version and location
boostPython_version=`brew list --versions | grep boost-python3 | cut -d ' ' -f 2`
boostPython_cellar=`brew --cellar boost-python3`

echo 'Linking boost-python3 libraries into boost installation location'
for lib in `ls $boostPython_cellar/$boostPython_version/lib/lib*`; do
    echo "Linking $lib  into  $boostLib_cellar/$boostLib_version/lib"
    sudo ln -s $lib $boostLib_cellar/$boostLib_version/lib
done

