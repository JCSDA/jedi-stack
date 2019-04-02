# OSX Software Stack

This repository will facilitate building widely used packages [by me] from source on OSX, instead of using existing package managers e.g. [HomeBrew](https://brew.sh/), etc.

The following software can be built on OSX with the scripts under `ush` and instructions that follow:
* GNU
* Jasper
* Zlib
* SZip
* OpenMPI
* MPICH
* HDF5
* NetCDF
* Udunits
* NetCDF Climate Operators
* Boost
* Eigen
* FFTW
* ecCodes
* ESMF
* ESMA-Baselibs

### Pre-requisites
* Lua Modules - for software stack management
* wget, curl, git - for fetching packages
* Other

### Packages
The individual packages should be downloaded, untarred and placed under`pkg`.  Most build scripts will look for directory `pkg/pkgName-pkgVersion` e.g. `pkg/hdf5-1.10.3`.

### Compiler options
Set the default compiler to build the stack.
```
export COMPILER="gnu-7.3.0"
```

### MPI options
Set the default MPI flavour to build the stack.
```
export MPI="" # Disable MPI for some software e.g. HDF5, NetCDF, Boost, etc.
export MPI="openmpi-3.1.2"
export MPI="mpich-3.2.1"
```

### Installation path
Specify the installation path for packages.
`export PREFIX="$HOME/opt"`
If PREFIX is anything other than `/opt`, the user will have to define an environment variable `OPT=$PREFIX` in order for the modulefiles to correctly define the installation path of the packages.

### Verify installation
Check the installation; will execute ctest or make check
```
export CHECK="NO" # Disable checking
export CHECK="YES" # Enable checking
```
### Todos
