/*
 * Copyright (c) 2023 Edward Kisiel hominoid@cablemi.com All rights reserved.
 *
 * FILE:        twi.h
 * LICENSE:     GNU GPLv3
 * DESCRIPTION: AVRDx TWI driver for I2C and SMBUS interface.
 *
*/

#include <stdbool.h>
#include <stdint.h>
#include <avr/io.h>
#include <avr/interrupt.h>

#define SUCCESS                             0
#define FAIL                                -1

#define TWI_WRITE                           0
#define TWI_READ                            1

/* TWI PINS */
#define TWI_PINS_DEFAULT                    0
#define TWI_PINS_ALT1                       1
#define TWI_PINS_ALT2                       2
 
/* TWI0 setttings */
#define TWI0_PORT                           0
#define TWI0_ADDR                           0x66

/* TWI1 setttings */
#define TWI1_PORT                           1
#define TWI1_ADDR                           0x68

#define TWI_MODE_HOST                       0
#define TWI_MODE_CLIENT                     1
#define TWI_MODE_DUAL                       2
#define TWI_READ_ACK                        1
#define TWI_READ_NACK                       0

/* error messages */
#define TWI_ERROR_NOHOST                   -2
#define TWI_ERROR_START                    -3
#define TWI_ERROR_ADDR                     -3
#define TWI_ERROR_NACK                     -4
#define TWI_ERROR_READ                     -5
#define TWI_ERROR_WRITE                    -6
#define TWI_ERROR_REGREAD                  -7

#define TWI_I2C                             0
#define TWI_SMB                             1

enum {
    TWI_INIT = 0, 
    TWI_ACKED,
    TWI_NACKED,
    TWI_READY,
    TWI_ERROR
};

struct twi_bus {
    uint8_t  port;      // TWI0_PORT, TWI1_PORT
    uint8_t  mode;      // TWI_MODE_HOST, TWI_MODE_CLIENT, TWI_MODE_DUAL
    uint32_t freq;      // twi freq
    uint8_t  bustype;   // TWI_I2C, TWI_SMB
    uint8_t  pins;      // TWI_PINS_DEFAULT, TWI_PINS_ALT1, TWI_PINS_ALT2
    uint8_t  sdahold;   // TWI_SDAHOLD_OFF_gc, TWI_SDAHOLD_50NS_gc, TWI_SDAHOLD_300NS_gc, TWI_SDAHOLD_500NS_gc
    uint8_t  sdasetup;  // TWI_SDASETUP_4CYC_gc, TWI_SDASETUP_8CYC_gc
    uint8_t  timeout;   // TWI_TIMEOUT_DISABLED_gc, TWI_TIMEOUT_50US_gc, TWI_TIMEOUT_100US_gc, TWI_TIMEOUT_200US_gc 
    bool     pullup;    // true, false
    bool     smart;     // true, false
    bool     intrupt;   // true, false
    uint8_t  state;     // twi state
};

uint8_t twi_init(struct twi_bus *twi_bus);
void twim_baud(uint8_t TWIPORT, uint32_t cpuHz, uint32_t twiHz);
uint8_t twi_start(uint8_t TWIPORT, uint8_t TWIADDR, uint8_t TWICMD);
uint8_t twi_wait(uint8_t TWIPORT, uint8_t mode);
uint8_t twi_read(uint8_t TWIPORT, volatile uint8_t *data, uint8_t len);
uint8_t twi_write(uint8_t TWIPORT, volatile uint8_t *data, uint8_t len);
uint8_t twi_read_reg(uint8_t TWIPORT, uint8_t TWIADDR, uint8_t reg_addr, volatile uint8_t *data, uint8_t len);
