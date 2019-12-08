/*
 * Author: Fengling <Fengling.Qin@gmail.com>
 *
 * This is free and unencumbered software released into the public domain.
 * For details see the UNLICENSE file at the root of the source tree.
 */

#include "system_config.h"
#include "io.h"
#include "timer.h"

int delay(int ticks)
{
	while (ticks--) {
		__asm__ volatile (
				"addi   x0, x0, 0\n\t"
				);
	}

	return 0;
}
