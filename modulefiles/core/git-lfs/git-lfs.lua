help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)
try_load("git")
local opt = os.getenv("JEDI_OPT") or "/opt/modules"
local base = pathJoin(opt,"core",pkgName,pkgVersion)
prepend_path("PATH", pathJoin(base,"bin"))

