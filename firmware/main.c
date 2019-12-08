/*
 * Author: Fengling <Fengling.Qin@gmail.com>
 *
 * This is free and unencumbered software released into the public domain.
 * For details see the UNLICENSE file at the root of the source tree.
 */

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

#include "minilibc.h"
#include "system_config.h"
#include "io.h"
#include "gpio.h"
#include "timer.h"

int main (void)
{
	int i;
	uint32_t leds = 0;

	gpio_write_led (leds);

	while (1) {
		leds = 1;
		for (i = 0; i < 5; i++) {
			gpio_write_led (leds);
			leds <<= 1;
			delay(CPU_FREQUENCY / 5 / 16);
		}
	}

	return 0;
}
