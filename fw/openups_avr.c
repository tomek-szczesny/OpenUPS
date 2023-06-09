// -----------------------------------------------------------------------------
// AVR microcontroller code
// A part of OpenUPS Project
// Website: https://github.com/tomek-szczesny/OpenUPS
// Authors: Tomek Szczęsny
// License: TBD
// -----------------------------------------------------------------------------

#include <avr/io.h>
#include <stdbool.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <util/delay.h>
#include "openups_avr.h"

/* Interrupt handlers */

void init (void) {	/* Initialization routine */

}

int main (void)
{
    init();
    struct twi_bus *twi_bus;
    twi_bus = &i2c_bus0;
    
    _delay_ms(500);
    // setup i2c port 0 as host
    if(twi_init(TWI0_PORT, TWI_MODE_HOST, TWI0_BAUD, twi_bus)) error(TWI_ERROR_NOHOST);
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
    if(twi_init(TWI1_PORT, TWI_MODE_CLIENT, TWI1_BAUD,  twi_bus)) error(TWI_ERROR_NOHOST);
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

/* error handler */
void error(uint8_t num)
{
    PORTC_DIRSET = 0x40;
    for (int i = 0; i <= num; i++) {
        PORTC_OUTSET = 0x40;
        _delay_ms(25);
        PORTC_OUTCLR = 0x40;
        _delay_ms(25);
    }
        _delay_ms(500);
}
