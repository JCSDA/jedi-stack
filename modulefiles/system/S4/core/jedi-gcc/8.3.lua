help([[
]])

local version = myModuleVersion()
local modname = myModuleName()
local full = myModuleFullName()

local base = "/opt/gcc/8.3"
local compbin = pathJoin(base,"bin")

whatis([===[loads the gcc 8.3 environment ]===])
prepend_path{"PATH",compbin,delim=":",priority="0"}
prepend_path{"LD_LIBRARY_PATH",pathJoin(base,"lib64"),delim=":",priority="0"}
prepend_path{"LIBRARY_PATH",pathJoin(base,"lib64"),delim=":",priority="0"}
prepend_path{"INCLUDE",pathJoin(base,"include"),delim=":",priority="0"}
prepend_path{"INCLUDE",pathJoin(base,"include/c++/8.3"),delim=":",priority="0"}
prepend_path{"MANPATH",pathJoin(base,"share/man"),delim=":",priority="0"}
