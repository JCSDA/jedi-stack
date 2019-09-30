help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

local opt = os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("MANPATH", pathJoin(base,"share","man"))

setenv("NCEPLIBS_ROOT", base)
setenv("NCEPLIBS_DIR", base)
setenv("NEMSIO_INC", pathJoin(base,"include"))
setenv("NCEPLIBS_INCLUDES", pathJoin(base,"include"))
setenv("NCEPLIBS_LIBRARIES", pathJoin(base,"lib"))
setenv("NCEPLIBS_VERSION", pkgVersion)
setenv("NEMSIO_LIB",pathJoin(base,"lib/libnemsio_d.a"))
setenv("BACIO_LIB4",pathJoin(base,"lib/libbacio_4.a"))
setenv("SP_LIBd",pathJoin(base,"lib/libsp_v2.0.2_d.a"))
setenv("W3EMC_LIBd",pathJoin(base,"lib/libw3emc_d.a"))
setenv("W3NCO_LIBd",pathJoin(base,"lib/libw3nco_d.a"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: NCEP libraries")
