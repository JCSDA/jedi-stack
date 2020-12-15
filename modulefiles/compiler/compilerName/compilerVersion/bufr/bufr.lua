help([[ Module: NCEP bufrlib library for reading binary BUFR format files ]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict("bufrlib")
conflict(pkgName)

local opt = os.getenv("JEDI_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("PYTHONPATH", pathJoin(base,"lib/python3.8/site-packages"))

setenv("bufr_VERSION", pkgVersion)
setenv("bufr_ROOT", base) -- CMake find_package(bufr)
setenv("bufrlib_ROOT", base) -- py-ncepbufr variable

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: NCEP bufrlib library for reading binary BUFR format files")
