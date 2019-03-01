help([[
]])

local name = "zlib"
local version = "1.2.8"
local compiler = "gnu"
local root = pathJoin("/Users/rmahajan/opt",name,compiler,version)

conflict(name)

prepend_path("DYLD_LIBRARY_PATH", pathJoin(root,"lib"))
prepend_path("CPATH", pathJoin(root,"include"))
prepend_path("MANPATH", pathJoin(root,"share","man"))

setenv( "ZLIB_ROOT", root)
setenv( "ZLIB_INCLUDES", pathJoin(root,"include"))
setenv( "ZLIB_LIBRARIES", pathJoin(root,"lib"))
setenv( "ZLIB_VERSION", version)

whatis("Name: ".. name)
whatis("Version: " .. version)
whatis("Category: library")
whatis("Description: Zlib library")
