help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

--io.stderr:write("compNameVer: ",compNameVer,"\n")
--io.stderr:write("compNameVerD: ",compNameVerD,"\n")

family("mpi")

conflict(pkgName)
conflict("mpich")

always_load("szip")
prereq("szip")

local opt = os.getenv("OPT") or "/opt"

local mpath = pathJoin(opt,"modulefiles/mpi",compNameVer,pkgName,pkgVersion)
prepend_path("MODULEPATH", mpath)

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("MANPATH", pathJoin(base,"share","man"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: OpenMPI library")
