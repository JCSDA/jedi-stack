#!/bin/sh

set -x

export PREFIX="/opt"
export CHECK="NO"

# First build the GNU compiler
./build_gnu.sh

export COMPILER="gnu-7.3.0"

# Next build GNU compiler suite
./build_szip.sh
./build_zlib.sh
./build_jasper.sh
./build_eigen.sh
./build_udunits.sh
./build_fftw.sh
./build_hdf5.sh
./build_netcdf.sh
./build_boost.sh
./build_nco.sh
./build_eccodes.sh

./deploy_modules.sh

# Then build GNU + OpenMPI compiler suite
export MPI="openmpi-3.1.2"
./build_mpi.sh
./build_fftw.sh
./build_hdf5.sh
./build_netcdf.sh
./build_boost.sh
./build_baselibs.sh

./deploy_modules.sh

# Finally build GNU + MPICH compiler suite
export MPI="mpich-3.2.1"
./build_mpi.sh
./build_fftw.sh
./build_hdf5.sh
./build_netcdf.sh
./build_boost.sh
./build_baselibs.sh

./deploy_modules.sh

exit 0
