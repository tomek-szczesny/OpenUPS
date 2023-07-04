
#include "devices/BD99950/BD99950.h"
#include "devices/NCV81599/NCV81599.h"
#include "devices/BQ76920/BQ76920.h"
#include "devices/LM75BTP/LM75BTP.h"
#include "devices/MCP9808/MCP9808.h"

#define MAX_DATA_SIZE    16

struct twi_bus i2c_bus0 = {
    TWI0_PORT,                  // TWI0_PORT, TWI1_PORT
    TWI_MODE_HOST,              // TWI_MODE_HOST, TWI_MODE_CLIENT, TWI_MODE_DUAL
    400000,                     // twi freq
    TWI_I2C,                    // TWI_I2C, TWI_SMB
    TWI_PINS_DEFAULT,           // TWI_PINS_DEFAULT, TWI_PINS_ALT1, TWI_PINS_ALT2
    TWI_SDAHOLD_50NS_gc,        // TWI_SDAHOLD_OFF_gc, TWI_SDAHOLD_50NS_gc, TWI_SDAHOLD_300NS_gc, TWI_SDAHOLD_500NS_gc
    TWI_SDASETUP_4CYC_gc,       // TWI_SDASETUP_4CYC_gc, TWI_SDASETUP_8CYC_gc
    TWI_TIMEOUT_50US_gc,        // TWI_TIMEOUT_DISABLED_gc, TWI_TIMEOUT_50US_gc, TWI_TIMEOUT_100US_gc, TWI_TIMEOUT_200US_gc 
    false,                      // enable pullups true, false
    false,                      // smart-mode true, false
    false,                      // interrupts true, false
    TWI_INIT,                   // twi state
    };
struct twi_bus i2c_bus1 = {
    TWI1_PORT,                  // TWI0_PORT, TWI1_PORT
    TWI_MODE_CLIENT,            // TWI_MODE_HOST, TWI_MODE_CLIENT, TWI_MODE_DUAL
    400000,                     // twi freq
    TWI_I2C,                    // TWI_I2C, TWI_SMB
    TWI_PINS_DEFAULT,           // TWI_PINS_DEFAULT, TWI_PINS_ALT1, TWI_PINS_ALT2
    TWI_SDAHOLD_50NS_gc,        // TWI_SDAHOLD_OFF_gc, TWI_SDAHOLD_50NS_gc, TWI_SDAHOLD_300NS_gc, TWI_SDAHOLD_500NS_gc
    TWI_SDASETUP_4CYC_gc,       // TWI_SDASETUP_4CYC_gc, TWI_SDASETUP_8CYC_gc
    TWI_TIMEOUT_50US_gc,        // TWI_TIMEOUT_DISABLED_gc, TWI_TIMEOUT_50US_gc, TWI_TIMEOUT_100US_gc, TWI_TIMEOUT_200US_gc 
    false,                      // enable pullups true, false
    false,                      // smart-mode true, false
    true,                       // interrupts true, false
    TWI_INIT,                   // twi state
    };

volatile uint8_t data[MAX_DATA_SIZE];

void flash_led(uint8_t num);   
void error(uint8_t num);
