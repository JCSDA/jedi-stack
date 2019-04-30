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
conflict("jedi-openmpi","jedi-mpich")

local mpi = pathJoin("impi",pkgVersion)
load(mpi)
prereq(mpi)

local opt = os.getenv("OPT") or "/opt/modules"
local mpath = pathJoin(opt,"modulefiles/mpi",compNameVer,"impi",pkgVersion)
prepend_path("MODULEPATH", mpath)

setenv("FC",  "mpiifort")
setenv("CC",  "mpiicc")
setenv("CXX", "mpiicpc")

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: Intel MPI library and module access")
