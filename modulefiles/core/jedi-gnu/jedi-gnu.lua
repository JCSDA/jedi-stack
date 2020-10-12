help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("MetaCompiler")

conflict(pkgName)
conflict("jedi-intel")

-- Default serial compiler names may be overridden by compiler module itself
setenv("FC",  "gfortran")
setenv("CC",  "gcc")
setenv("CXX", "g++")

local compiler = pathJoin("gnu",pkgVersion)
load(compiler)
prereq(compiler)

local opt = os.getenv("JEDI_OPT") or os.getenv("OPT") or "/opt/modules"

local mpath = pathJoin(opt,"modulefiles/compiler","gnu",pkgVersion)
prepend_path("MODULEPATH", mpath)

local mpath = pathJoin(opt,"modulefiles/compiler","jedi-gnu",pkgVersion)
prepend_path("MODULEPATH", mpath)

local fc = os.getenv("FC") or "gfortran"
local cc = os.getenv("CC") or "gcc"
local cxx = os.getenv("CXX") or "g++"
setenv("SERIAL_FC",  fc)
setenv("SERIAL_CC",  cc)
setenv("SERIAL_CXX", cxx)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Compiler")
whatis("Description: GNU Compiler Family and module access")
