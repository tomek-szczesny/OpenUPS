
/*
 * Copyright (c) 2023 by the OpenUPS Developers All rights reserved.
 *
 *        File:  NCV81599.h
 * Description:  TI NCV81599 Register Map per Datasheet
 *
*/

#define NCV81599_ADDR0          0x74
#define NCV81599_ADDR1          0x75

// read write registers
#define NCV81599_INTERUPT       0x00
#define NCV81599_DAC_TARGET     0x01
#define NCV81599_SLEW_RATE      0x02
#define NCV81599_PMW_FREQ       0x03
#define NCV81599_DISCHARGE      0x04
#define NCV81599_OCP_SLIM       0x05
#define NCV81599_CS_CLIM_POS    0x06
#define NCV81599_GAMP_SET       0x07
#define NCV81599_AMUX           0x08
#define NCV81599_INT_MASK       0x09

// read only registers
#define NCV81599_VFB            0x10
#define NCV81599_VIN            0x11
#define NCV81599_CS2            0x12
#define NCV81599_CS1            0x13
#define NCV81599_STAT1          0x14
#define NCV81599_STAT2          0x15


