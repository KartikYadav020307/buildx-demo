# PYNQ-Z2: external 125 MHz PHY reference and four user LEDs.
# Pin mappings verified against Xilinx xup_fpga_vivado_flow pynq-z2/lab5.
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports sysclk]
create_clock -name sys_clk_pin -period 8.000 [get_ports sysclk]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {led[3]}]
# LEDs are visual indicators with no synchronous external receiver.
# Exempt only their output paths, never the detector/VIO internal paths.
set_false_path -to [get_ports {led[*]}]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
