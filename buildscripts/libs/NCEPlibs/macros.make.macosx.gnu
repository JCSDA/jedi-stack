# Settings for LIBRARY BUILD ONLY: macosx.gnu
#
# Flags common to all
RM         = rm -f
AR         = ar
ARFLAGS    =
FC         = mpif90
FCserial   = gfortran
CC         = mpicc

ifeq ($(OPENMP),1)
  OMPFLAGS= -fopenmp
else
  OMPFLAGS=
endif

# Number of parallel tasks for gmake
GMAKEMINUSJ = -j24

# Flags for bacio library
BACIO_FFLAGS  = $(OMPFLAGS) -O3 -fbacktrace -fPIC
BACIO_CFLAGS  = $(OMPFLAGS) -O3 -DUNDERSCORE -DMACOSX -fPIC

# Flags for gfsio library
GFSIO_FFLAGS  = $(OMPFLAGS) -fbacktrace -g -O3 -fconvert=big-endian -I$(INCMOD) -ffree-form -fPIC
GFSIO_ARFLAGS = -rv

# Flags for ip library
IP_FFLAGS     = $(OMPFLAGS) -O3 -fdefault-real-8 -fPIC
IP_ARFLAGS    = -ruv

# Flags for landsfcutil library
LAND_FFLAGS   = $(OMPFLAGS) -O3 -I$(MOD_DIR) -fdefault-real-8 -ffree-form -fPIC
LAND_ARFLAGS  = -rv

# Flags for nemsio library
NEMSIO_FFLAGS  = $(OMPFLAGS) -O -g -fPIC
NEMSIO_ARFLAGS = -rvu

# Flags for sigio library
SIGIO_FFLAGS  = $(OMPFLAGS) -O0 -g -fbacktrace -ffree-form -fconvert=big-endian -c -fPIC
SIGIO_ARFLAGS = crvs

# Flags for sp library
SP_FFLAGS  = $(OMPFLAGS) -O3 -fdefault-real-8 -fconvert=big-endian -cpp -DLINUX -fPIC
SP_ARFLAGS = -ruv

# Flags for w3emc library
W3EMC_FFLAGS = $(OMPFLAGS) -O2 -g -fbacktrace -ffixed-form -fno-range-check -c -fPIC
W3EMC_ARFLAGS = ruv

# Flags for w3nco library
W3NCO_FFLAGS  = $(OMPFLAGS) -O0 -g -fdefault-real-8 -fno-range-check -ffixed-form -fPIC
W3NCO_CFLAGS  = $(OMPFLAGS) -O0 -DLINUX -fPIC
W3NCO_ARFLAGS = -ruv
