#!/bin/bash
#==========================================================================
#
# Description: This script builds the NCEP libraries used by NEMSfv3gfs v1
#
# Usage: see function usage below
#
# Examples:
#     > ./make_ncep_libs.sh -h
#     > ./make_ncep_libs.sh -s theia -c intel -d /scratch4/home/USERNAME/NCEPlibs-20180401 -o 1
#     > ./make_ncep_libs.sh -s cheyenne -c pgi -d /glade/p/work/USERNAME/NCEPlibs-20180401 -o 0
#     > ./make_ncep_libs.sh -s macosx -c gnu -d /usr/local/NCEPlibs-20180401 -o 1
#
#==========================================================================

# Define functions.

function fail    { [ -n "$1" ] && printf "\n%s\n" "$1"; exit 1; }

function usage   { 
  echo "Usage: "
  echo "$THIS_FILE -s system -c compiler -d installdir -o openmp | -h"
  echo "    Where: system     [required] can be : ${validsystems[@]}"
  echo "           compiler   [required] can be : ${validcompilers[@]}"
  echo "           installdir [required] is the installation destination (must exist)"
  echo "           openmp     [required] is an OpenMP build flag and can be ${validopenmpflags[@]}"
  exit 1
}

NCEPLIBS_SRC_DIR=`pwd`

THIS_FILE=$(basename "$0" )

#--------------------------------------------------------------
# Define available options
#--------------------------------------------------------------
validsystems=( theia cheyenne macosx linux )
validcompilers=( intel pgi gnu )
validopenmpflags=( 0 1 )

#--------------------------------------------------------------
# Parse command line arguments
#--------------------------------------------------------------
while getopts :s:c:d:o:help opt; do
  case $opt in
    s) SYSTEM=$OPTARG ;;
    c) COMPILER=$OPTARG ;;
    d) NCEPLIBS_DST_DIR=$OPTARG ;;
    o) OPENMP=$OPTARG ;;
    h) usage ;;
    *) usage ;;
  esac
done

# Check if all mandatory arguments are provided
if [ -z $SYSTEM ] ; then usage; fi
if [ -z $COMPILER ] ; then usage; fi
if [ -z $NCEPLIBS_DST_DIR ] ; then usage; fi
if [ -z $OPENMP ] ; then usage; fi

# Ensure value ($2) of variable ($1) is contained in list of validvalues ($3)
function checkvalid {
  if [ $# -lt 3 ]; then
    echo $FUNCNAME requires at least 3 arguments: stopping
    exit 1
  fi

  var_name=$1 && shift
  input_val=$1 && shift
  valid_vars=($@)

  for x in ${valid_vars[@]}; do
    if [ "$input_val" == "$x" ]; then
      echo "${var_name}=${input_val} is valid."
      return
    fi
  done
  echo "ERROR: ${var_name}=${input_val} is invalid. Valid values are: ${valid_vars[@]}"
  exit 1
}

checkvalid SYSTEM ${SYSTEM} ${validsystems[@]}
checkvalid COMPILER ${COMPILER} ${validcompilers[@]}
checkvalid OPENMP ${OPENMP} ${validopenmpflags[@]}

if [ -d ${NCEPLIBS_DST_DIR} ]; then
  echo "Destination directory ${NCEPLIBS_DST_DIR} exists."
else
  echo "ERROR: Destination directory ${NCEPLIBS_DST_DIR} does not exist."
  exit 1
fi

#--------------------------------------------------------------
# Get the build root directory
#--------------------------------------------------------------
export BUILD_DIR="${NCEPLIBS_SRC_DIR}/exec_${SYSTEM}.${COMPILER}"
echo
echo "Building NCEP libraries in ${BUILD_DIR} ..."
echo

#--------------------------------------------------------------
# Copy appropriate macros.make file
#--------------------------------------------------------------
MACROS_FILE=${NCEPLIBS_SRC_DIR}/macros.make
if [ -f ${MACROS_FILE} ]; then
  rm -rf ${MACROS_FILE}
fi
cp -v ${MACROS_FILE}.${SYSTEM}.${COMPILER} ${MACROS_FILE}
 
#--------------------------------------------------------------
# Copy library source to BUILD_DIR and build
#--------------------------------------------------------------
rsync -a macros.make Makefile src ${BUILD_DIR}
cd ${BUILD_DIR}
make || fail "An error occurred building the NCEP libraries"

#--------------------------------------------------------------
# Install to NCEPLIBS_DST_DIR
#--------------------------------------------------------------
echo
echo "Installing to ${NCEPLIBS_DST_DIR} ..."
echo
rm -fr ${NCEPLIBS_DST_DIR}/*
mkdir ${NCEPLIBS_DST_DIR}/lib
mkdir ${NCEPLIBS_DST_DIR}/include
cp -av ${BUILD_DIR}/include/* ${NCEPLIBS_DST_DIR}/include/
cp -av ${BUILD_DIR}/lib*.a ${NCEPLIBS_DST_DIR}/lib/

echo
echo "To build FV3, set environment variable NCEPLIBS_DIR to ${NCEPLIBS_DST_DIR}"
echo
