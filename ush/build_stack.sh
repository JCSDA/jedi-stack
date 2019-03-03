#!/bin/sh

set -x

export PREFIX="${HOME}/opt"
export CHECK="NO"
export PKGDIR="${PWD}/../pkg"

# First build the GNU compiler
./build_gnu.sh

compilerName="gnu"
compilerVersion="7.3.0"
export COMPILER="$compilerName-$compilerVersion"

# Next build GNU compiler suite
./build_jasper.sh "jasper" "1.900.1"
./build_zlib.sh "zlib" "1.2.8"
./build_szip.sh "szip" "2.1.1"
./build_udunits.sh "udunits" "2.2.26"
./build_eigen.sh "eigen" "3.3.5" "b3f3d4950030"
./build_fftw.sh "fftw" "3.3.8"
./build_hdf5.sh "hdf5" "1.10.3"
./build_netcdf.sh "netcdf" "4.6.1" "4.4.4" "4.3.0"
./build_boost.sh "boost" "1_68_0"
./build_eccodes.sh "eccodes" "2.8.2"

# Then build GNU + OpenMPI compiler suite
mpiName="openmpi"
mpiVersion="3.1.2"
export MPI="$mpiName-$mpiVersion"

./build_mpi.sh $mpiName $mpiVersion
./build_fftw.sh "fftw" "3.3.8"
./build_hdf5.sh "hdf5" "1.10.3"
./build_netcdf.sh "netcdf" "4.6.1" "4.4.4" "4.3.0"
./build_boost.sh "boost" "1_68_0"
./build_baselibs.sh "baselibs" "5.2.2"

# Finally build GNU + MPICH compiler suite
mpiName="mpich"
mpiVersion="3.2.1"
export MPI="$mpiName-$mpiVersion"

./build_mpi.sh $mpiName $mpiVersion
./build_fftw.sh "fftw" "3.3.8"
./build_hdf5.sh "hdf5" "1.10.3"
./build_netcdf.sh "netcdf" "4.6.1" "4.4.4" "4.3.0"
./build_boost.sh "boost" "1_68_0"
./build_baselibs.sh "baselibs" "5.2.2"

exit 0
