help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,2)
local mpiNameVer   = hierA[1]
local compNameVer  = hierA[2]
local mpiNameVerD  = mpiNameVer:gsub("/","-")
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

local opt = os.getenv("OPT") or "/opt"

local base = pathJoin(opt,compNameVerD,mpiNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin/bin0/Darwin.gfortran.64.openmpi.default"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib/lib0/Darwin.gfortran.64.openmpi.default"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib/lib0/Darwin.gfortran.64.openmpi.default"))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("CPATH", pathJoin(base,"mod/mod0/Darwin.gfortran.64.openmpi.default"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: FFTW library")
