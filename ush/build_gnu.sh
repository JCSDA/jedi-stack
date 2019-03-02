#!/bin/sh --login

# Installation instructions from:
# https://solarianprogrammer.com/2017/05/21/compiling-gcc-macos/

set -ex

install_gmp=YES
install_mpfr=YES
install_mpc=YES
install_isl=YES
install_gcc=YES

# GNU compilers and dependencies
gmp=gmp-6.1.2
mpfr=mpfr-4.0.1
mpc=mpc-1.1.0
isl=isl-0.18
#gcc=gcc-8.2.0
gcc=gcc-7.3.0

gcc_ver=$(echo $gcc | cut -d"-" -f2)

mkdir -p ../build ; cd ../build
root_dir=$(pwd)

# Installation path
prefix="${PREFIX:-"$HOME/opt"}/gnu/$gcc_ver"
if [[ -d $prefix ]]; then
    echo "Installation directory already exists at:"
    echo "$prefix"
    echo "ABORT!"
    exit 9
fi

# 1. install gmp
if [ $install_gmp = "YES" ]; then
    cd $root_dir
    software=$gmp
    echo "BUILDING ... $software"
    dir_software=${PKGDIR:-"../pkg"}/$software
    [[ -d $dir_software ]] && cd $dir_software || (echo "$dir_software does not exist, ABORT!"; exit 1)
    build=$root_dir/$software/build
    [[ -d $build ]] && rm -rf $build
    mkdir -p $build && cd $build
    ../configure --prefix=$prefix
    make -j${NTHREADS:-4}
    make install
fi

# 2. install mpfr
if [ $install_mpfr = "YES" ]; then
    cd $root_dir
    software=$mpfr
    echo "BUILDING ... $software"
    dir_software=${PKGDIR:-"../pkg"}/$software
    [[ -d $dir_software ]] && cd $dir_software || (echo "$dir_software does not exist, ABORT!"; exit 1)
    build=$root_dir/$software/build
    [[ -d $build ]] && rm -rf $build
    mkdir -p $build && cd $build
    ../configure --prefix=$prefix \
                 --with-gmp=$prefix
    make -j${NTHREADS:-4}
    make install
fi

# 3. install mpc
if [ $install_mpc = "YES" ]; then
    cd $root_dir
    software=$mpc
    echo "BUILDING ... $software"
    dir_software=${PKGDIR:-"../pkg"}/$software
    [[ -d $dir_software ]] && cd $dir_software || (echo "$dir_software does not exist, ABORT!"; exit 1)
    build=$root_dir/$software/build
    [[ -d $build ]] && rm -rf $build
    mkdir -p $build && cd $build
    ../configure --prefix=$prefix \
                 --with-gmp=$prefix \
                 --with-mpfr=$prefix
    make -j${NTHREADS:-4}
    make install
fi

# 4. install isl
if [ $install_isl = "YES" ]; then
    cd $root_dir
    software=$isl
    echo "BUILDING ... $software"
    dir_software=${PKGDIR:-"../pkg"}/$software
    [[ -d $dir_software ]] && cd $dir_software || (echo "$dir_software does not exist, ABORT!"; exit 1)
    build=$root_dir/$software/build
    [[ -d $build ]] && rm -rf $build
    mkdir -p $build && cd $build
    ../configure --prefix=$prefix \
                 --with-gmp=$prefix
    make -j${NTHREADS:-4}
    make install
fi

# Finally install GNU compilers
if [ $install_gcc = "YES" ]; then
    cd $root_dir
    software=$gcc
    echo "BUILDING ... $software"
    dir_software=${PKGDIR:-"../pkg"}/$software
    [[ -d $dir_software ]] && cd $dir_software || (echo "$dir_software does not exist, ABORT!"; exit 1)
    build=$root_dir/$software/build
    [[ -d $build ]] && rm -rf $build
    mkdir -p $build && cd $build
    ../configure --prefix=$prefix \
                 --enable-checking=release \
                  --with-gmp=$prefix \
                  --with-mpfr=$prefix \
                  --with-mpc=$prefix \
                  --enable-languages=c,c++,fortran \
                  --with-isl=$prefix
    make -j${NTHREADS:-4}
    make install
fi

exit 0
