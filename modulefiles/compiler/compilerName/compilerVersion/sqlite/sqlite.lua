help([[ Module: SQLite: Minimal SQL database engine. ]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

local opt = os.getenv("JEDI_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("PATH", pathJoin(base,"bin"))

setenv("sqlite_ROOT", base)
setenv("sqlite_VERSION", pkgVersion)

prepend_path("PKG_CONFIG_PATH", pathJoin(base,"lib","pkgconfig"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: SQLite: QLite is a C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine.")
