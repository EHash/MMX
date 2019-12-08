/*
 * Author: Fengling <Fengling.Qin@gmail.com>
 *
 * This is free and unencumbered software released into the public domain.
 * For details see the UNLICENSE file at the root of the source tree.
 */

#ifndef _SYSTEM_CONFIG_H_
#define _SYSTEM_CONFIG_H_

#define CPU_FREQUENCY_MHZ	(100)
#define CPU_FREQUENCY		(CPU_FREQUENCY_MHZ * 1000 * 1000) /* 100Mhz */

/* Registers */
#define GPIO_BASE		(0x10000000)

#endif /* _SYSTEM_CONFIG_H_ */
