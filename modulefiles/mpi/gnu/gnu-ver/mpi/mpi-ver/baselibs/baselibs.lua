help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,2)
local mpiNameVer   = hierA[1]
local compNameVer  = hierA[2]
local mpiNameVerD  = mpiNameVer:gsub("/","-")
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)
conflict("szip")
conflict("hdf5")
conflict("netcdf")
conflict("udunits")
conflict("esmf")

local opt = os.getenv("OPT") or "/opt"

local base = pathJoin(opt,compNameVerD,mpiNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("MANPATH", pathJoin(base,"share","man"))

setenv("BASEDIR", base)

setenv("HDF4_ROOT", base)
setenv("HDF4_INCLUDES", pathJoin(base,"include"))
setenv("HDF4_LIBRARIES", pathJoin(base,"lib"))

setenv("HDF5_ROOT", base)
setenv("HDF5_INCLUDES", pathJoin(base,"include"))
setenv("HDF5_LIBRARIES", pathJoin(base,"lib"))

setenv("NETCDF_ROOT", base)
setenv("NETCDF_INCLUDES", pathJoin(base,"include/netcdf"))
setenv("NETCDF_LIBRARIES", pathJoin(base,"lib"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Collection of libraries")
whatis("Description: GMAO ESMA-Baselibs")
