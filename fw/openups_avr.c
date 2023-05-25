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


/* Interrupt handlers */

void init (void) {	/* Initialization routine */

}

int main (void)
{
    init();
    PORTC_DIRSET = 0x40;
    while (1) {            /* Main Loop */
        PORTC_OUTSET = 0x40;
        _delay_ms(100);
        PORTC_OUTCLR = 0x40;
        _delay_ms(100);
    }
    return (0);
}
