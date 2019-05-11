# libsrc/Makefile.  Generated from Makefile.in by configure.

# libsrc/ level makefile template

# Package-specific substitution variables
package = nceplibs sigio
version = $(VER)
tarname = sigio
distdir = $(tarname)/$(version)

# Prefix-specific substitution variables
#prefix = /nwprod/lib/sorc/sigio_v2.0.1
prefix = ${NWPROD}/lib

# Mixed package and prefix substitution variables
installdir = $(prefix)/$(distdir)

# Compiler substitution variables
#FC      = ifort
FC      = gfortran
ifeq ($(COMP),cray)
FCFLAGS = -O2 -G2 -ffree -hbyteswapio -c
else
FCFLAGS = -O3 -fconvert=big-endian -ffree-form -ffast-math -fno-second-underscore -frecord-marker=4 -funroll-loops -static -fno-range-check -c
endif
AR       = ar
ARFLAGS  = crvs
RANLIB   = ranlib
INSTALL      = /usr/bin/install -c
INSTALL_DATA = ${INSTALL} -m 644

# The library name
LIBRARY = ${installdir}/lib$(tarname)_$(version)_4.a

# The file definitions. This include must occur before targets.
include make.filelist

# The targets
all: library

$(LIBRARY): $(OBJ_FILES)
	$(AR) $(ARFLAGS) $@ $(OBJ_FILES)
	$(RANLIB) $@

library: $(LIBRARY)

clean:
	-rm *.o *.mod *.a >/dev/null 2>&1

distclean:
	-rm Makefile >/dev/null 2>&1

check: library
	@echo "***THIS IS WHERE THE UNIT TEST INVOCATION GOES***"

# ...Gnu-style installation
install:
	$(INSTALL) -d $(DESTDIR)$(installdir)/include
	$(INSTALL) -d $(DESTDIR)$(installdir)/lib
	$(INSTALL_DATA) *.mod $(DESTDIR)$(installdir)/include
	$(INSTALL_DATA) $(LIBRARY) $(DESTDIR)$(installdir)/lib
	$(INSTALL_DATA) ../config.log $(DESTDIR)$(installdir)

# ...NCO-style installation
nco_install: FORCE
	$(INSTALL) -d $(SIGIO_INC4)
	$(INSTALL_DATA) *.mod $(SIGIO_INC4)
	$(INSTALL_DATA) $(LIBRARY) $(SIGIO_LIB4)
	#$(INSTALL_DATA) ../config.log $(SIGIO_SRC)/config.log.$(distdir)

FORCE:
	@if [ -d `dirname $(SIGIO_LIB4)` ]; then \
          echo; \
	  echo "*** NCO-style installation does not install into existing directories! ***"; \
	  echo "*** `dirname $(SIGIO_LIB4)` already exists! ***"; \
          echo; \
	  exit 1; \
	fi

# ...Universal uninstallation
uninstall:
	-rm -fr $(DESTDIR)$(installdir) >/dev/null 2>&1

# ...Reconfig targets
#Makefile: Makefile.in ../config.status
#	cd .. && ./config.status libsrc/$@

#../config.status: ../configure
#	cd .. && ./config.status --recheck

# Specify targets that do not generate filesystem objects
.PHONY: all clean distclean check install nco_install uninstall

# Dependency include file
include make.dependencies

# Suffix rules
.SUFFIXES:
.SUFFIXES: .f .o
.f.o:
	$(FC) $(EXTRA_FCFLAGS) $(FCFLAGS) $<
