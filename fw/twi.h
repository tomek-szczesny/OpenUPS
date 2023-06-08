/*
 * Copyright (c) 2023 Edward Kisiel hominoid@cablemi.com All rights reserved.
 *
 * File:    twi.h
 * Author:  Edward Kisiel
 * License: GNU GPLv3
 *
 * Description: AVRDx TWI driver for I2C interface.
 *
*/

#define F_CPU                           24000000UL
#define CLK_PER                         24000000UL

/* TWI PINS */
#define TWI_PINS_DEFAULT                0
#define TWI_PINS_ALT1                   1
#define TWI_PINS_ALT2                   2
 
/* TWI0 setttings */
#define TWI0_I2C                        0
#define TWI0_ADDR                       0x72
#define TWI0_BAUD                       400000
#define TWI0_BAUDRATE(F_SCL, T_RISE)    ((((((float)CLK_PER / (float)F_SCL)) - 10 - ((float)CLK_PER * T_RISE))) / 2)

/* TWI1 setttings */
#define TWI1_I2C                        1
#define TWI1_ADDR                       0x68
#define TWI1_BAUD                       100000
#define TWI1_BAUDRATE(F_SCL, T_RISE)    ((((((float)CLK_PER / (float)F_SCL)) - 10 - ((float)CLK_PER * T_RISE))) / 2)

#define TWI_MODE_HOST                   0
#define TWI_MODE_CLIENT                 1
#define TWI_MODE_DUAL                   1
#define TWI_READ_ACK                    1
#define TWI_READ_NACK                   0

/* error messages */
#define TWI_ERROR_NOHOST                10

uint8_t twi_init(uint8_t TWIPORT, uint8_t TWI_PINS, uint8_t TWI_MODE, uint32_t BAUD, bool TWI_SMART);

void error(uint8_t num);