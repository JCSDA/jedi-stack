help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

local opt = os.getenv("OPT") or "/opt"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("MANPATH", pathJoin(base,"share","man"))

setenv("JASPER_ROOT", base)
setenv("JASPER_INCLUDES", pathJoin(base,"include"))
setenv("JASPER_LIBRARIES", pathJoin(base,"lib"))
setenv("JASPER_VERSION", pkgVersion)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: Jasper library")
