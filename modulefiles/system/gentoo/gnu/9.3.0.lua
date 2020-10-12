family("compiler")
whatis("GNU")
help([[GCC: GNU Compiler Collection]])

local posix = require("posix")
-- Global compiler flags for GCC compatibility

pushenv("FC",pathJoin(compiler_bin_path,"gfortran-9.3.0"))
pushenv("CC",pathJoin(compiler_bin_path,"gcc-9.3.0"))
pushenv("CXX",pathJoin(compiler_bin_path,"g++-9.3.0"))
