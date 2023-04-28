# ------------------------------------------------------------------------------
# Makefile for AVR microcontroller code
# A part of OpenUPS Project
# Website: https://github.com/tomek-szczesny/OpenUPS
# Authors: Tomek Szczęsny
# License: TBD
# ------------------------------------------------------------------------------

GCC=avr-gcc
DEVICE=avr32db28
GCCFLAGS=-g -mmcu=${DEVICE} -B deps/${DEVICE} -isystem deps/io
LDFLAGS= -g -mmcu=${DEVICE} -B deps/${DEVICE} -T deps/avrxmega3.xn
SRC=openups_avr.c
ELF=openups_avr.elf
BIN=openups_avr.hex


none:
	@echo ""
	@echo "Pick one of the options:"
	@echo "make build		- Builds AVR code for OpenUPS project"
	@echo "make disassy		- Disassemble the code"

build:
	${GCC} ${GCCFLAGS} -c ${SRC}
	${GCC} ${LDFLAGS} -o ${ELF} *.o
	avr-objcopy -j .text -j .data -O ihex ${ELF} ${BIN}

disassy:
	avr-objdump -S ${ELF}
