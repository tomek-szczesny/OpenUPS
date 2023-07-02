/*
 * Copyright (c) 2023 Edward Kisiel hominoid@cablemi.com All rights reserved.
 *
 * FILE:        twi.c
 * LICENSE:     GNU GPLv3
 * DESCRIPTION: AVRDx TWI driver for I2C and SMBUS interface.
 *
*/
 
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <util/delay.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include "twi.h"

/* 
 *  DESCRIPTION: twi initialization for all ports and modes.
 *   
 *         NAME: uint8_t twi_init(uint8_t TWIPORT, uint8_t TWI_MODE, uint8_t FREQ, struct twi_bus *twi_bus)
 
 *   PARAMETERS: TWIPORT = TWI0_PORT, TWI1_PORT
 *               TWI_MODE = TWI_MODE_HOST, TWI_MODE_CLIENT, TWI_MODE_DUAL
 *               FREQ = 100000, 400000, 1000000
 *               *twi_bus = struct twi_bus {
 *                  int  bustype;     TWI_I2C, TWI_SMB
 *                  int  pins;        TWI_PINS_DEFAULT, TWI_PINS_ALT1, TWI_PINS_ALT2
 *                  int  sdahold;     TWI_SDAHOLD_OFF_gc, TWI_SDAHOLD_50NS_gc, 
 *                                      TWI_SDAHOLD_300NS_gc, TWI_SDAHOLD_500NS_gc
 *                  int  sdasetup;    TWI_SDASETUP_4CYC_gc, TWI_SDASETUP_8CYC_gc
 *                  int  timeout;     TWI_TIMEOUT_DISABLED_gc, TWI_TIMEOUT_50US_gc
 *                                      TWI_TIMEOUT_100US_gc, TWI_TIMEOUT_200US_gc 
 *                  bool pullup;      true, false
 *                  bool smart;       true, false
 *                  bool intrupt;     true, false
 *
 *       RETURN: SUCCESS = 0, FAIL = -1
 *
 *         TODO: WIP
 *
 */
 
uint8_t twi_init(uint8_t TWIPORT, uint8_t TWI_MODE, uint32_t FREQ, struct twi_bus *twi_bus) {

    if(TWIPORT == TWI0_PORT) {   
        // set twi pin mux
        switch(twi_bus->pins) {
            case TWI_PINS_ALT1 :
                PORTMUX_TWIROUTEA = PORTMUX_TWI0_ALT1_gc;   /* PA2, PA3, PC6, PC7 */
                PORTA_DIRSET = PIN2_bm | PIN3_bm;
                if(twi_bus->pullup == true) PORTA_PINCONFIG = PORT_PULLUPEN_bm;
                PORTA_PINCTRLUPD = PIN2_bm | PIN3_bm;
            case TWI_PINS_ALT2 :
                PORTMUX_TWIROUTEA = PORTMUX_TWI0_ALT2_gc;   /* PC2, PC3, PC6, PC7 */
                PORTC_DIRSET = PIN2_bm | PIN3_bm;
                if(twi_bus->pullup == true) PORTC_PINCONFIG = PORT_PULLUPEN_bm;
                PORTC_PINCTRLUPD = PIN2_bm | PIN3_bm;
            case TWI_PINS_DEFAULT :
                PORTMUX_TWIROUTEA = PORTMUX_TWI0_DEFAULT_gc;    /* PA2, PA3, PC2, PC3 */
                PORTA_DIRSET = PIN2_bm | PIN3_bm;
                if(twi_bus->pullup == true) PORTA_PINCONFIG = PORT_PULLUPEN_bm;
                PORTA_PINCTRLUPD = PIN2_bm | PIN3_bm;
                PORTA_OUT = (0 << PIN2_bp) & (0 << PIN3_bp);
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
            TWI0_MBAUD = TWI0_BAUDRATE(FREQ, 350);
            
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
            
            // set bits for read and write interupts
            if(twi_bus->intrupt) TWI0_MCTRLA = TWI_WIEN_bm | TWI_RIEN_bm;
 
            // set ENABLE bit
            TWI0_MCTRLA = TWI_ENABLE_bm;

            // clear MSTATUS and set BUSSTATE to force idle
            TWI0_MSTATUS = TWI_RIF_bm | TWI_WIF_bm | TWI_CLKHOLD_bm | TWI_RXACK_bm |
                TWI_ARBLOST_bm | TWI_BUSERR_bm | TWI_BUSSTATE_IDLE_gc;
            
            // check for idle state
            if(TWI0_MSTATUS & TWI_BUSSTATE_1_bm == 1) {
                return(SUCCESS);
            }
            else {
                return(FAIL);
            }
        }
        
        if(TWI_MODE == TWI_MODE_CLIENT) {

            // enable smart mode
            if(twi_bus->smart) TWI0_SCTRLA = TWI_SMEN_bm;
                
            // configure SDASETUP
            switch(twi_bus->sdasetup) {
                case TWI_SDASETUP_4CYC_gc :
                    TWI0_CTRLA = TWI_SDASETUP_4CYC_gc;
                case TWI_SDASETUP_8CYC_gc :
                    TWI0_CTRLA = TWI_SDASETUP_8CYC_gc;
                default :
                    break;
            }
            
            // set bits for address, stop and data interupts
            if(twi_bus->intrupt) TWI0_SCTRLA = TWI_APIEN_bm | TWI_DIEN_bm | TWI_PIEN_bm;

            // set address
            TWI0_SADDR = TWI0_ADDR << 1;
            
            // set ENABLE bit
            TWI0_SCTRLA = TWI_ENABLE_bm;
            
            return(SUCCESS);
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
            TWI0_SADDR = TWI0_ADDR << 1;

            // set ENABLE bit
            TWI0_DUALCTRL = TWI_ENABLE_bm;
            
            return(SUCCESS);
        }
    }
    
    if(TWIPORT == TWI1_PORT) { 
        // set twi pin mux
        switch(twi_bus->pins) {
            case TWI_PINS_ALT1 :
                PORTMUX_TWIROUTEA = PORTMUX_TWI1_DEFAULT_gc;   /* PF2, PF3 */
                PORTF_DIRSET = PIN2_bm | PIN3_bm;
                if(twi_bus->pullup == true) PORTF_PINCONFIG = PORT_PULLUPEN_bm;
                PORTF_PINCTRLUPD = PIN2_bm | PIN3_bm;
            case TWI_PINS_ALT2 :
                PORTMUX_TWIROUTEA = PORTMUX_TWI1_ALT2_gc;   /* PB2, PB3 */
                PORTB_DIRSET = PIN2_bm | PIN3_bm;
                if(twi_bus->pullup == true) PORTB_PINCONFIG = PORT_PULLUPEN_bm;
                PORTB_PINCTRLUPD = PIN2_bm | PIN3_bm;
            case TWI_PINS_DEFAULT :
                PORTMUX_TWIROUTEA = PORTMUX_TWI1_DEFAULT_gc;    /* PF2, PF3, PB2, PB3 */
                PORTF_DIRSET = PIN2_bm | PIN3_bm;
                if(twi_bus->pullup == true) PORTF_PINCONFIG = PORT_PULLUPEN_bm;
                PORTF_PINCTRLUPD = PIN2_bm | PIN3_bm;
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
            
            // set bits for read and write interupts
            if(twi_bus->intrupt) TWI1_MCTRLA = TWI_WIEN_bm | TWI_RIEN_bm;
            
            // set ENABLE bit
            TWI1_MCTRLA = TWI_ENABLE_bm;
            
            // clear MSTATUS and set BUSSTATE to force idle
            TWI1_MSTATUS = TWI_RIF_bm | TWI_WIF_bm | TWI_CLKHOLD_bm | TWI_RXACK_bm |
                TWI_ARBLOST_bm | TWI_BUSERR_bm | TWI_BUSSTATE_IDLE_gc;
            
            // check for idle state
            if(TWI1_MSTATUS & TWI_BUSSTATE_1_bm == 1) {
                return(SUCCESS);
            }
            else {
                return(FAIL);
            }
        }
        
        if(TWI_MODE == TWI_MODE_CLIENT) {
        
            // enable smart mode
            if(twi_bus->smart) TWI1_SCTRLA = TWI_SMEN_bm;

            // set bits for address, stop and data interupts
            if(twi_bus->intrupt) TWI1_SCTRLA = TWI_APIEN_bm | TWI_DIEN_bm | TWI_PIEN_bm;

            // configure SDASETUP
            switch(twi_bus->sdasetup) {
                case TWI_SDASETUP_4CYC_gc :
                    TWI1_CTRLA = TWI_SDASETUP_4CYC_gc;
                case TWI_SDASETUP_8CYC_gc :
                    TWI1_CTRLA = TWI_SDASETUP_8CYC_gc;
                default :
                    break;
            }
            
            // set address
            TWI1_SADDR = TWI1_ADDR << 1;

            // set ENABLE bit
            TWI1_SCTRLA = TWI_ENABLE_bm;

            return(SUCCESS);                                
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
            TWI1_SADDR = TWI1_ADDR << 1;

            // set ENABLE bit
            TWI1_DUALCTRL = TWI_ENABLE_bm;
                            
            return(SUCCESS);
        }    
    }
}


/* 
 *  DESCRIPTION: wait for read/write and returns bus state
 *   
 *         NAME: uint8_t twi_wait(uint8_t TWI_PORT, mode)
 *
 *   PARAMETERS: TWIPORT = TWI0_PORT, TWI1_PORT
 *               mode = TWI_READ, TWI_WRITE
 *
 *       RETURN: SUCCESS = 0, FAIL = -1
 *
 *         TODO: WIP
 */
 
uint8_t twi_wait(uint8_t TWI_PORT, uint8_t mode) {
    uint8_t state = TWI_INIT;
    if(TWI_PORT == TWI0_PORT) {
        if(mode == TWI_READ) {
            while(!state) {
                if(TWI0_MSTATUS & TWI_RIF_bm) {
                    state = TWI_READY;
                }
                else if(TWI0_MSTATUS & (TWI_BUSERR_bm | TWI_ARBLOST_bm)) {
                    state = TWI_ERROR;
                }
            }
            return state;
        }    
        if(mode == TWI_WRITE) {
            while(!state) {
                if(TWI0_MSTATUS & TWI_WIF_bm) {
                    if(!(TWI0_MSTATUS & TWI_RXACK_bm)) {
                        state = TWI_ACKED;
                    }
                    else {
                        state = TWI_NACKED;
                    }
                }
                else if(TWI0_MSTATUS & (TWI_BUSERR_bm | TWI_ARBLOST_bm)) {
                    state = TWI_ERROR;
                }
            } 
            return state;        
        }    
    }
    if(TWI_PORT == TWI1_PORT) {
        if(mode == TWI_READ) {
            while(!state) {
                if(TWI1_MSTATUS & TWI_RIF_bm) {
                    state = TWI_READY;
                }
                else if(TWI1_MSTATUS & (TWI_BUSERR_bm | TWI_ARBLOST_bm)) {
                    state = TWI_ERROR;
                }
            }
            return state;
        }    
        if(mode == TWI_WRITE) {
            while(!state) {
                if(TWI1_MSTATUS & TWI_WIF_bm) {
                    if(!(TWI1_MSTATUS & TWI_RXACK_bm)) {
                        state = TWI_ACKED;
                    }
                    else {
                        state = TWI_NACKED;
                    }
                }
                else if(TWI1_MSTATUS & (TWI_BUSERR_bm | TWI_ARBLOST_bm)) {
                    state = TWI_ERROR;
                }
            } 
            return state;        
        }    
    }
}


/* 
 *  DESCRIPTION: starts twi buses 
 *   
 *         NAME: uint8_t twi_start(uint8_t TWIPORT, unit8_t TWIADDR, unit8_t TWICMD)
 *
 *   PARAMETERS: TWIPORT = TWI0_PORT, TWI1_PORT
 *               TWIADDR = client address
 *               TWICMD = TWI_READ, TWI_WRITE
 *
 *       RETURN: SUCCESS = 0, FAIL = -1
 *
 *         TODO: WIP
 */
 
uint8_t twi_start(uint8_t TWIPORT, uint8_t TWIADDR, uint8_t TWICMD) {

    if(TWIPORT == TWI0_PORT) { 
        
        if(TWICMD == TWI_READ) {
            TWI0_MADDR = ((TWIADDR << 1) & TWICMD);
            if(twi_wait(TWI0_PORT, TWI_WRITE) != TWI_ACKED) return(TWI_ERROR_START);
        }

        if(TWICMD == TWI_WRITE) {
            TWI0_MADDR = ((TWIADDR << 1) | TWICMD);
            if(twi_wait(TWI0_PORT, TWI_WRITE) != TWI_ACKED) return(TWI_ERROR_START);
        }
        return(SUCCESS);
    }
    if(TWIPORT == TWI1_PORT) {

        if(TWICMD == TWI_READ) {
            TWI1_MADDR = ((TWIADDR << 1) & TWICMD);
            if(twi_wait(TWI1_PORT, TWI_WRITE) != TWI_ACKED) return(TWI_ERROR_START);
        }

        if(TWICMD == TWI_WRITE) {
            TWI1_MADDR = ((TWIADDR << 1) | TWICMD);
            if(twi_wait(TWI1_PORT, TWI_WRITE) != TWI_ACKED) return(TWI_ERROR_START);
        }
        return(SUCCESS);
    }
}


/* 
 *  DESCRIPTION: polled twi read 
 *   
 *         NAME: void twi_read_poll(uint8_t TWIPORT, volatile uint8_t *data, uint8_t len)
 *
 *   PARAMETERS: TWIPORT = TWI0_PORT, TWI1_PORT
 *               *data = data buffer pointer
 *               len = number of bytes
 *
 *       RETURN: number of bytes read
 *
 *         TODO: WIP
 */
 
uint8_t twi_read_poll(uint8_t TWIPORT, volatile uint8_t *data, uint8_t len) {

    uint8_t c = 0;
           
    if(TWIPORT == TWI0_PORT) { 
        TWI0_MSTATUS = 1 << TWI_CLKHOLD_bp;
        while (len--) {
            if(twi_wait(TWI0_PORT, TWI_READ) == TWI_READY) {
                *data++ = TWI0_MDATA;
                c += 1;
                TWI0_MCTRLB = (c == 0)? TWI_ACKACT_bm | TWI_MCMD_STOP_gc : TWI_MCMD_RECVTRANS_gc;
            }
            else {
                break;      
            }        
        }
    }
    if(TWIPORT == TWI1_PORT) { 
        TWI1_MSTATUS = TWI_CLKHOLD_bp;
        while (len--) {
            if(twi_wait(TWI1_PORT, TWI_READ) == TWI_READY) {
                *data++ = TWI1_MDATA;
                c += 1;
                TWI1_MCTRLB = (c == 0)? TWI_ACKACT_bm | TWI_MCMD_STOP_gc : TWI_MCMD_RECVTRANS_gc;
            }
            else {
                break;      
            }        
        }
        return(c);
    }
}


/* 
 *  DESCRIPTION: polled twi write 
 *   
 *         NAME: uint8_t twi_write_poll(uint8_t TWIPORT, volatile uint8_t *data, uint8_t len)
 *
 *   PARAMETERS: TWIPORT = TWI0_PORT, TWI1_PORT
 *                 *data = data buffer pointer
 *                   len = number of bytes
 *
 *       RETURN: SUCCESS = 0, FAIL = -1
 *
 *         TODO: WIP
 */
 
uint8_t twi_write_poll(uint8_t TWIPORT, volatile uint8_t *data, uint8_t len) {

    uint8_t c = 0;
    
    if(TWIPORT == TWI0_PORT) {
        while (c < len) {
            TWI0_MDATA = data[c];   
            if(twi_wait(TWI0_PORT, TWI_WRITE) != TWI_ACKED) return(TWI_ERROR_NACK);
            c++;
        }
    return(SUCCESS);
    }
    if(TWIPORT == TWI1_PORT) { 
        while (c < len) {
            TWI1_MDATA = data[c];
            if(twi_wait(TWI1_PORT, TWI_WRITE) != TWI_ACKED) return(TWI_ERROR_NACK);
            c++;
        }
    return(SUCCESS);
    }
}


/* 
 *  DESCRIPTION: polled register read 
 *   
 *         NAME: uint8_t twi_read_reg(uint8_t TWIPORT, uint8_t TWIADDR, uint8_t reg_addr, volatile uint8_t *data, uint8_t len)
 *
 *   PARAMETERS: TWIPORT = TWI0_PORT, TWI1_PORT
 *               TWIADDR = client address
 *               reg_addr = register
 *               *data = data buffer pointer
 *               len = number of bytes
 *
 *       RETURN: number of bytes read or FAIL
 *
 *         TODO: WIP
 */
 
uint8_t twi_read_reg(uint8_t TWIPORT, uint8_t TWIADDR, uint8_t reg_addr, volatile uint8_t *data, uint8_t len) {
      
    // address Client Device (Write)
    if(twi_start(TWIPORT, TWIADDR, TWI_WRITE)) return(TWI_ERROR_START);
    
    // write register address
    if(TWIPORT == TWI0_PORT) {
        TWI0_MDATA = reg_addr;
    }
    if(TWIPORT == TWI1_PORT) {
        TWI1_MDATA = reg_addr;
    }
    if(twi_wait(TWIPORT, TWI_WRITE) != TWI_ACKED) return(TWI_ERROR_WRITE);

    //Restart the TWI Bus in READ mode
    if(TWIPORT == TWI0_PORT) {
        TWI0_MADDR |= TWI_READ;
        TWI0_MCTRLB = TWI_MCMD_REPSTART_gc;
    }
    if(TWIPORT == TWI1_PORT) {
        TWI1_MADDR |= TWI_READ;
        TWI1_MCTRLB = TWI_MCMD_REPSTART_gc;
    }   
    if(twi_wait(TWIPORT, TWI_READ) != TWI_READY) return(TWI_ERROR_READ);

    // read characters
    uint8_t c = 0;
    if(TWIPORT == TWI0_PORT) { 
        TWI0_MSTATUS = 1 << TWI_CLKHOLD_bp; 
    }
    if(TWIPORT == TWI1_PORT) { 
        TWI1_MSTATUS = 1 << TWI_CLKHOLD_bp;
    }
    while (len--) {
        if(twi_wait(TWIPORT, TWI_READ) == TWI_READY) {
            *data++ = TWI0_MDATA;
            c += 1;
            if(TWIPORT == TWI0_PORT) {
                TWI0_MCTRLB = (len == 0)? TWI_ACKACT_bm | TWI_MCMD_STOP_gc : TWI_MCMD_RECVTRANS_gc;
            }
            if(TWIPORT == TWI1_PORT) {
                TWI1_MCTRLB = (len == 0)? TWI_ACKACT_bm | TWI_MCMD_STOP_gc : TWI_MCMD_RECVTRANS_gc;
            }
        }
        else {
            break;      
        }        
    }
    return (c);
}