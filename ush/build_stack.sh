#!/bin/sh

set -x

export PREFIX="${HOME}/opt"
export CHECK="NO"
export PKGDIR="${PWD}/../pkg"

# First build the GNU compiler
./build_gnu.sh

export COMPILER="gnu-7.3.0"

# Next build GNU compiler suite
./build_jasper.sh "jasper-1.900.1"
./build_zlib.sh "zlib-1.2.8"
./build_szip.sh "szip-2.1.1"
./build_eigen.sh "eigen-eigen-b3f3d4950030" "3.3.5"
./build_udunits.sh "udunits-2.2.26"
./build_fftw.sh "fftw-3.3.8"
./build_hdf5.sh "hdf5-1.10.3"
./build_netcdf.sh "netcdf-c-4.6.1" "netcdf-fortran-4.4.4" "netcdf-cxx4-4.3.0"
./build_boost.sh "boost_1_68_0"
./build_nco.sh "nco-4.7.3"
./build_eccodes.sh "eccodes-2.8.2-Source"

# Then build GNU + OpenMPI compiler suite
export MPI="openmpi-3.1.2"

./build_mpi.sh $MPI
./build_fftw.sh "fftw-3.3.8"
./build_hdf5.sh "hdf5-1.10.3"
./build_netcdf.sh "netcdf-c-4.6.1" "netcdf-fortran-4.4.4" "netcdf-cxx4-4.3.0"
./build_boost.sh "boost_1_68_0"
./build_baselibs.sh "baselibs-5.2.2"

# Finally build GNU + MPICH compiler suite
export MPI="mpich-3.2.1"

./build_mpi.sh $MPI
./build_fftw.sh "fftw-3.3.8"
./build_hdf5.sh "hdf5-1.10.3"
./build_netcdf.sh "netcdf-c-4.6.1" "netcdf-fortran-4.4.4" "netcdf-cxx4-4.3.0"
./build_boost.sh "boost_1_68_0"
./build_baselibs.sh "baselibs-5.2.2"

exit 0
