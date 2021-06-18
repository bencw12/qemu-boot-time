#!/bin/bash

BLUE='\033[1;34m'
NC='\033[0m' # No Color

if ! [[ $1 =~ ^[0-9]+$ ]] ; then
    echo "Enter the number for runs for both fgkaslr and nofgkaslr"
    exit 1
fi


outfile="./results/nofgkaslr.txt"
rm -f $outfile

for ((n=1;n<=$1;n++)); do
    echo -e "${BLUE}Booting with fgkaslr off ${n}/${1} ${NC}"
    ./qemu-boot-time.sh nofgkaslr >> $outfile
done

outfile="./results/fgkaslr.txt"
rm -f $outfile

for ((n=1;n<=$1;n++)); do
    echo -e "${BLUE}Booting with fgkaslr on ${n}/${1} ${NC}"
    ./qemu-boot-time.sh fgkaslr >> $outfile
done