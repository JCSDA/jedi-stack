# Platforms

Here are are tips for building the jedi-stack on particular Platforms

## <a name="MacPython"></a>Setting up python for Mac OSX
It is recommended for now to skip the automatic build of the pyjedi package. This has been shut off by default in the mac configuration file. It is also recommended to use miniconda for python2 and python3.

For miniconda, get the downloads on the site: https://docs.conda.io/en/latest/miniconda.html. Select the 64-bit bash installer for both python 2.7 and 3.7. These each download a script to install miniconda on your Mac. Run each script as:
~~~~~~~
sh Miniconda2-latest-MacOSX-x86_64.sh
sh Miniconda3-latest-MacOSX-x86_64.sh
~~~~~~~

When prompted allow the install to go into your home directory, and allow the script to modify your .bash_profile file. Edit your .bash_profile file and make sure that your PATH is being set the way you want it. Keep in mind that for now the ODB API python interface only works with python 2.7 (so you should make sure that "python" will be found in your miniconda2 area).

Once you have miniconda2 and 3 installed, run the conda command to install extra python packages you will need for JEDI. For both miniconda2 and 3, run:
~~~~~~~
conda install setuptools
conda install wheel
conda install netcdf4
conda install matplotlib
conda install pycodestyle
conda install autopep8
conda install swig
conda install numpy
conda install scipy
conda install pyyaml
conda install sphinx
~~~~~~~

Then, build the ncepbufr python packages. Again for both miniconda2 and 3, run:
~~~~~~~
git clone https://github.com/JCSDA/py-ncepbufr.git # Only need to do this once. The build/install processes for both
                                                   # python2 and 3 can be run from the same clone of py-ncepbufr.

cd py-ncepbufr
python setup.py build
python setup.py install
~~~~~~~

## Mac OSX Clang environment module
One result of the build process for Mac OSX is that a module script has been installed for setting up your environment for using Clang on the Mac. This can be accessed by running:
~~~~~~~
module purge                        # clear out the environment
module load jedi/clang-openmpi      # set environment for subsequent JEDI builds on the Mac using Clang and OpenMPI
module list
~~~~~~~

## Gentoo

The ``gentoo`` system setting is designed for building Intel toolchains on systems like [Gentoo Linux](https://gentoo.org/get-started/),
where the base system and all JEDI dependencies are compiled using GCC and installed in the `/usr` directory.  In order to also build JEDI packages with
Intel compilers, all Fortran packages that provide compiled modules must be independently compiled
with the Intel `ifort` compiler.

To setup environment, choose a modules home directory.  This can be anywhere, but a common location is `$HOME/opt/modules`.  Also the Intel compilers must be installed to a location pointed to by the `INTEL_ROOT` environment variable.  We assume licenses are available under the `$INTEL_ROOT/licenses` path, but the path can also be supplied via `INTEL_LICENSE_FILE` environment variable.
~~~~~~~~~
$ export INTEL_ROOT=<path-to-intel-root>
$ export JEDI_OPT=$HOME/opt/modules
$ buildscipts/setup_environment.sh gentoo
$ buildscipts/setup_modules.sh gentoo
$ buildscipts/build_stack.sh gentoo
~~~~~~~~~

The enthronement setup with `setup_environment.sh gentoo` generates a `$HOME/.jedi-stack-bashrc` with all the environment
variables necessary for configuring the JEDI modules, based on the supplied `JEDI_OPT`.  This script can then be sourced in `.bashrc` if desired:
~~~~~~~~~
source $HOME/.jedi-stack-bashrc
~~~~~~~~~

Now load intel-impi modules under the `jedi` prefix:
~~~~~~~~~
$ module load jedi/intel-impi
~~~~~~~~~

## S4 (SSEC)

S4 only supports intel modules.  But, when building JEDI, you must link to newer gcc headers and libraries in order to enable C++-14 support.  You may not be able to build JEDI unless you use these flags for the stack as well as the JEDI code itself.  See the [S4 configuration file for details](../buildscripts/config/config_S4.sh).

Another important tip is that you cannot load the intel compiler module until you have loaded the intel license module.  Furthermore, the default version of python is 2.7 so it is recommended that you load the miniconda module for python3.  So, before running `build_stack.sh`, we recommend you load the following modules:

```bash
module load license_intel miniconda
```

When building the jedi-code itself, it is recommended that you use the [S4 toolchain located in the jedi-cmake repository](https://github.com/JCSDA/jedi-cmake/blob/develop/cmake/Toolchains/jcsda-S4-Intel.cmake):

```bash
ecbuild --toolchain=<path>/jedi-cmake/cmake/Toolchains/jcsda-S4-Intel.cmake <path-to-bundle>
```

This will add the flags necessary for C++-14 support and it will also identify `srun` as the preferred executable for parallel MPI processes.

## Discover (NCCS)

When building the intel stack on Discover, it is recommended that you use the `comp/intel/19.1.0.166` together with the `comp/gcc/9.2.0` module.  Intel uses gcc headers and libraries to provide support for `c++-14` and later and the default `gcc` is not sufficient to provide this.

The current `jedi/intel-impi/19.1.0.166` module on Discover auto-loads the `comp/gcc/9.2.0` module so if you are using that you do not have to load it explicitly.  But, if you are starting from scratch, you should edit your intel module to auto-load a gnu module that is compatible and that provides C++-14 support.

It also helps to load up-to-date versions of cmake, git and python before you run `build_stack.sh`.   Furthermore, since the top-level metamodules are located is a slightly different place than on other systems (`$JEDI_OPT/modulefiles/apps`) it is useful to append your modulepath as shown here.  So, in short, we recommend you execute the following commands before running `build_stack.sh`:

```
module use $JEDI_OPT/modulefiles
module use $JEDI_OPT/modulefiles/core
module load git python/GEOSpyD cmake
```

For most of the libraries, it is also advisable to use the `-m64` flag when compiling with intel, as specified in the [configuration file](../buildscripts/config/config_Discover.sh).  However, this flag should be omitted for bufrlib and for jedi itself.

For hdf5 in particular, the following flags are recommended

```bash
export CFLAGS="-w -g -O -fPIC -m64"
export CXXFLAGS="-w -g -O -fPIC -m64"
export FFLAGS="-fPIC -g -O -m64"
export F90FLAGS="-fPIC -g -O -m64"
export FCFLAGS="$FFLAGS"
```

## Orion

When building the stack on Orion, it is helpful to load these modules first:
```bash
module load cmake git python
```

For building the gnu-openmpi stack, it is easiest to setup the modulefiles manually.  To set up the directory structure you can set `JEDI_COMPILER=gnu/8.3.0` and `JEDI_MPI=openmpi/4.0.2` in the config file and then set both `JEDI_COMPILER_BUILD` and `MPI_BUILD` to `native-pkg`.  Then copy the appropriate modulefiles over to the directories and edit them to load the native gnu and openmpi modules.  After this, you can run `build_stack.sh` as usual.

For the intel stack in particular, running the tests is very sensitive to the precise form of the sbatch batch script.  Here is an example of a script that works for ufo-bundle (as on other systems, the compute nodes do not have internet access so the `get_*` tests must be run from the login node before running the batch tests):

```
#!/usr/bin/bash
#SBATCH --job-name=ctest-ufo-intel
#SBATCH -A <your-account>
#SBATCH -p orion
#SBATCH -q batch
#SBATCH -N 4-10
#SBATCH -t 30:00
#SBATCH -o ctest-ufo-intel.out
#SBATCH -e ctest-ufo-intel.err
#SBATCH --mail-user=<your-email>
source /etc/bashrc
module purge
export JEDI_OPT=/work/noaa/da/mmiesch/modules
module use -a $OPT/modulefiles/core
module load jedi/intel-impi
module list
ulimit -s unlimited
export SLURM_EXPORT_ENV=ALL
export HDF5_USE_FILE_LOCKING=FALSE
cd <build-directory>
ctest -E get_
exit 0
```

If a test fails, try re-running it with the precise number of tasks specified, for example by adding this line to the script: `#SBATCH -n 5`.

## Cheyenne (NCAR)

One thing to watch out for with Cheyenne is that native modules often have the same names as the modules in the jedi-stack(e.g. `pnetcdf`, `hdf5`...) and they are set up to be the defaults.  So make sure you're using the modules you want in the build.

Recommended native modules to load before building the stack are:
```bash
module load cmake git python
```

When building JEDI for intel, use the [Cheyenne intel toolchain]() to properly link to

## Intel C++14 support

Here we give some general tips on building the jedi-stack and jedi itself with Intel on HPC systems.

JEDI now makes use of the C++14 standard.  So, compilers must be capable of interpreting this standard or JEDI will not build.

This is usually not a problem if you are using gnu or clang compilers.  Any recent version will have C++-14 support.  It's also usually not a problem for cloud platforms and workstations/laptops, even if you are using intel compiler.  In these cases the default gcc on the system is usually recent enough to support C++14 and, if it isn't, you often have the admin priviliges to update it.

The problem comes in when you are using Intel compilers on HPC systems.  The intel C++ compiler, `icpc`, leverages the gnu C++ compiler, `g++` to provide headers and libraries, including the headers and libraries that are used to implement the C++-14 standard.  For stability, most HPC systems do not update their default `gcc` compilers; what's there is typically what was installed when the operating system was installed.  This can be very outdated.  If you run `gcc --version` from the command line without loading any modules, you may see version 5 or less.  Version 7.3 or greater is recommended for C++14 support.  For further information, [see here](https://software.intel.com/content/www/us/en/develop/documentation/cpp-compiler-developer-guide-and-reference/top/compatibility-and-portability/gcc-compatibility-and-interoperability.html) or google "intel icpc gcc compatability and interoperability".

Furthermore, even though many of the libraries in the jedi-stack do not require C++-14 support, you will want to enable C++-14 support when you build them to avoid potential linking conflicts when you do eventually build jedi.

If you are using Intel compilers on an HPC system with an older version of gcc, there are (at least) three ways to proceed to enable C++-14 support for the jedi-stack, and consequently for jedi itself.

The first way is the easiest, but it doesn't always work.  First, load a recent `gcc` module, such as gcc 9.3.0, if available.  Then run `module avail` to search for a compatible intel module.  On some systems the proper command might be `module avail intel` but other systems may put their intel modules under different paths or names.  If you find a recent intel module in the listing, try to load it.  If you are lucky, these will be compatible and you can proceed to build the jedi-stack with both the compatible intel and gcc modules loaded.

However, many systems will only allow you to load one compiler at a time.  So, if you try to load an intel module, you may see a message telling you that it unloaded the gcc module and replaced it with the intel module. Then the active gcc is still the old one and you won't be able to build with C++-14 support.  You will then have to try the second or third approach.

The second approach is to define the following flags in your configuration script:

```bash
export CXXFLAGS="-gxx-name=<gcc-path>/bin/g++ -Wl,-rpath,<gcc-path>/lib64"
export LDFLAGS="-gxx-name=<gcc-path>/bin/g++ -Wl,-rpath,<gcc-path>/lib64"
```

where `<gcc-path>` is the path to the gcc installation you wish to use.  In many cases you can determine this by loading a recent gcc module and entering `which g++`.

Then build the stack as usual.  When you are ready to build jedi, you can specify these flags as environment variables or on the `ecbuild` command line:

```bash
ecbuild -DCMAKE_CXX_FLAGS="-gxx-name=<gcc-path>/bin/g++ -Wl,-rpath,<gcc-path>/lib64" -DCMAKE_LINKER_FLAGS="-gxx-name=<gcc-path>/bin/g++ -Wl,-rpath,<gcc-path>/lib64" <path-to-bundle>
```

Or you can specify them in a CMake toolchain.  See the `jcsda-Cheyenne-Intel.cmake` toolchain in the [jedi-cmake repository](https://github.com/jcsda/jedi-cmake) for an example.

The third way to enable C++-14 is to define your own gcc module that does not conflict with your preferred intel module.  This can prepend the executable and linker paths to activate a particular gcc version.  For an example, see the [jedi-gcc modulefile for S4](../modulefiles/system/S4/core/jedi-gcc/8.3.lua).
