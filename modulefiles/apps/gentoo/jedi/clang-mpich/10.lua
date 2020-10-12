help([[
 Minimal JEDI environment with Clang C compilers and mpich
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

load("jedi-clang/10")

whatis("Name: ".. pkgName)
whatis("Version: ".. pkgVersion)
whatis("Category: Application")
whatis("Description: Minimal JEDI environment with Clang C compilers and mpich.")
