help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local pythNameVer  = hierA[1]
-- needed ??? 
local pythNameVerD = pythNameVer:gsub("/","-")

conflict(pkgName)

local opt = os.getenv("JEDI_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,pkgName,pkgVersion)

if (os.getenv("JEDI_PYTHON_STYLE")=="other") then
  prepend_path("PATH",              pathJoin(base,"bin"))
  prepend_path("LD_LIBRARY_PATH",   pathJoin(base))
  prepend_path("DYLD_LIBRARY_PATH", pathJoin(base))
  prepend_path("PYTHONPATH",        pathJoin(base))
end

if (os.getenv("JEDI_PYTHON_STYLE")=="conda") then
  -- On load: Activate environment
  execute{cmd="conda activate pyjedi", modeA={"load"}}
  -- On unload: Deactivate environment
  execute{cmd="conda deactivate", modeA={"unload"}}
end

-- prepend_path("CPATH", pathJoin(base,"include"))
-- prepend_path("MANPATH", pathJoin(base,"share","man"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: PyJEDI Python environment")
