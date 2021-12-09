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

-- On unload: Remove exported functions
execute{cmd="unset -f " .. funcs, modeA={"unload"}}

load(python)
prereq(python)

-- Specify where system and user environments should be created
setenv("CONDA_ENVS_PATH", opt)
-- Directories are separated with a comma
setenv("CONDA_PKGS_DIRS", conda_dir .. "/pkgs")

-- Set environment variable that tell JEDI python environments if this is conda or not
setenv("JEDI_PYTHON_STYLE", "conda")

-- On load: Initialize conda
execute{cmd="source " .. conda_dir .. "/etc/profile.d/conda.sh; export -f " .. funcs, modeA={"load"}}

