
/*
 * Copyright (c) 2023 by the OpenUPS Developers All rights reserved.
 *
 *        File:  MCP9808.h
 * Description:  MCP9808 Register Map per Microchip Datasheet
 *
*/

#define MCP9808_ADDR      0x18

#define MCP9808_RFU       0x00
#define MCP9808_TUPPER    0x01
#define MCP9808_TLOWER    0x02
#define MCP9808_TCRIT     0x03
#define MCP9808_TA        0x05
#define MCP9808_MANID     0x06
#define MCP9808_DEVID     0x07
#define MCP9808_RES       0x08

uint8_t mcp9808_get_temp(uint8_t TWIPORT, uint8_t DEVADDR);