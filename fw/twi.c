/*
 * Copyright (c) 2023 Edward Kisiel hominoid@cablemi.com All rights reserved.
 *
 * File:    twi.c
 * Author:  Edward Kisiel
 * License: GNU GPLv3
 *
 * Description: AVRDx TWI driver for I2C interface.
 *
*/
 
#include <avr/io.h>
#include <stdbool.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include "twi.h"


/* 
 *  twi/i2c initialization for all ports and modes.
 *   
 *  uint8_t twi_init(uint8_t TWIPORT, uint8_t TWI_PINS, uint8_t TWI_MODE, uint8_t BAUD, bool TWI_SMART)
 *                    TWIPORT = TWI0, TWI1
 *                   TWI_PINS = TWI_PINS_DEFAULT, TWI_PINS_ALT1, TWI_PINS_ALT2
 *                   TWI_MODE = TWI_MODE_HOST, TWI_MODE_CLIENT, TWI_MODE_DUAL
 *                       BAUD = bus freq 100000, 400000, 1000000
 *                  TWI_SMART = true, false
 */
 
uint8_t twi_init(uint8_t TWIPORT, uint8_t TWI_PINS, uint8_t TWI_MODE, uint32_t BAUD, bool TWI_SMART) {

    if(TWI_MODE == TWI_MODE_HOST) {
        switch(TWIPORT) {
            case TWI0_I2C :
                // set twi pin mux
                switch(TWI_PINS) {
                    case TWI_PINS_ALT1 :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI0_ALT1_gc;   /* PA2, PA3, PC6, PC7 */
                    case TWI_PINS_ALT2 :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI0_ALT2_gc;   /* PC2, PC3, PC6, PC7 */
                    case TWI_PINS_DEFAULT :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI0_DEFAULT_gc;    /* PA2, PA3, PC2, PC3 */
                    default :
                        break;
                }

                // configure INPUTLVL I2C, SDAHOLD 50ns, SDASETUP 4 cycles
                TWI0_CTRLA = TWI_INPUTLVL_I2C_gc || TWI_SDAHOLD_50NS_gc || TWI_SDASETUP_4CYC_gc; 
                
                // enable smart mode
                if(TWI_SMART) TWI0_MCTRLA = TWI_SMEN_bm;          
                
                if(BAUD == 1000000UL) {
                    TWI0_CTRLA = TWI_FMPEN_ON_gc;
                }
                else {
                    TWI0_CTRLA = TWI_FMPEN_OFF_gc;
                }

                // set baud rate
                TWI0_MBAUD = TWI0_BAUDRATE(BAUD, 0);
                
                // configure TIMEOUT 50us
                TWI0_CTRLA = TWI_TIMEOUT_50US_gc;
                
                // set ENABLE bit
                TWI0_MCTRLA = TWI_ENABLE_bm;

                // clear MSTATUS and set BUSSTATE to force idle
                TWI0_MSTATUS = TWI_RIF_bm | TWI_WIF_bm | TWI_CLKHOLD_bm | TWI_RXACK_bm |
                    TWI_ARBLOST_bm | TWI_BUSERR_bm | TWI_BUSSTATE_IDLE_gc;
                
                // check for idle state
                if(TWI0_MSTATUS > 0) {
                    return(0);
                }
                else {
                    return(1);
                }
            case TWI1_I2C :
                // set twi pin mux
                switch(TWI_PINS) {
                    case TWI_PINS_ALT1 :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI1_DEFAULT_gc;   /* PF2, PF3 */
                    case TWI_PINS_ALT2 :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI1_ALT2_gc;   /* PB2, PB3 */
                    case TWI_PINS_DEFAULT :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI1_DEFAULT_gc;    /* PF2, PF3, PB2, PB3 */
                    default :
                        break;
                }

                // configure INPUTLVL I2C, SDAHOLD 50ns, SDASETUP 4 cycles
                TWI1_CTRLA =  TWI_INPUTLVL_I2C_gc || TWI_SDAHOLD_50NS_gc || TWI_SDASETUP_4CYC_gc;

                // enable smart mode
                if(TWI_SMART) TWI1_MCTRLA = TWI_SMEN_bm;          
                
                if(BAUD == 1000000UL) {
                    TWI1_CTRLA = TWI_FMPEN_ON_gc;
                }
                else {
                    TWI1_CTRLA = TWI_FMPEN_OFF_gc;
                }

                // set baud rate
                TWI1_MBAUD = TWI1_BAUDRATE(BAUD, 0);

                // configure TIMEOUT 50us
                TWI0_CTRLA = TWI_TIMEOUT_50US_gc;
                
                // set ENABLE bit
                TWI1_MCTRLA = TWI_ENABLE_bm;
                
                // clear MSTATUS and set BUSSTATE to force idle
                TWI1_MSTATUS = TWI_RIF_bm | TWI_WIF_bm | TWI_CLKHOLD_bm | TWI_RXACK_bm |
                    TWI_ARBLOST_bm | TWI_BUSERR_bm | TWI_BUSSTATE_IDLE_gc;
                
                // check for idle state
                if(TWI1_MSTATUS > 0) {
                    return(0);
                }
                else {
                    return(1);
                }
            default :
                return(1);
        }
    }
    if(TWI_MODE == TWI_MODE_CLIENT) {
        switch(TWIPORT) {
            case TWI0_I2C :
                // set twi pin mux
                switch(TWI_PINS) {
                    case TWI_PINS_ALT1 :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI0_ALT1_gc;   /* PA2, PA3, PC6, PC7 */
                    case TWI_PINS_ALT2 :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI0_ALT2_gc;   /* PC2, PC3, PC6, PC7 */
                    case TWI_PINS_DEFAULT :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI0_DEFAULT_gc;    /* PA2, PA3, PC2, PC3 */
                    default :
                        break;
                }
                // configure INPUTLVL I2C, SDAHOLD 50ns, SDASETUP 4 cycles
                TWI0_CTRLA = TWI_INPUTLVL_I2C_gc || TWI_SDAHOLD_50NS_gc || TWI_SDASETUP_4CYC_gc;

                // enable smart mode
                if(TWI_SMART) TWI0_SCTRLA = TWI_SMEN_bm;
                    
                // set address
                TWI0_SADDR = TWI0_ADDR;

                // set ENABLE bit
                TWI0_SCTRLA = TWI_ENABLE_bm;
                
                return(0);
                
            case TWI1_I2C :
                // set twi pin mux
                switch(TWI_PINS) {
                    case TWI_PINS_ALT1 :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI1_DEFAULT_gc;   /* PF2, PF3 */
                    case TWI_PINS_ALT2 :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI1_ALT2_gc;   /* PB2, PB3 */
                    case TWI_PINS_DEFAULT :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI1_DEFAULT_gc;    /* PF2, PF3, PB2, PB3 */
                    default :
                        break;
                }
                // configure INPUTLVL I2C, SDAHOLD 50ns, SDASETUP 4 cycles
                TWI1_CTRLA = TWI_INPUTLVL_I2C_gc || TWI_SDAHOLD_50NS_gc || TWI_SDASETUP_4CYC_gc;
                
                // enable smart mode
                if(TWI_SMART) TWI1_SCTRLA = TWI_SMEN_bm;

                // set address
                TWI1_SADDR = TWI1_ADDR;

                // set ENABLE bit
                TWI1_SCTRLA = TWI_ENABLE_bm;
                                
                return(0);
              
            default :
                return(1);
        }
    }
    if(TWI_MODE == TWI_MODE_DUAL) {
        switch(TWIPORT) {
            case TWI0_I2C :
                // set twi pin mux
                switch(TWI_PINS) {
                    case TWI_PINS_ALT1 :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI0_ALT1_gc;   /* PA2, PA3, PC6, PC7 */
                    case TWI_PINS_ALT2 :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI0_ALT2_gc;   /* PC2, PC3, PC6, PC7 */
                    case TWI_PINS_DEFAULT :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI0_DEFAULT_gc;    /* PA2, PA3, PC2, PC3 */
                    default :
                        break;
                }
                // configure SDAHOLD to 50ns
                TWI0_CTRLA = TWI_SDAHOLD_50NS_gc;
                
                // configure INPUTLVL I2C, SDASETUP 4 cycles
                TWI0_DUALCTRL = TWI_INPUTLVL_I2C_gc || TWI_SDASETUP_4CYC_gc;

                // enable smart mode
                if(TWI_SMART) TWI0_SCTRLA = TWI_SMEN_bm;
                
                // set address
                TWI0_SADDR = TWI0_ADDR;

                // set ENABLE bit
                TWI0_DUALCTRL = TWI_ENABLE_bm;
                
                return(0);
                
            case TWI1_I2C :
                // set twi pin mux
                switch(TWI_PINS) {
                    case TWI_PINS_ALT1 :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI1_DEFAULT_gc;   /* PF2, PF3 */
                    case TWI_PINS_ALT2 :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI1_ALT2_gc;   /* PB2, PB3 */
                    case TWI_PINS_DEFAULT :
                        PORTMUX_TWIROUTEA = PORTMUX_TWI1_DEFAULT_gc;    /* PF2, PF3, PB2, PB3 */
                    default :
                        break;
                }
                // configure SDAHOLD to 50ns
                TWI1_CTRLA = TWI_SDAHOLD_50NS_gc;
                
                // configure INPUTLVL I2C, SDASETUP 4 cycles
                TWI1_DUALCTRL = TWI_INPUTLVL_I2C_gc || TWI_SDASETUP_4CYC_gc;

                // enable smart mode
                if(TWI_SMART) TWI1_SCTRLA = TWI_SMEN_bm;
                
                // set address
                TWI1_SADDR = TWI1_ADDR;

                // set ENABLE bit
                TWI1_DUALCTRL = TWI_ENABLE_bm;
                                
                return(0);
              
            default :
                return(1);
        }
    }
}


