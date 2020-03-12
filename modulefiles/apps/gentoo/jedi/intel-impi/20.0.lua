help([[
JEDI environment with intel compilers, intel mpi, and intel mkl. Release 2020.0
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

load("jedi-intel/20.0")
load("jedi-impi/20.0")

load("hdf5")
load("pnetcdf")
load("netcdf")
load("pio")
load("bufrlib")

whatis("Name: ".. pkgName)
whatis("Version: ".. pkgVersion)
whatis("Category: Application")
whatis("Description: JEDI environment with intel compilers, intel mpi, and intel mkl. Release 2020.0")
