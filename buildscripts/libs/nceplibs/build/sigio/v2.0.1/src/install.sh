#!/bin/sh
rm -f *.a *.o *.mod
make -f Makefile.gnu
make -f Makefile.gnu install
