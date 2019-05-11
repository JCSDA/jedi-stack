#!/bin/sh
###############################################################
#
#   AUTHOR:    Vuong - SIB
#
#   DATE:      10/12/2012
#
#   PURPOSE:   This script uses the make utility to update the libw3 
#              archive libraries.
#              It first reads a list of source files in the library and
#              then generates a makefile used to update the archive
#              libraries.  The make command is then executed for each
#              archive library, where the archive library name and 
#              compilation flags are passed to the makefile through 
#              environment variables.
#
#   REMARKS:   Only source files that have been modified since the last
#              library update are recompiled and replaced in the object
#              archive libraries.  The make utility determines this
#              from the file modification times.
#
#              New source files are also compiled and added to the object 
#              archive libraries.
#
###############################################################
#
#     Generate a list of object files that corresponds to the
#     list of Fortran ( .f ) files in the current directory
#

COMP=gnu

case ${COMP:?} in
  intel)
    #export FC=${1:-ifort}
    #export CC=${2:-icc}
    export FC=${1:-ftn}
    export CC=${2:-cc}
    flagOpt="-O3 -axCore-AVX2 -g"
    flag64bit="-i8 -r8"
    flag64flt="-r8"
  ;;
  cray)
    export FC=${1:-ftn}
    export CC=${2:-cc}
    flagOpt="-O2 -g"
    flag64bit="-s integer64 -s real64"
    flag64flt="-s real64"
  ;;
  gnu)
    export FC=${1:-gfortran}
    export CC=${2:-gcc}
    flagOpt=" -O3 -fconvert=big-endian -ffast-math -fno-second-underscore -frecord-marker=4 -funroll-loops -static -fno-range-check "
    flag64bit=" -fdefault-real-8 -fdefault-integer-8 "
    flag64flt=" -fdefault-real-8 "
  ;;
  *)
    >&2 echo "Don't know how to build lib under $COMP compiler"
    exit 1
  ;;
esac



#
for i in `ls *.f` ; do
  obj=`basename $i .f`
  OBJS="$OBJS ${obj}.o"
done
#
#     Generate a list of object files that corresponds to the
#     list of C ( .c ) files in the current directory
#
for i in `ls *.c` ; do
  obj=`basename $i .c`
  OBJS="$OBJS ${obj}.o"
done
#
#     Remove make file, if it exists.  May need a new make file
#     with an updated object file list.
#
if [ -f make.libw3nco ] ; then
  rm -f make.libw3nco
fi
#
#     Generate a new make file ( make.libw3), with the updated object list,
#     from this HERE file.
#
cat > make.libw3nco << EOF
SHELL=/bin/sh

\$(LIB):	\$(LIB)( ${OBJS} )

.f.a:
	$FC -c \$(FFLAGS) \$<
	ar -ruv \$(AFLAGS) \$@ \$*.o
	rm -f \$*.o

.c.a:
	$CC -c \$(CFLAGS) \$<
	ar -ruv  \$(AFLAGS) \$@ \$*.o
	rm -f \$*.o
EOF
#
#     Update 4-byte version of libw3nco_4.a
#
export LIB=${NWPROD}/lib/w3nco/${VER}/libw3nco_${VER}_4.a
mkdir -p $(dirname $LIB)
export FFLAGS=" ${flagOpt}"
export AFLAGS=" "
export CFLAGS=" ${flagOpt} -DLINUX"
make -f make.libw3nco

#
#     Update 8-byte version of libw3nco_8.a
#
export LIB=${NWPROD}/lib/w3nco/${VER}/libw3nco_${VER}_8.a
export FFLAGS=" ${flagOpt} ${flag64bit}"
export AFLAGS=" "
export CFLAGS=" ${flagOpt} -DLINUX"
make -f make.libw3nco

#
#     Update Double Precision (Size of Real 8-byte and default Integer) version 
#     of libw3nco_d.a
#
export LIB=${NWPROD}/lib/w3nco/${VER}/libw3nco_${VER}_d.a
export FFLAGS=" ${flagOpt} ${flag64flt}"
export AFLAGS=" "
export CFLAGS=" ${flagOpt} -DLINUX"
make -f make.libw3nco

rm -f make.libw3nco
