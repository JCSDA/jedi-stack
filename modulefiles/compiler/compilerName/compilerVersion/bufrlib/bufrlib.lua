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
prepend_path("LIBRARY_PATH", pathJoin(base,"lib"))

setenv("BUFRLIB_ROOT", base)
setenv("BUFRLIB_PATH", base)
setenv("BUFRLIB_DIR", base)
setenv("BUFRLIB_INCLUDES", pathJoin(base,"include","bufrlib"))
setenv("BUFRLIB_LIBRARIES", pathJoin(base,"lib"))
setenv("BUFRLIB_VERSION", pkgVersion)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: NCEP BUFRLIB library for reading binary BUFR format files")
