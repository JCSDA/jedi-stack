help([[
Load environment for running JEDI applications with MPICH.
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

load("jedi-gnu")
load("szip")
load("jedi-mpich")

load("lapack")
load("eigen")
load("boost")
load("json")
load("json-schema-validator")

load("ecbuild")
load("eckit")

load("hdf5")
load("netcdf")
load("nccmp")
load("gsl_lite")

whatis("Name: ".. pkgName)
whatis("Version: ".. pkgVersion)
whatis("Category: Application")
whatis("Description: JEDI Environment with MPICH")
