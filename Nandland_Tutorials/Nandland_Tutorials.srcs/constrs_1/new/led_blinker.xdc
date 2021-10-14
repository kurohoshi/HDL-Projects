set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN Y9 [get_ports clk]
create_clock -period 10 [get_ports clk]

set_property IOSTANDARD LVCMOS33 [get_ports driver_led]
set_property PACKAGE_PIN T22 [get_ports driver_led]

set_property IOSTANDARD LVCMOS25 [get_ports enable]
set_property IOSTANDARD LVCMOS25 [get_ports switch_1]
set_property IOSTANDARD LVCMOS25 [get_ports switch_2]
set_property PACKAGE_PIN F22 [get_ports enable]
set_property PACKAGE_PIN G22 [get_ports switch_2]
set_property PACKAGE_PIN H22 [get_ports switch_1]
