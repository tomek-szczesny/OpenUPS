// -----------------------------------------------------------------------------
// AVR microcontroller code
// A part of OpenUPS Project
// Website: https://github.com/tomek-szczesny/OpenUPS
// Authors: Tomek Szczęsny
// License: TBD
// -----------------------------------------------------------------------------

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <util/delay.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include "twi.h"
#include "openups_avr.h"

/* Interrupt handlers */

void init (void) {	/* Initialization routine */

}

int main (void)
{
    init();
    struct twi_bus *twi_bus;
    uint8_t temperature = 0x00;
    uint8_t MCP9808_ADDR = 0x18;
    uint8_t ta_reg = 0x05;

    _PROTECTED_WRITE(CLKCTRL.OSCHFCTRLA, CLKCTRL_FRQSEL_4M_gc); 

    // assign twi0 bus structure
    twi_bus = &i2c_bus0;

    // setup twi port 0 as i2c host
    if(twi_init(TWI0_PORT, TWI_MODE_HOST, TWI0_BAUD, &i2c_bus0) == FAIL) error(TWI_ERROR_NOHOST);
    
    // initialize data buffer
    for (uint8_t i = 0; i < MAX_DATA_SIZE; i++) {
        data[i] = 0x00;
    }
    
    PORTC_DIRSET = 0x40;
    PORTC_OUTSET = 0x40;
    
    while (1) {

        uint8_t len = 2;
        
        // read ta register
        if(twi_read_reg(TWI0_PORT, MCP9808_ADDR, ta_reg, &data[0], len) != len) error(10);
        
        // clear mcp9808 flag bits
        data[0] = data[0] & 0x1F;
        
        temperature = 0x00;
             
        if ((data[0] & 0x10) == 0x10){
            // TA < 0°C clear sign
            data[0] = data[0] & 0x0F;
            temperature = 256-(data[0]*16) + (data[1]/16);
        }
        else {
            // TA ≥ 0°C Temperature = Ambient Temperature (°C)
            temperature = ((data[0])*16) + ((data[1])/16);
        }

        PORTC_DIRSET = 0x40;
        for (int i = temperature; i > 0; i--) {
            PORTC_OUTCLR = 0x40;
            _delay_ms(500);
            PORTC_OUTSET = 0x40;
            _delay_ms(500);
        }
        _delay_ms(1500);
    }
}

void flash_led(uint8_t num) {
    PORTC_DIRSET = 0x40;
    for (int i = num; i > 0; i--) {
        PORTC_OUTCLR = 0x40;
        _delay_ms(500);
        PORTC_OUTSET = 0x40;
        _delay_ms(500);
    }
}

/* error handler */
void error(uint8_t num)
{
    num &= 0x7F;
    PORTC_DIRSET = 0x40;
    for (int i = 0; i <= num-1; i++) {
        PORTC_OUTSET = 0x40;
        _delay_ms(100);
        PORTC_OUTCLR = 0x40;
        _delay_ms(100);
    }
    _delay_ms(1000);
}
