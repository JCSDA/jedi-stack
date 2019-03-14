help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

local base = pathJoin("/Users/rmahajan/opt",pkgName)

prepend_path("PATH", pathJoin(base,"bin"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Software")
whatis("Description: Amazon Web Services - Command Line Interface")
