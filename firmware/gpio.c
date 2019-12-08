/*
 * Author: Mikeqin <Fengling.Qin@gmail.com>
 *
 * This is free and unencumbered software released into the public domain.
 * For details see the UNLICENSE file at the root of the source tree.
 */

#include "system_config.h"
#include "io.h"
#include "gpio.h"

static struct rv32_gpio *gpio = (struct rv32_gpio *)GPIO_BASE;

void gpio_write_led(uint32_t led)
{
	writel(led, &gpio->reg);
}

uint32_t gpio_read_led(void)
{
	return readl(&gpio->reg);
}
