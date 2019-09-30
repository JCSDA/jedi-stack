# libsrc/Makefile

# libsrc/ level makefile template

include ../../../../macros.make 

version = v2.0.1
tarname = sigio

# Compiler substitution variables
FC      = $(FCserial)
FCFLAGS = $(SIGIO_FFLAGS)
ARFLAGS  = $(SIGIO_ARFLAGS)
RANLIB   = ranlib
INSTALL      = /usr/bin/install -c
INSTALL_DATA = ${INSTALL} -m 644
LIB      = ../../../../libsigio_${version}_4.a

# The library name
LIBRARY = lib$(tarname).a

SRC_FILES = sigio_module.f sigio_r_module.f

# The list of object files
OBJ_FILES = ${SRC_FILES:.f=.o}

# The targets
all: library

$(LIBRARY): $(OBJ_FILES)
	$(AR) $(ARFLAGS) $@ $(OBJ_FILES)
	$(RANLIB) $@

library: $(LIBRARY)
	cp $(LIBRARY) $(LIB)
	mkdir -p ../incmod
	cp *.mod ../incmod

clean:
	$(RM) *.o *.mod *.a $(LIB) ../incmod/*.mod

# Specify targets that do not generate filesystem objects
.PHONY: all clean

# Dependencies
sigio_module.o : sigio_module.f 
sigio_r_module.o : sigio_r_module.f sigio_module.o 

# Suffix rules
.SUFFIXES:
.SUFFIXES: .f .o
.f.o:
	$(FC) $(EXTRA_FCFLAGS) $(FCFLAGS) $<
