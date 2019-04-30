#!/bin/bash

# Installation instructions from:
# https://solarianprogrammer.com/2017/05/21/compiling-gcc-macos/

set -ex

name="gnu"
version=$1

$USE_SUDO && SUDO="sudo" || unset SUDO

cd ${JEDI_STACK_ROOT}/${PKGDIR:-"pkg"}
curr_dir=$(pwd)

# GNU compilers and dependencies
if [[ "$version" = "7.3.0" ]]; then

    gmp=gmp-6.1.2
    mpfr=mpfr-4.0.1
    mpc=mpc-1.1.0
    isl=isl-0.18
    gcc=gcc-7.3.0

elif [[ "$version" = "8.3.0" ]]; then

    url="ftp://gcc.gnu.org/pub/gcc"

    gmp=gmp-6.1.0;   #curl -L $url/infrastructure/$gmp.tar.gz2  | tar xf -
    mpfr=mpfr-3.1.4; #curl -L $url/infrastructure/$mpfr.tar.bz2 | tar xf -
    mpc=mpc-1.0.3;   #curl -L $url/infrastructure/$mpc.tar.gz   | tar xf -
    isl=isl-0.18;    #curl -L $url/infrastructure/$isl.tar.bz2  | tar xf -
    gcc=gcc-8.3.0;   #curl -L $url/releases/$gcc/$gcc.tar.gz    | tar xf -

else

    echo "Unknown GCC $version, ABORT!"; exit 1

fi

# Installation path
prefix="${PREFIX:-"$HOME/opt"}/$name/$version"
[[ -d $prefix ]] && ( echo "$prefix exists, ABORT!"; exit 1 )

cd $curr_dir

# 1. install gmp
echo "BUILDING ... $gmp"
software=$gmp
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build
../configure --prefix=$prefix
make -j${NTHREADS:-4}
$SUDO make install

cd $curr_dir

# 2. install mpfr
echo "BUILDING ... $mpfr"
software=$mpfr
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build
../configure --prefix=$prefix \
             --with-gmp=$prefix
make -j${NTHREADS:-4}
$SUDO make install

cd $curr_dir

# 3. install mpc
echo "BUILDING ... $mpc"
software=$mpc
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build
../configure --prefix=$prefix \
             --with-gmp=$prefix \
             --with-mpfr=$prefix
make -j${NTHREADS:-4}
$SUDO make install

cd $curr_dir

# 4. install isl
echo "BUILDING ... $isl"
software=$isl
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build
../configure --prefix=$prefix \
             --with-gmp=$prefix
make -j${NTHREADS:-4}
$SUDO make install

cd $curr_dir

# Finally install GNU compilers
echo "BUILDING ... $gcc"
software=$gcc
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build
../configure --prefix=$prefix \
             --enable-checking=release \
              --with-gmp=$prefix \
              --with-mpfr=$prefix \
              --with-mpc=$prefix \
              --enable-languages=c,c++,fortran \
              --with-isl=$prefix
make -j${NTHREADS:-4}
$SUDO make install

# generate modulefile from template
cd $JEDI_STACK_ROOT/buildscripts
libs/update_modules.sh core $name $version

exit 0
