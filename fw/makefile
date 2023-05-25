# ------------------------------------------------------------------------------
# Makefile for AVR microcontroller code
# A part of OpenUPS Project
# Website: https://github.com/tomek-szczesny/OpenUPS
# Authors: Tomek Szczęsny
# License: TBD
# ------------------------------------------------------------------------------

GCC=avr-gcc
DEVICE=avr128da48
GCCFLAGS= -g -Os -DF_CPU=24000000UL -mmcu=${DEVICE} -B Atmel.AVR-Dx_DFP.2.2.253.atpack/gcc/dev/${DEVICE} -isystem Atmel.AVR-Dx_DFP.2.2.253.atpack/include
LDFLAGS= -g -Os -mmcu=${DEVICE} -B Atmel.AVR-Dx_DFP.2.2.253.atpack/gcc/dev/${DEVICE}
NAME=openups_avr
SRC=$(NAME).c
ELF=$(NAME).elf
BIN=$(NAME).hex
OBJECTS = $(NAME).o 

none:
	@echo ""
	@echo "Pick one of the options:"
	@echo "make build		- Builds AVR code for OpenUPS project"
	@echo "make disassy		- Disassemble the code"
	@echo "make clean		- Deletes OBJ and ELF"

build:
	${GCC} ${GCCFLAGS} -c ${SRC}
	${GCC} ${LDFLAGS} -o ${ELF} *.o
	avr-objcopy -j .text -j .data -O ihex ${ELF} ${BIN}

disassy:
	avr-objdump -S ${ELF}
	
clean:
	rm -f $(OBJECTS) ${ELF}

