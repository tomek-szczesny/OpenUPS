
/*
 * Copyright (c) 2023 by the OpenUPS Developers All rights reserved.
 *
 *        File:  BD99950.h
 * Description:  Rohm BD99950 Register Map per Datasheet
 *
*/

#define BD99950_ADDR0                   0x77
#define BD99950_ADDR1                   0x79

#define BD99950_CHARGE_OPTION_WRITE     0x12
#define BD99950_CHARGE_OPTION_READ      0x13
#define BD99950_CHARGE_CURRENT          0x14
#define BD99950_CHARGE_VOLTAGE          0x15
#define BD99950_MIN_SYSTEM_VOLTAGE      0x3E
#define BD99950_ADAPTER_CURRENT         0X3F
#define BD99950_MANUFACTURE_ID          0XFE
#define BD99950_DEVICE_ID               0XFF