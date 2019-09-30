# lib/ip makefile template
#
#     Update Double Precision (Size of Real 8-byte and default Integer) version
#     of libip_d.a
 
include ../../../../macros.make

SRCS   = $(wildcard *.f)
OBJS   = $(addsuffix .o, $(basename $(SRCS)))
LIB    = ../../../../libip_d.a
FC     = $(FCserial)
#FFLAGS_D_DEBUG = -check all -traceback -fpe0 -ftrapuv -g -real-size 64 -integer-size 32 -openmp
FFLAGS = $(IP_FFLAGS)
AFLAGS = $(IP_ARFLAGS)
 
%.o: %.f
	$(FC) -c $(FFLAGS) $<

$(LIB): $(OBJS)
	ar $(AFLAGS) $@ $^

clean:
	$(RM) *.o *.mod $(LIB)
