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

conflict(pkgName)
conflict("jedi-mpich","jedi-impi")

local mpi = pathJoin("openmpi",pkgVersion)
load(mpi)
prereq(mpi)

local opt = os.getenv("OPT") or "/opt/modules"
local mpath = pathJoin(opt,"modulefiles/mpi",compNameVer,"openmpi",pkgVersion)
prepend_path("MODULEPATH", mpath)

setenv("FC",  "mpifort")
setenv("CC",  "mpicc")
setenv("CXX", "mpicxx")

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: OpenMPI library and module access")
