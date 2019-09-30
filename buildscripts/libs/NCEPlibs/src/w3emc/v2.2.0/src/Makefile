# libsrc/w3emc level makefile template

include ../../../../macros.make

version   = v2.2.0
tarname   = w3emc
precision = d
distdir   = $(tarname)_$(version)_$(precision)

# Compiler substitution variables
FC       = $(FCserial)
FCFLAGS  = $(W3EMC_FFLAGS)
FPPFLAGS = 
ARFLAGS  = $(W3EMC_ARFLAGS)
RANLIB   = ranlib
LIBDIR   = ../../../..

# The library name
LIBRARY = lib$(tarname)_$(precision).a
INC     = -I../../../sigio/v2.0.1/incmod

# The file definitions. This include must occur before targets.
include make.filelist

# The targets
all: library

$(LIBRARY): $(OBJ_FILES)
	$(AR) $(ARFLAGS) $@ $(OBJ_FILES)
	$(RANLIB) $@

library: $(LIBRARY)
	cp $(LIBRARY) $(LIBDIR)

clean:
	$(RM) *.o *.mod *.a $(LIBDIR)/$(LIBRARY)

# Specify targets that do not generate filesystem objects
.PHONY: all clean

# Dependency include file
include make.dependencies

# Suffix rules
.SUFFIXES:
.SUFFIXES: .F .f .o
.F.o:
	$(FC) $(EXTRA_FCFLAGS) $(FCFLAGS) $(FPPFLAGS) $<

.f.o:
	$(FC) $(EXTRA_FCFLAGS) $(FCFLAGS) $(INC) $<

