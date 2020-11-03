help([[
 Minimal JEDI environment with GCC-9 compilers and mpich
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

load("jedi-gnu/9.3.0")
load("jedi-mpich/3.3.2")

-- Packages producing Fortran modules
load("bufrlib")
load("hdf5")
load("pnetcdf")
load("netcdf")
load("pio")

-- ECMWF packages
load("eckit")
load("fckit")
load("atlas")

whatis("Name: ".. pkgName)
whatis("Version: ".. pkgVersion)
whatis("Category: Application")
whatis("Description: Minimal JEDI environment with GCC-9 compilers and mpich")
