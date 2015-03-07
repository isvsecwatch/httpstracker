#!/bin/zsh
#
# This launches Google Chrome on OS X without support for RC4 and 3DES
#
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --cipher-suite-blacklist=0x0004,0x0005,0xc011,0xc007 &
