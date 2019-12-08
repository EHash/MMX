#######################################################################
##                              ZedBoard                            ##
#######################################################################

# Clocks
set_property IOSTANDARD LVCMOS33 [get_ports sysclk_i]
set_property PACKAGE_PIN Y9 [get_ports sysclk_i]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5.000} [get_ports {sysclk_i}];

# LEDs
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_led_o[0]}]
set_property PACKAGE_PIN T22  [get_ports {gpio_led_o[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_led_o[1]}]
set_property PACKAGE_PIN T21  [get_ports {gpio_led_o[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_led_o[2]}]
set_property PACKAGE_PIN U22  [get_ports {gpio_led_o[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_led_o[3]}]
set_property PACKAGE_PIN U21  [get_ports {gpio_led_o[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_led_o[4]}]
set_property PACKAGE_PIN V22 [get_ports {gpio_led_o[4]}]

#######################################################################
##                         Bitstream Settings                        ##
#######################################################################

set_property CFGBVS VCCO [current_design]
