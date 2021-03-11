help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVer  = hierA[2]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

try_load("qt")

local opt = os.getenv("JEDI_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("MANPATH", pathJoin(base,"share","man"))

prepend_path("PYTHONPATH", pathJoin(base,"lib/python@PYTHON_VERSION@/site-packages/ecflow"))

setenv("ECFLOW_ROOT", base)
setenv("ECFLOW_INCLUDES", pathJoin(base,"include"))
setenv("ECFLOW_LIBRARIES", pathJoin(base,"lib"))
setenv("ECFLOW_VERSION", pkgVersion)
setenv("ECFLOW_PYTHON", pathJoin(base,"lib/python@PYTHON_VERSION@/site-packages/ecflow"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: application")
whatis("Description: ecFlow Workflow Manager")
