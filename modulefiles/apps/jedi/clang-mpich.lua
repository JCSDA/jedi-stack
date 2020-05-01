help([[
Load environment for running JEDI applications with clang/gfortran compilers and OpenMPI.
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

load("jedi-clang")
load("szip/2.1.1")
load("jedi-mpich/3.3.1")

load("hdf5/1.10.5")
load("pnetcdf/1.11.2")
load("netcdf/4.7.0")

load("lapack/3.7.0")
load("boost-headers/1.68.0")
load("eigen/3.3.5")
load("bufrlib/master")

load("ecbuild")
load("eckit")
load("fckit")

load("odc")
load("nccmp")

setenv("CC","mpicc")
setenv("FC","mpifort")
setenv("CXX","mpicxx")
setenv("LD","mpicc")

whatis("Name: ".. pkgName)
whatis("Version: ".. pkgVersion)
whatis("Category: Application")
whatis("Description: JEDI Environment with clang/mpich")
