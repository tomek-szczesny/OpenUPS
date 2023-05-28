/*
 * Copyright (c) 2023 Edward Kisiel hominoid@cablemi.com All rights reserved.
 *
 * File:    twi.c
 * Date:    May 27, 2023
 * Author:  Edward Kisiel
 *
 * Description:
 *
 * AVRDx TWI driver to control the processor's I2C interface.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * Code released under GPLv3: http://www.gnu.org/licenses/gpl.html
*/
 
/* TWI0 setttings */
#define TWI0_I2C            0
#define TWI0_ADDR           0x00
#define TWI0_BAUD           128

/* TWI1 setttings */
#define TWI1_I2C            1
#define TWI1_ADDR           0x69
#define TWI1_BAUD           128

#define TWI_MODE_HOST       0
#define TWI_MODE_CLIENT     1
#define TWI_READ_ACK        1
#define TWI_READ_NACK       0

/* error messages */
#define TWI_ERROR_NOHOST    10

uint8_t twi_init(uint8_t TWI_MODE, uint8_t TWIPORT, uint8_t BAUD);

void error(uint8_t num);