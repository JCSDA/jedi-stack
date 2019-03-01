# OSX Software Stack

These repository will build widely used packages [by me] from source on OSX, instead of using existing package managers e.g. [HomeBrew](https://brew.sh/), etc.

The following software can be built on OSX with the scripts under `ush` and instructions that follow:
* GNU
* Jasper [ Not used ]
* Zlib [ Not used ]
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
* ESMA-Baselibs

### Pre-requisites
* Lua Modules - for software stack management
* Other

### Packages
The individual packages should be downloaded and placed under`pkg`

### MPI options
`export MPI=""` # Disable MPI for some software e.g. HDF5, NetCDF, Boost, etc.

`export MPI="openmpi-3.1.2"`

`export MPI="mpich-3.2.1"`

### Installation path
`export PREFIX=""` # [will install under $HOME/opt]

`export PREFIX="/opt"`

### Checking the installation; will execute ctest or make check
`export CHECK=""` # Empty String -- Disable checking [Prefered]

`export CHECK="Y"` # Enable checking [ This can be slow ]

### Todos

 - Remove hard-wired software versions
 - Remove hard-wired prefix paths in modulefiles
