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
#include "peripherals/TWI/twi.h"
#include "devices/MCP9808/MCP9808.h"
#include "openups_avr.h"

/* Interrupt handlers */

void init (void) {	/* Initialization routine */

    // setup cpu clock
    _PROTECTED_WRITE(CLKCTRL_OSCHFCTRLA, CLKCTRL_FRQSEL_24M_gc); 

    // setup sleep controller to standby
    SLPCTRL_CTRLA = SLPCTRL_SMODE_STDBY_gc | SLPCTRL_SEN_bm;

    // setup twi port 0 as i2c host
    if(twi_init(&i2c_bus0) == FAIL) error(TWI_ERROR_NOHOST);

    // setup curiosity nano builtin led
    PORTC_DIRSET = 0x40;
    PORTC_OUTSET = 0x40;
    
}


int main (void)
{
    init();
       
    while (1) {
    
    flash_led(mcp9808_get_temp(TWI0_PORT, MCP9808_ADDR));
    _delay_ms(1500);
    }
}


void flash_led(uint8_t num) {
    PORTC_DIRSET = 0x40;
    for (uint8_t i = num; i > 0; i--) {
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
    for (uint8_t i = 0; i <= num-1; i++) {
        PORTC_OUTSET = 0x40;
        _delay_ms(100);
        PORTC_OUTCLR = 0x40;
        _delay_ms(100);
    }
    _delay_ms(1000);
}
