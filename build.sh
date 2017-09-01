#!/bin/bash

#AS65 Assembler for R6502 [1.42].  Copyright 1994-2007, Frank A. Kingswood
# 
# Usage: AS65 [-DIcghilmnopqstuvwxz] file
# 
# Options:
# 	-D<name> : Define label, if no name given define DEBUG.
# 	-I<path> : Specify include file path string.
# 	-c       : Show number of cycles per instruction in listing.
# 	-g       : Generate source-level debug information.
# 	-h<num>  : Specify height of page for listing.
# 	-i       : Ignore case in opcodes.
# 	-l       : Generate pass 2 listing.
# 	-l<name> : Listing file name.
# 	-m       : Show macro expansions in listing.
# 	-n       : Disable optimizations.
# 	-o<name> : Binary/hex output file name.
# 	-p       : Generate pass 1 listing.
# 	-q       : Quiet mode.
# 	-s1 -s   : Write s-records instead of binary file.
# 	-s2      : Write intel-hex file instead of binary file.
# 	-t       : Generate symbol table.
# 	-u       : List memory usage map.
# 	-v       : Verbose mode.
# 	-w<wid>  : Specify listing width, 131 if no number given.
# 	-x1      : Use 6502 undefined instructions.
# 	-x2 -x   : Use 65SC02 extensions.
# 	-z       : Fill unused memory with zeros.
# 

function make_atm_header {
     len=`du -b $1 | awk '{print $1}'`     
     echo -n `basename $1` > hdr
     truncate -s 16 hdr
     echo -e -n "\x00" >> hdr
     echo -e -n "\x34" >> hdr
     echo -e -n "\x00" >> hdr
     echo -e -n "\x34" >> hdr
     echo -e -n "\x`printf '%x' $(($len & 255))`" >> hdr
     echo -e -n "\x`printf '%x' $(($len / 256))`" >> hdr
     cat $1 >> hdr
     mv hdr $1
}


# Target 1 = ATOM
# Target 2 = BEEB

for TARGET in 1 2 
do

    if [ $TARGET == "1" ]
    then
       DIR=atom
    else
       DIR=beeb
    fi

    mkdir -p $DIR
    rm -f $DIR/*

    BIN=D6502
    ../as65/as65 -DTARGET=$TARGET -o$DIR/$BIN -l$DIR/$BIN.lst -m -w -h0 6502_functional_test.a65

    if [ $TARGET == "1" ]
    then
        make_atm_header $DIR/$BIN
    fi

    for WDC_OP in 0 1
    do
        for RKWL_OP in 0 1
        do
            BIN=D65C02$WDC_OP$RKWL_OP
            ../as65/as65 -DTARGET=$TARGET -DWDC_OP=$WDC_OP -DRKWL_OP=$RKWL_OP -o$DIR/$BIN -l$DIR/$BIN.lst -m -w -x -h0 65C02_extended_opcodes_test.a65c
        done
    done
done
