# Software Stack for JEDI applications

This repository provides a unified, module-based build system for building the JEDI software stack.
The motivation is to define a common set of software packages and versions to be used for applications, development, testing and across multiple platforms including software containers (Docker, Singularity, Charliecloud), cloud computing instances (e.g. AWS, Azure, Google), and HPC systems (e.g. NOAA, NASA, NCAR).

We want to provide a common set of software libraries to JEDI users and developers in order to minimize problems associated with incompatible or outdated software versions.  However, we also wish to take advantage of site-specific configurations and optimizations that exploit the local hardware.  For this reason, the build process is designed to use native installations of the compiler suite and the MPI libraries.  The rest of the software stack is build from source for the specified compiler/mpi combination.

# Section 1: Current JEDI Stack Components


## Required, but not sensitive to version: These can be installed via jedi-stack but are often easier to install via package manager or native modules

| software  | minimum version | Notes |
| -------   | --------------- | ----- |
| compiler  | ---             | C++, C, and Fortran; commonly used: gnu (gcc/gfortran), clang, intel; must support C++-14
| MPI library | ---           | commonly used: Openmpi, mpich, Intel MPI
| cmake     | 3.16            |       |
| git-lfs   | 2.11            |       |


## Required components of the stack on most HPC systems, laptops, and containers - installed via jedi-stack (current release versions)

| software | version | Notes |
| -------- | ------- | ----- |
| udunits  | 2.2.26  | updated to 2.2.28 in develop |
| zlib     | 1.2.11  |       |
| szip     | 2.1.1   |       |
| lapack   | 3.8.0   | Can be replaced by intel mkl |
| Boost    | 1.68.0  | headers only |
| Eigen    | 3.3.7   |       |
| ecbuild  | jcsda/3.3.2.jcsda3 | Now `ecmwf/3.6.1` in develop |
| hdf5     | 1.12.0  |    |
| pnetcdf  | 1.12.1  |    |
| netcdf   | 4.7.4, 4.5.3, 4.3.0 | versions for C, Fortran, and C++ |
| nccmp    | 1.8.7.0 | Needed for running tests |
| eckit    | jcsda/1.11.6.jcsda2 | Now `ecmwf/1.16.0` in develop |
| bufrlib     | 11.3.2 | deprecated: replaced by NCEP-bufr   |
| pybind11    | 2.5.0 |   |
| gsl_lite    | 0.34.0 | upgraded to 0.37.0 in develop  |

## New components since most recent release

| software | version | Notes |
| -------- | ------- | ----- |
| CGAL     | 5.0.2   | Optional in principle but may become required in practice for efficiency reasons.  Can be installed without gmp, mpfr dependencies |
| bufr     | 11.4.0.jcsda1  | NCEP version replaces previous bufrlib |

## Required for certain components or models

| software | version | Notes |
| -------- | ------- | ----- |
| PIO      | 2.5.1   | Needed for MPAS |

## Required, but not necessarily in HPC modules

| software | version | Notes |
| -------- | ------- | ----- |
| pyjedi   | ---   | Python tools installed in user space.  Should be deprecated soon in lieu of python dependencies handled by individual repos, solo, new bufr libraries, and/or virtual environments |
| json | 3.9.1 | |
| json-schema-validator | 2.1.0 | used for testing |
| doxygen+dot | --- | used for generating documentation |
| latex | --- | used for generating documentation |

## Optional

These can be build by jedi-stack but they are not required for jedi.

| software | version | Notes |
| -------- | ------- | ----- |
| NCO      | 4.7.9   | Can use a native module or package installation? |
| fckit | jcsda/0.7.0.jcsda1 | Now using `ecmwf/0.9.2` and now included in default stack |
| atlas | jcsda/0.20.2.jcsda1 | Now using `ecmwf/0.24.1` and now included in default stack |
| fms | jcsda/release-stable | Currently not included in stack but moving toward including it|
| gptl | 8.0.3 | profiling tool |
| fftw | 3.3.8 | |
| Boost (full) | 1.68.0 | |
| esmf | 8_0_1 | |
| baselibs | 5.2.2 | |
| pdtoolkit | 3.25.1 | Tau dependency |
| tau2 | 3.25.1 | |
| armadillo | 1.900.1 | No longer used? |
| odc | jcsda/1.0.3 | |
| png | 1.6.35 | |
| jpeg | 9.1.0 | |
| jasper | 1.900.1 | |
| xerces | 3.1.4 | |
| nceplibs | fv3 | |
| tkdiff | 4.3.5 | |
| geos | 3.8.1 | |
| sqlite | 3.32.3 | |
| proj | 7.1.0 | |
| ecflow | 5.5.3 | Requires boost, boost-python3, openssl, and qt (install via [brew](https://brew.sh/)); see [Notes on building the Software Stack for JEDI applications on Mac OS](buildscripts/Mac/README.md)|

# Section 2: Building the JEDI Stack

[The procedure to build the jedi-stack is described here](doc/Build.md)


# Section 3: Adding a New library/package

It is desirable to limit the number of software packages included in jedi-stack for several reasons.

Adding dependencies to JEDI may adversely affect its portability.  New dependencies could pose problems for some platforms and compilers or could conflict with other stack components.  As the stack grows, it takes more work to maintain on multiple systems.

Adding optional build scripts for packages not required by JEDI also increases maintenance work to test them and keep them up to date.  We do not want to support build scripts that are not commonly used.

For these reasons, additions to the JEDI stack must first be approved by the JEDI Software Infrastructure team.

## Vetting process

If you want to add a new library or software package to the jedi-stack you must first do the following:

1. Create a Zenhub issue that describes the reason for the addition.  Which JEDI components require it?  Why is it beneficial to add to the stack?  Can it be installed or acquired a different way?  (If you do not have access to the internal JCSDA ZenHub boards you can create a thread on the [JCSDA forums](https://forums.jcsda.org)).  Bring it to the attention of the JEDI Software Infrastructure team (JEDI 1) by "asssigning" or tagging individual members.

2. The issue will be discussed at one or more meetings of the JEDI 1 team, possibly in consultation with the broader JEDI team.  You may be contacted for further information.

3. The JEDI 1 Team will either approve or decline the request for an addition to the jedi-stack.   You will be informed of the decision through the ZenHub issue (or forum thread) or by other means (e.g. meetings, email, etc).

## Required Code Changes

If your request to add a package to the JEDI stack is approved by the JEDI 1 team, then you can proceed to add it to the jedi-stack with the following code changes:

1. write a new build script in `buildscripts/libs`, using existing scripts as a template
2. define a new control flag and add it to the `choose_modules.sh` and `config_container*` scripts in `buildscripts/config`
3. Add a call to the new build script in `buildscripts/build_stack.sh`
4. Create a new module template at the appropriate place in the `modulefiles` directory, using existing files as a template
5. Add the package to the list of jedi-stack components in the (top-level) `README.md` file
