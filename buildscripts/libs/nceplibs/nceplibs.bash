#!/bin/bash

set -x

libs=( bacio/v2.0.1 sp/v2.0.2 ip/v2.0.0 sigio/v2.0.1 w3nco/v2.0.6 w3emc/v2.2.0 )

export NWPROD=${NWPROD:-/nwprod}
export SIGIO_INC4=${NWPROD}/lib/sigio/v2.0.1/include
export SIGIO_LIB4=${NWPROD}/lib/sigio/v2.0.1/libsigio_v2.0.1_4.a
export W3EMC_INC4=${NWPROD}/lib/w3emc/v2.2.0/w3emc_v2.2.0_4
export W3EMC_LIB4=${NWPROD}/lib/w3emc/v2.2.0/libw3emc_v2.2.0_4.a
export W3EMC_INC8=${NWPROD}/lib/w3emc/v2.2.0/w3emc_v2.2.0_8
export W3EMC_LIB8=${NWPROD}/lib/w3emc/v2.2.0/libw3emc_v2.2.0_8.a
export W3EMC_INCd=${NWPROD}/lib/w3emc/v2.2.0/w3emc_v2.2.0_d
export W3EMC_LIBd=${NWPROD}/lib/w3emc/v2.2.0/libw3emc_v2.2.0_d.a


cd build

for string in ${libs[@]}; do
    array=(`echo $string | sed 's/\//\n/g'`)
    mkdir -p  ${NWPROD}/lib/${array[0]}/${array[1]}
    export VER=${array[1]}
    mkdir -p ${string}
    cd ${string}
    if [ ! -f robots.txt ]; then
       wget -r -nH --no-parent --cut-dirs=6 --reject "index.html*" 'http://www.nco.ncep.noaa.gov/pmb/codes/nwprod/lib/'${string}'/src/'
    fi
    cd src
    if [ ${array[0]} == 'w3emc' ]; then 
       export W3EMC_SRC=`pwd`
    fi
    ./install.sh
    cd ..
    cd ../..

done
exit 0
