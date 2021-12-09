help([[
JEDI non-conda python environment containing pyjedi
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("MetaPython")

conflict(pkgName)
conflict("jedi-conda", "jedi-python")

local python = pathJoin("python",pkgVersion)

local opt = os.getenv("JEDI_OPT") or os.getenv("OPT") or "/opt/modules"
local mpath = pathJoin(opt,"modulefiles/python","python",pkgVersion)
prepend_path("MODULEPATH", mpath)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: python")
whatis("Description: non-conda python configuration")

load(python)
prereq(python)

-- Set environment variable that tell JEDI python environments if this is conda or not
setenv("JEDI_PYTHON_STYLE", "other")

