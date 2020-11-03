family("compiler")
whatis("Clang")
help([[Clang: A C language family frontend for LLVM]])

local posix = require("posix")
-- Global compiler flags for GCC compatibility

pushenv("FC",pathJoin(compiler_bin_path,"gfortran-10.2.0"))
pushenv("CC",pathJoin(compiler_bin_path,"clang-10"))
pushenv("CXX",pathJoin(compiler_bin_path,"clang++-10"))
