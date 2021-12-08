help([[
JEDI conda python environment containing pyjedi
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("MetaPython")

conflict(pkgName)
conflict("jedi-conda", "jedi-python")

local python = pathJoin("conda",pkgVersion)

local opt = os.getenv("JEDI_OPT") or os.getenv("OPT") or "/opt/modules"
local mpath = pathJoin(opt,"modulefiles/python","conda",pkgVersion)
prepend_path("MODULEPATH", mpath)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: python")
whatis("Description: conda python configuration")

local conda_dir = "${CONDA_ROOT}"
local funcs = "conda __conda_activate __conda_hashr __conda_reactivate __add_sys_prefix_to_path"

-- On unload: Deactivate environment and remove exported functions
-- execute{cmd="for i in $(seq ${CONDA_SHLVL:=0}); do conda deactivate; done")
execute{cmd="conda deactivate", modeA={"unload"}}
execute{cmd="unset -f " .. funcs, modeA={"unload"}}

load(python)
prereq(python)

-- Specify where system and user environments should be created
setenv("CONDA_ENVS_PATH", opt)
-- Directories are separated with a comma
setenv("CONDA_PKGS_DIRS", conda_dir .. "/pkgs")

-- On load: Initialize conda and activate environment (unless told to skip)
execute{cmd="source " .. conda_dir .. "/etc/profile.d/conda.sh; export -f " .. funcs, modeA={"load"}}
local skip_activate=os.getenv("SKIP_ACTIVATE_PYJEDI") or ""
if ( not skip_activate ) then
  execute{cmd="conda activate pyjedi", modeA={"load"}}
end
