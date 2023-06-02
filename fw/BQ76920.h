
/*
 * Copyright (c) 2023 by the OpenUPS Developers All rights reserved.
 *
 *        File:  BQ76920.h
 * Description:  TI BQ76920 Register Map per Datasheet
 *
*/

#define BQ76920_ADDR        0x18

#define BQ76920_SYS_STAT    0x00
#define BQ76920_CELLBAL1    0x01
#define BQ76920_SYS_CTRL1   0x04
#define BQ76920_SYS_CTRL2   0x05
#define BQ76920_PROTECT1    0x06
#define BQ76920_PROTECT2    0x07
#define BQ76920_PROTECT3    0x08
#define BQ76920_OV_TRIP     0x09
#define BQ76920_UV_TRIP     0x0A
#define BQ76920_CC_CFG      0x0B

#define BQ76920_VC1_HI      0x0C
#define BQ76920_VC1_LO      0x0D
#define BQ76920_VC2_HI      0x0E
#define BQ76920_VC2_LO      0x0F
#define BQ76920_VC3_HI      0x10
#define BQ76920_VC3_LO      0x11
#define BQ76920_VC4_HI      0x12
#define BQ76920_VC4_LO      0x13
#define BQ76920_VC5_HI      0x14
#define BQ76920_VC5_LO      0x15
#define BQ76920_BAT_HI      0x2A
#define BQ76920_BAT_LO      0x2B
#define BQ76920_TS1_HI      0x2C
#define BQ76920_TS1_LO      0x2D
#define BQ76920_CC_HI       0x32
#define BQ76920_CC_LO       0x33
#define BQ76920_ADCGAIN1    0x50
#define BQ76920_ADCOFFSET   0x51
#define BQ76920_ADCGAIN2    0x59
