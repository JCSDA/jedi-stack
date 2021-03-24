help([[
Load environment for running JEDI applications with GNU compilers and OpenMPI.
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

load("jedi-intel")
load("szip")
load("jedi-impi")

load("hdf5")
load("pnetcdf")
load("netcdf")
load("nccmp")

load("boost-headers")
load("eigen")
load("bufr")
load("json")
load("json-schema-validator")

load("ecbuild")
load("eckit")
load("gsl_lite")


setenv("CC","mpiicc")
setenv("FC","mpiifort")
setenv("CXX","mpiicpc")

whatis("Name: ".. pkgName)
whatis("Version: ".. pkgVersion)
whatis("Category: Application")
whatis("Description: JEDI Environment with Intel17")
