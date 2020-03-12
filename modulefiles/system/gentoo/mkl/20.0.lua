whatis("Intel mkl")
help([[Intel mkl]])

local posix = require("posix")

local intel_root_path =  os.getenv("INTEL_HOME") or pathJoin(os.getenv("HOME"),"intel")
local intel_release_path = pathJoin(intel_root_path,"compilers_and_libraries_2020.0.166/linux")
local intel_license_path = pathJoin(intel_root_path,"licenses")

setenv("INTEL_MKL_RELEASE_PATH", intel_release_path)
prepend_path("INTEL_LICENSE_FILE", intel_license_path)

-- MKL (32-bit integer indexing [lp64] using 64-bit libraries)
local intel_mkl_path = pathJoin(intel_release_path,"mkl")
local mkl_lib_path  = pathJoin(intel_mkl_path,"lib/intel64_lin")
local mkl_inc_path  = pathJoin(intel_mkl_path,"include")
local mkl_ilp64_module_path  = pathJoin(intel_mkl_path,"include/intel64/ilp64") -- 64-bit integer interface
local mkl_lp64_module_path  = pathJoin(intel_mkl_path,"include/intel64/lp64") -- 32-bit integer interface
local mkl_pkgconfig_path  = pathJoin(intel_mkl_path,"bin/pkgconfig")

prepend_path("LD_LIBRARY_PATH",mkl_lib_path) -- dynamic loader serach paths
prepend_path("LIBRARY_PATH",mkl_lib_path) -- Compiler -L search dirs
prepend_path("CPATH",mkl_inc_path) -- Compiler -I search dirs

-- Set Fotran Modules path.  ifort also uses the CPATH. Ther is no ifort specific include variable.
if os.getenv("MKL_ILP64") and not os.getenv("MKL_ILP64")=="0" then
    prepend_path("CPATH",mkl_ilp64_module_path)
else
    prepend_path("CPATH",mkl_lp64_module_path)
end
prepend_path("PKG_CONFIG_PATH",mkl_pkgconfig_path) -- For pkg-config
setenv("INTEL_MKL_PATH", intel_mkl_path)
setenv("MKL_PATH", intel_mkl_path) -- ecbuild search name
setenv("MKL_ROOT", intel_mkl_path) -- cmake findPackage() search name
