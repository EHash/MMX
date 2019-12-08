/*
 * Author: Mikeqin <Fengling.Qin@gmail.com>
 *
 * This is free and unencumbered software released into the public domain.
 * For details see the UNLICENSE file at the root of the source tree.
 */

#ifndef __GPIO_H__
#define __GPIO_H__

#include <stdint.h>

struct rv32_gpio {
	volatile unsigned int reg; /* GPIO register */
};

void gpio_write_led(uint32_t led);
uint32_t gpio_read_led(void);

#endif	/* __GPIO_H__ */
