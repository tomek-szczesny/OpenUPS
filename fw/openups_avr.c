// -----------------------------------------------------------------------------
// AVR microcontroller code
// A part of OpenUPS Project
// Website: https://github.com/tomek-szczesny/OpenUPS
// Authors: Tomek Szczęsny
// License: TBD
// -----------------------------------------------------------------------------

#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <util/delay.h>
#include "twi.h"

/* Interrupt handlers */

void init (void) {	/* Initialization routine */

}

int main (void)
{
    init();
    // setup i2c port 0 as host
    if(twi_init(TWI_MODE_HOST, TWI0_I2C, TWI0_BAUD)) error(TWI_ERROR_NOHOST);
    PORTC_DIRSET = 0x40;
    if(TWI0_MSTATUS > 0) {
        for (int i = 0; i <= TWI0_MSTATUS; i++) {
            PORTC_OUTCLR = 0x40;
            _delay_ms(50);
            PORTC_OUTSET = 0x40;
            _delay_ms(50);
        }
    }
    _delay_ms(500);
    // setup i2c port 1 as client
    if(twi_init(TWI_MODE_CLIENT, TWI1_I2C, TWI1_BAUD)) error(TWI_ERROR_NOHOST);
    PORTC_DIRSET = 0x40;
    if(TWI1_MSTATUS > 0) {
        for (int i = 0; i <= TWI1_MSTATUS; i++) {
            PORTC_OUTCLR = 0x40;
            _delay_ms(50);
            PORTC_OUTSET = 0x40;
            _delay_ms(50);
        }
    }
    return (0);
}
