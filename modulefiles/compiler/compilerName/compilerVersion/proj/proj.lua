help([[ Module: PROJ: Generic coordinate transformation software ]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

local opt = os.getenv("JEDI_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)
local libdir  =pathJoin(base,'lib64')

prepend_path("LD_LIBRARY_PATH", libdir)
prepend_path("DYLD_LIBRARY_PATH", libdir)
prepend_path("LIBRARY_PATH", libdir)
prepend_path("CPATH", pathJoin(base,"include"))

setenv("proj_ROOT", base)
setenv("proj_VERSION", pkgVersion)

prepend_path("PKG_CONFIG_PATH", pathJoin(libdir,"pkgconfig"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: PROJ: a generic coordinate transformation software that transforms " ..
       "geospatial coordinates from one coordinate reference system (CRS) to another.")
