help([[
Load environment for running JEDI applications with GNU compilers and OpenMPI.
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

load("jedi-intel/17.0.1")
try_load("szip/2.1.1")
load("jedi-impi/17.0.1")

load("hdf5/1.10.5")
load("pnetcdf/1.11.2")
load("netcdf/4.7.0")

load("lapack/3.7.0")
load("boost-headers/1.68.0")
load("eigen/3.3.5")
load("bufrlib/11.3.2")
load("json/3.9.1")
load("json-schema-validator/2.1.0")

load("ecbuild/jcsda-release-stable")
load("eckit/1.1.0")
load("fckit/jcsda-develop")

setenv("CC","mpiicc")
setenv("FC","mpiifort")
setenv("CXX","mpiicpc")

whatis("Name: ".. pkgName)
whatis("Version: ".. pkgVersion)
whatis("Category: Application")
whatis("Description: JEDI Environment with Intel17")
