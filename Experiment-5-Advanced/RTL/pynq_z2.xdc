# Pins checked against AMD/Xilinx PYNQ-Z2 board constraints (see Documentation/SOURCES.md).
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports sysclk]
# Clocking Wizard owns the 125 MHz input clock definition; avoid a duplicate create_clock.
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports {btn[0]}]
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports {btn[1]}]
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS33} [get_ports {btn[2]}]
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS33} [get_ports {btn[3]}]
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33} [get_ports {sw[0]}]
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports {sw[1]}]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
# Only asynchronous inputs to their first synchronizer are excepted.
set_false_path -from [get_ports {btn[*] sw[*]}] -to [get_cells -hier -filter {NAME =~ *io_meta_reg*}]
# LEDs are human-visible status outputs, without an external sampling clock.
set_false_path -to [get_ports {led[*]}]
