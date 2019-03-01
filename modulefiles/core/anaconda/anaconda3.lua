help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

local pythonExtras = "/Users/rmahajan/opt/python-extras/lib/python3.6/site-packages"

local base = pathJoin("/Users/rmahajan/opt",pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("PYTHONPATH", pythonExtras)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion .. "-5.2.0")
whatis("Category: Software")
whatis("Description: Anaconda Python 3 Distribution")
