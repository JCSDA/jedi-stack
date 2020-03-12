help([[ Module: NCEP bufrlib library for reading binary BUFR format files ]])

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

setenv("bufrlib_ROOT", base)
setenv("bufrlib_PATH", base)
setenv("bufrlib_DIR", pathJoin(base,"share","bufrlib","cmake"))
setenv("bufrlib_INCLUDES", pathJoin(base,"include","bufrlib"))
setenv("bufrlib_LIBRARIES", pathJoin(base,"lib"))
setenv("bufrlib_VERSION", pkgVersion)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: NCEP bufrlib library for reading binary BUFR format files")
