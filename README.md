# Software Stack for JEDI applications

This repository will facilitate building widely used packages by JEDI from source, instead of using existing package managers e.g. [HomeBrew](https://brew.sh/) for OSX, [apt-get](https://linux.die.net/man/8/apt-get) for Linux, etc.

The following software can be built with the scripts under `ush` and instructions that follow:
* GCC
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
The individual packages will be fetched from their respective sources, but can be downloaded, untarred and placed under`pkg` if desired.  Most build scripts will look for directory `pkg/pkgName-pkgVersion` e.g. `pkg/hdf5-1_10_3`.

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
```
export PREFIX="$HOME/opt"
```
If `$PREFIX` is anything other than `/opt`, the user will have to define an environment variable `export OPT=$PREFIX` in order for the modulefiles to correctly define the installation path of the packages.

### Verify installation
Check the installation; will execute ctest or make check
```
export CHECK="YES|NO" # Enable|Disable checking
```
### Todos
Update `ush/deploy_modules.sh` to automagically create appropriate modulefiles for packages from templates.
