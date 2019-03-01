help([[
]])

local name = "jasper"
local version = "1.900.1"
local compiler = "gnu"
local root = pathJoin("/opt",name,compiler,version)

conflict(name)

prepend_path("DYLD_LIBRARY_PATH", pathJoin(root,"lib"))
prepend_path("CPATH", pathJoin(root,"include"))
prepend_path("MANPATH", pathJoin(root,"share","man"))

setenv( "JASPER_ROOT", root)
setenv( "JASPER_INCLUDES", pathJoin(root,"include"))
setenv( "JASPER_LIBRARIES", pathJoin(root,"lib"))
setenv( "JASPER_VERSION", version)

whatis("Name: ".. name)
whatis("Version: " .. version)
whatis("Category: library")
whatis("Description: Jasper library")
