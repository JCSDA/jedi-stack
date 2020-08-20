family("compiler")
whatis("Intel x86_64 compilers")
help([[Intel x86_64 compilers]])

local posix = require("posix")

local intel_root_path = os.getenv("INTEL_ROOT") or os.getenv("INTEL_HOME") or pathJoin(os.getenv("HOME"),"intel")
local intel_release_path = pathJoin(intel_root_path,"compilers_and_libraries_2020.0.166/linux")
local intel_license_path = pathJoin(intel_root_path,"licenses")

setenv("INTEL_COMPILER_RELEASE_PATH", intel_release_path)
prepend_path("INTEL_LICENSE_FILE", intel_license_path)

-- Compiler
local intel_compiler_path = intel_release_path
local intel_gcc_version = "9.3.0" -- Version of GCC to use (10.1.0) not supported yet
local compiler_bin_path = pathJoin(intel_compiler_path,"bin/intel64")
local compiler_lib_path = pathJoin(intel_compiler_path,"compiler/lib/intel64_lin")
local compiler_inc_path = pathJoin(intel_compiler_path,"compiler/include/intel64")
local compiler_man_path = pathJoin(intel_compiler_path,"man/common")

prepend_path("PATH",compiler_bin_path)
prepend_path("CPATH",compiler_inc_path)
prepend_path("LD_LIBRARY_PATH",compiler_lib_path)
prepend_path("LIBRARY_PATH",compiler_lib_path)
prepend_path("MANPATH",compiler_man_path)
setenv("INTEL_COMPILER_PATH", intel_compiler_path)

-- Global compiler flags for GCC compatibility
setenv("FFLAGS","-gcc-name=gcc-" .. intel_gcc_version)
setenv("CFLAGS","-gcc-name=gcc-" .. intel_gcc_version)
setenv("LDFLAGS","-gcc-name=gcc-" .. intel_gcc_version)
setenv("CXXFLAGS","-gcc-name=gcc-" .. intel_gcc_version)

pushenv("FC",pathJoin(compiler_bin_path,"ifort"))
pushenv("CC",pathJoin(compiler_bin_path,"icc"))
pushenv("CXX",pathJoin(compiler_bin_path,"icpc"))
