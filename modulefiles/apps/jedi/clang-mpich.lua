help([[
Load environment for running JEDI applications with clang/gfortran compilers and OpenMPI.
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

load("jedi-clang")
load("szip")
load("jedi-mpich")

load("hdf5")
load("pnetcdf")
load("netcdf")

load("lapack")
load("boost-headers")
load("eigen")
load("bufr")
load("json")
load("json-schema-validator")

load("ecbuild")

load("nccmp")
load("gsl_lite")

setenv("CC","mpicc")
setenv("FC","mpifort")
setenv("CXX","mpicxx")
setenv("LD","mpicc")

whatis("Name: ".. pkgName)
whatis("Version: ".. pkgVersion)
whatis("Category: Application")
whatis("Description: JEDI Environment with clang/mpich")
