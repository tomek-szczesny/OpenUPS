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
 *  uint8_t twi_init(uint8_t TWIPORT, uint8_t TWI_MODE, uint8_t FREQ, struct twi_bus *twi_bus)
 *                    TWIPORT = TWI0_PORT, TWI1_PORT
 *                   TWI_MODE = TWI_MODE_HOST, TWI_MODE_CLIENT, TWI_MODE_DUAL
 *                       FREQ = 100000, 400000, 1000000
 *                   *twi_bus = struct twi_bus {
 *                                  int  bustype;    // TWI_I2C, TWI_SMB
 *                                  int  pins;       // TWI_PINS_DEFAULT, TWI_PINS_ALT1, TWI_PINS_ALT2
 *                                  bool pullups;    // true, false
 *                                  int  sdahold;    // TWI_SDAHOLD_OFF_gc, TWI_SDAHOLD_50NS_gc, 
 *                                                      TWI_SDAHOLD_300NS_gc, TWI_SDAHOLD_500NS_gc
 *                                  int  sdasetup;   // TWI_SDASETUP_4CYC_gc, TWI_SDASETUP_8CYC_gc
 *                                  int  timeout;    // TWI_TIMEOUT_DISABLED_gc, TWI_TIMEOUT_50US_gc
 *                                                      TWI_TIMEOUT_100US_gc, TWI_TIMEOUT_200US_gc 
 *                                  bool smart;      // true, false
 *                                  bool intrupt;    // true, false
 *
 */
 
uint8_t twi_init(uint8_t TWIPORT, uint8_t TWI_MODE, uint32_t FREQ, struct twi_bus *twi_bus) {

    if(TWIPORT == TWI0_PORT) {   
        // set twi pin mux
        switch(twi_bus->pins) {
            case TWI_PINS_ALT1 :
                PORTMUX_TWIROUTEA = PORTMUX_TWI0_ALT1_gc;   /* PA2, PA3, PC6, PC7 */
            case TWI_PINS_ALT2 :
                PORTMUX_TWIROUTEA = PORTMUX_TWI0_ALT2_gc;   /* PC2, PC3, PC6, PC7 */
            case TWI_PINS_DEFAULT :
                PORTMUX_TWIROUTEA = PORTMUX_TWI0_DEFAULT_gc;    /* PA2, PA3, PC2, PC3 */
            default :
                break;
        }
        
        if(TWI_MODE != TWI_MODE_DUAL) {
            // configure INPUTLVL
            switch(twi_bus->bustype) {
                case TWI_I2C :
                    TWI0_CTRLA = TWI_INPUTLVL_I2C_gc;
                case TWI_SMB :
                    TWI0_CTRLA = TWI_INPUTLVL_SMBUS_gc;
                default :
                    break;
            }

            // configure SDASETUP
            switch(twi_bus->sdasetup) {
                case TWI_SDASETUP_4CYC_gc :
                    TWI0_CTRLA = TWI_SDASETUP_4CYC_gc;
                case TWI_SDASETUP_8CYC_gc :
                    TWI0_CTRLA = TWI_SDASETUP_8CYC_gc;
                default :
                    break;
            }
        }

        // configure SDAHOLD 
        switch(twi_bus->sdahold) {
            case TWI_SDAHOLD_OFF_gc :
                TWI0_CTRLA = TWI_SDAHOLD_OFF_gc;
            case TWI_SDAHOLD_50NS_gc :
                TWI0_CTRLA = TWI_SDAHOLD_50NS_gc;
            case TWI_SDAHOLD_300NS_gc :
                TWI0_CTRLA = TWI_SDAHOLD_300NS_gc;
            case TWI_SDAHOLD_500NS_gc :
                TWI0_CTRLA = TWI_SDAHOLD_500NS_gc;
            default :
                break;
        }
        
        if(TWI_MODE == TWI_MODE_HOST) {               
            // enable smart mode
            if(twi_bus->smart) TWI0_MCTRLA = TWI_SMEN_bm;          
            
            // set SM, FM or FM+ based on FREQ
            if(FREQ == 1000000UL) {
                TWI0_CTRLA = TWI_FMPEN_ON_gc;
            }
            else {
                TWI0_CTRLA = TWI_FMPEN_OFF_gc;
            }

            // set FREQ rate
            TWI0_MBAUD = TWI0_BAUDRATE(FREQ, 0);
            
            // configure TIMEOUT
            switch(twi_bus->timeout) {
                case TWI_TIMEOUT_DISABLED_gc :
                    TWI0_CTRLA = TWI_TIMEOUT_DISABLED_gc;
                case TWI_TIMEOUT_50US_gc :
                    TWI0_CTRLA = TWI_TIMEOUT_50US_gc;
                case TWI_TIMEOUT_100US_gc :
                    TWI0_CTRLA = TWI_TIMEOUT_100US_gc;
                case TWI_TIMEOUT_200US_gc :
                    TWI0_CTRLA = TWI_TIMEOUT_200US_gc;
                default :
                    break;
            }

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
        }
        
        if(TWI_MODE == TWI_MODE_CLIENT) {
            // enable smart mode
            if(twi_bus->smart) TWI0_SCTRLA = TWI_SMEN_bm;
                
            // set address
            TWI0_SADDR = TWI0_ADDR;

            // set ENABLE bit
            TWI0_SCTRLA = TWI_ENABLE_bm;
            
            return(0);
        }
        
        if(TWI_MODE == TWI_MODE_DUAL) {
            // configure INPUTLVL
            switch(twi_bus->bustype) {
                case TWI_I2C :
                    TWI0_DUALCTRL = TWI_INPUTLVL_I2C_gc;
                case TWI_SMB :
                    TWI0_DUALCTRL = TWI_INPUTLVL_SMBUS_gc;
                default :
                    break;
            }

            // configure SDASETUP
            switch(twi_bus->sdasetup) {
                case TWI_SDASETUP_4CYC_gc :
                    TWI0_DUALCTRL = TWI_SDASETUP_4CYC_gc;
                case TWI_SDASETUP_8CYC_gc :
                    TWI0_DUALCTRL = TWI_SDASETUP_8CYC_gc;
                default :
                    break;
            }

            // enable smart mode
            if(twi_bus->smart) TWI0_SCTRLA = TWI_SMEN_bm;
            
            // set address
            TWI0_SADDR = TWI0_ADDR;

            // set ENABLE bit
            TWI0_DUALCTRL = TWI_ENABLE_bm;
            
            return(0);
        }
    }
    
    if(TWIPORT == TWI1_PORT) { 
        // set twi pin mux
        switch(twi_bus->pins) {
            case TWI_PINS_ALT1 :
                PORTMUX_TWIROUTEA = PORTMUX_TWI1_DEFAULT_gc;   /* PF2, PF3 */
            case TWI_PINS_ALT2 :
                PORTMUX_TWIROUTEA = PORTMUX_TWI1_ALT2_gc;   /* PB2, PB3 */
            case TWI_PINS_DEFAULT :
                PORTMUX_TWIROUTEA = PORTMUX_TWI1_DEFAULT_gc;    /* PF2, PF3, PB2, PB3 */
            default :
                break;
        }

        if(TWI_MODE != TWI_MODE_DUAL) {
            // configure INPUTLVL
            switch(twi_bus->bustype) {
                case TWI_I2C :
                    TWI1_CTRLA = TWI_INPUTLVL_I2C_gc;
                case TWI_SMB :
                    TWI1_CTRLA = TWI_INPUTLVL_SMBUS_gc;
                default :
                    break;
            }

            // configure SDASETUP
            switch(twi_bus->sdasetup) {
                case TWI_SDASETUP_4CYC_gc :
                    TWI1_CTRLA = TWI_SDASETUP_4CYC_gc;
                case TWI_SDASETUP_8CYC_gc :
                    TWI1_CTRLA = TWI_SDASETUP_8CYC_gc;
                default :
                    break;
            }
        }
        
        // configure SDAHOLD 
        switch(twi_bus->sdahold) {
            case TWI_SDAHOLD_OFF_gc :
                TWI1_CTRLA = TWI_SDAHOLD_OFF_gc;
            case TWI_SDAHOLD_50NS_gc :
                TWI1_CTRLA = TWI_SDAHOLD_50NS_gc;
            case TWI_SDAHOLD_300NS_gc :
                TWI1_CTRLA = TWI_SDAHOLD_300NS_gc;
            case TWI_SDAHOLD_500NS_gc :
                TWI1_CTRLA = TWI_SDAHOLD_500NS_gc;
            default :
                break;
        }
        
        if(TWI_MODE == TWI_MODE_HOST) {           
            // enable smart mode
            if(twi_bus->smart) TWI1_MCTRLA = TWI_SMEN_bm;          
            
            // set SM, FM or FM+ based on FREQ
            if(FREQ == 1000000UL) {
                TWI1_CTRLA = TWI_FMPEN_ON_gc;
            }
            else {
                TWI1_CTRLA = TWI_FMPEN_OFF_gc;
            }

            // set FREQ rate
            TWI1_MBAUD = TWI1_BAUDRATE(FREQ, 0);
            
            // configure TIMEOUT
            switch(twi_bus->timeout) {
                case TWI_TIMEOUT_DISABLED_gc :
                    TWI1_CTRLA = TWI_TIMEOUT_DISABLED_gc;
                case TWI_TIMEOUT_50US_gc :
                    TWI1_CTRLA = TWI_TIMEOUT_50US_gc;
                case TWI_TIMEOUT_100US_gc :
                    TWI1_CTRLA = TWI_TIMEOUT_100US_gc;
                case TWI_TIMEOUT_200US_gc :
                    TWI1_CTRLA = TWI_TIMEOUT_200US_gc;
                default :
                    break;
            }
            
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
        }
        
        if(TWI_MODE == TWI_MODE_CLIENT) {
            // enable smart mode
            if(twi_bus->smart) TWI1_SCTRLA = TWI_SMEN_bm;

            // set address
            TWI1_SADDR = TWI1_ADDR;

            // set ENABLE bit
            TWI1_SCTRLA = TWI_ENABLE_bm;

            return(0);                                
        }
        
        if(TWI_MODE == TWI_MODE_DUAL) {
            // configure INPUTLVL
            switch(twi_bus->bustype) {
                case TWI_I2C :
                    TWI1_DUALCTRL = TWI_INPUTLVL_I2C_gc;
                case TWI_SMB :
                    TWI1_DUALCTRL = TWI_INPUTLVL_SMBUS_gc;
                default :
                    break;
            }

            // configure SDASETUP
            switch(twi_bus->sdasetup) {
                case TWI_SDASETUP_4CYC_gc :
                    TWI1_DUALCTRL = TWI_SDASETUP_4CYC_gc;
                case TWI_SDASETUP_8CYC_gc :
                    TWI1_DUALCTRL = TWI_SDASETUP_8CYC_gc;
                default :
                    break;
            }

            // enable smart mode
            if(twi_bus->smart) TWI1_SCTRLA = TWI_SMEN_bm;
            
            // set address
            TWI1_SADDR = TWI1_ADDR;

            // set ENABLE bit
            TWI1_DUALCTRL = TWI_ENABLE_bm;
                            
            return(0);
        }    
    }
}

