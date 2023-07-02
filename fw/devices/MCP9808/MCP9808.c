/*
 * Copyright (c) 2023 Edward Kisiel hominoid@cablemi.com All rights reserved.
 *
 * FILE:        MCP9808.c
 * LICENSE:     GNU GPLv3
 * DESCRIPTION: MCP9808 temperature sensor I2C driver.
 *
*/

#include <stdint.h>
#include <stdbool.h>
#include "../../peripherals/TWI/twi.h"
#include "MCP9808.h"

/* 
 *  DESCRIPTION: read ambient temperature from MCP9808.
 *   
 *         NAME: uint8_t mcp9808_get_temp(uint8_t TWIPORT, uint8_t DEVADDR)
 
 *   PARAMETERS: TWIPORT = TWI0_PORT, TWI1_PORT
 *               DEVADDR = device address fo mcp9808
 *
 *       RETURN: uint8_t temperature
 *
 *         TODO: NONE
 *
 */
 
uint8_t mcp9808_get_temp(uint8_t TWIPORT, uint8_t DEVADDR) {

    // initialize data buffer
    volatile uint8_t bufsize = 2;
    volatile uint8_t buf[bufsize];

    for (uint8_t i = 0; i < bufsize; i++) {
        buf[i] = 0x00;
    }
    uint8_t temperature = 0x00;
    
    // read ta register
    if(twi_read_reg(TWIPORT, DEVADDR, MCP9808_TA, &buf[0], bufsize) != bufsize) return(FAIL);

    // clear mcp9808 flag bits
    buf[0] = buf[0] & 0x1F;
    
    if ((buf[0] & 0x10) == 0x10){
        // TA < 0°C clear sign
        buf[0] = buf[0] & 0x0F;
        temperature = 256-(buf[0] <<= 4) + (buf[1] >>= 4);

    }
    else {
        // TA ≥ 0°C Temperature = Ambient Temperature (°C)
        temperature = (buf[0] <<= 4) + (buf[1] >>= 4);
    }
   return(temperature);
}
