help([[
Load environment for running JEDI applications with GNU compilers and OpenMPI.
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

load("jedi-gnu")
load("szip")
load("jedi-openmpi")

load("hdf5")
load("pnetcdf")
load("netcdf")

load("lapack")
load("boost-headers")
load("eigen")
load("json")
load("json-schema-validator")

laod("ecbuild")
load("eckit")
load("gsl_lite")

whatis("Name: ".. pkgName)
whatis("Version: ".. pkgVersion)
whatis("Category: Application")
whatis("Description: JEDI Environment with OpenMPI")
