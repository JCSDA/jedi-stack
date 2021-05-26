help([[
Load environment for running JEDI applications with Intel OneAPI
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

load("cmake")
load("jedi-intel")
load("szip")
load("zlib")
load("jedi-impi")

load("udunits")

load("hdf5")
load("pnetcdf")
load("netcdf")
load("nccmp")

load("boost-headers")
load("eigen")
load("json")
load("json-schema-validator")
load("gsl_lite")
load("pybind11")
load("bufr")

load("ecbuild")
load("eckit")
load("fckit")
load("atlas")

whatis("Name: ".. pkgName)
whatis("Version: ".. pkgVersion)
whatis("Category: Application")
whatis("Description: JEDI Environment with Intel OneAPI")
