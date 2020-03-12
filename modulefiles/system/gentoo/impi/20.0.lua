family("mpi")
whatis("Intel mpi and libfabric")
help([[Intel mpi and libfabric]])

conflict(myModuleName())
conflict("mpich","openmp")

local posix = require("posix")

local intel_root_path = os.getenv("INTEL_HOME") or pathJoin(os.getenv("HOME"),"intel")
local intel_release_path = pathJoin(intel_root_path,"compilers_and_libraries_2020.0.166/linux")
local intel_license_path = pathJoin(intel_root_path,"licenses")

setenv("INTEL_MPI_RELEASE_PATH", intel_release_path)
prepend_path("INTEL_LICENSE_FILE", intel_license_path)

-- Intel MPI
local intel_mpi_root = pathJoin(intel_release_path,"mpi")
local intel_mpi_intel64_path = pathJoin(intel_mpi_root,"intel64")
local libfabric_bin_path  = pathJoin(intel_mpi_intel64_path,"libfabric/bin")
local libfabric_lib_path  = pathJoin(intel_mpi_intel64_path,"libfabric/lib")
local libfabric_prov_path  = pathJoin(intel_mpi_intel64_path,"libfabric/lib/prov")
local mpi_bin_path  = pathJoin(intel_mpi_intel64_path,"bin")
local mpi_include_path  = pathJoin(intel_mpi_intel64_path,"include")
local mpi_man_path = pathJoin(intel_mpi_root,"man")
local mpi_lib_path  = pathJoin(intel_mpi_intel64_path,"lib")
local mpi_lib_release_path  = pathJoin(intel_mpi_intel64_path,"lib/release")
local mpi_lib_debug_path  = pathJoin(intel_mpi_intel64_path,"lib/debug")
local mpi_lib_release_mt_path  = pathJoin(intel_mpi_intel64_path,"lib/release_mt")
local mpi_lib_debug_mt_path  = pathJoin(intel_mpi_intel64_path,"lib/debug_mt")
local mpi_lib_kind = os.getenv("I_MPI_LIBRARY_KIND") or "release"

prepend_path("PATH",libfabric_bin_path)
prepend_path("LD_LIBRARY_PATH",libfabric_lib_path)
prepend_path("LD_LIBRARY_PATH",libfabric_prov_path)
prepend_path("LIBRARY_PATH",libfabric_lib_path)

prepend_path("PATH",mpi_bin_path)
prepend_path("MANPATH",mpi_man_path)
prepend_path("CPATH",mpi_include_path)

if mpi_lib_kind == "release" then
    prepend_path("LD_LIBRARY_PATH",mpi_lib_release_path)
    prepend_path("LIBRARY_PATH",mpi_lib_release_path)
    setenv("I_MPI_LIBRARY_KIND", mpi_lib_kind)
elseif mpi_lib_kind == "debug" then
    prepend_path("LD_LIBRARY_PATH",mpi_lib_debug_path)
    prepend_path("LIBRARY_PATH",mpi_lib_debug_path)
elseif mpi_lib_kind == "release_mt" then
    prepend_path("LD_LIBRARY_PATH",mpi_lib_release_mt_path)
    prepend_path("LIBRARY_PATH",mpi_lib_release_mt_path)
elseif mpi_lib_kind == "debug_mt" then
    prepend_path("LD_LIBRARY_PATH",mpi_lib_debug_mt_path)
    prepend_path("LIBRARY_PATH",mpi_lib_debug_mt_path)
else
    print("Unknown intel MPI library kind:", mpi_lib_kind)
    print("Defaulting to using release libs")
    prepend_path("LD_LIBRARY_PATH",mpi_lib_release_path)
    prepend_path("LIBRARY_PATH",mpi_lib_release_path)
    setenv("I_MPI_LIBRARY_KIND", mpi_lib_kind)
end

-- For intel comonents this should be the root above the intel64 directory
setenv("I_MPI_ROOT", intel_mpi_root)
-- setenv("INTEL_MPI_PATH", intel_mpi_intel64_path)

-- For CMake to find the mpiexec and other programs INTEL
pushenv("MPI_HOME", intel_mpi_intel64_path)
pushenv("MPIEXEC_EXECUTABLE", pathJoin(mpi_bin_path,"mpiexec"))
pushenv("MPI_Fortran_COMPILER", pathJoin(mpi_bin_path,"mpiifort"))
pushenv("MPI_C_COMPILER", pathJoin(mpi_bin_path,"mpiicc"))
pushenv("MPI_CXX_COMPILER", pathJoin(mpi_bin_path,"mpiicpc"))
pushenv("MPIFC",pathJoin(mpi_bin_path,"mpiifort"))
pushenv("MPICC",pathJoin(mpi_bin_path,"mpiicc"))
pushenv("MPICXX",pathJoin(mpi_bin_path,"mpiicpc"))
-- For jedi-stack which like to have a '_'
pushenv("MPI_FC",pathJoin(mpi_bin_path,"mpiifort"))
pushenv("MPI_CC",pathJoin(mpi_bin_path,"mpiicc"))
pushenv("MPI_CXX",pathJoin(mpi_bin_path,"mpiicpc"))
-- For intel-provided mpifort mpicc mpicxx scripts to set default compiler
pushenv("I_MPI_F77","ifort")
pushenv("I_MPI_F90","ifort")
pushenv("I_MPI_FC","ifort")
pushenv("I_MPI_CC","icc")
pushenv("I_MPI_CXX","icpc")
--For ParallelIO CMake to detect MPIMOD_PATH
pushenv("MPI_Fortran_INCLUDE_PATH",mpi_include_path)
