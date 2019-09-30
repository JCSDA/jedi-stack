# libsrc/nemsio makefile template
#
# Build Double Precision (Size of Real 8-byte and default Integer) version
# of libnemsio?????w3nco_d.a DH*
#
#
include ../../../../macros.make

LIB     = ../../../../libnemsio_d.a
INCMOD  = ../../../../include
FFLAGS  = $(NEMSIO_FFLAGS)
ARFLAGS = $(NEMSIO_ARFLAGS)

#FC      = $(FCOMP)
#FFLAGS      = -O -g
#AR          = ar
#ARFLAGS     = -rvu
#RM          = rm

OBJS    = nemsio_openclose.o nemsio_read.o nemsio_write.o nemsio_module.o nemsio_module_mpi.o

$(LIB):	$(OBJS)
	$(AR) $(ARFLAGS) $@ $(OBJS)
	mkdir -vp $(INCMOD)
	mv -v *.mod $(INCMOD)
	rm -vf *.o

clean:
	mkdir -p $(INCMOD)
	$(RM) -f *.o *.mod *.a $(LIB)

.SUFFIXES: .c .f90 .f .o

.f90.o:
	echo `pwd`
	$(FC) $(FFLAGS) -I. -c $*.f90

.f.o:
	echo `pwd`
	$(FC) $(FFLAGS) -I. -c $*.f

%.o: %.mod

nemsio_read.o: nemsio_openclose.o
nemsio_write.o: nemsio_openclose.o
nemio_module.o: nemsio_openclose.o nemsio_read.o nemsio_write.o
