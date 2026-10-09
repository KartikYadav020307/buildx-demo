# PYNQ-Z2 external PL clock and four user LEDs. Source: AMD PYNQ board constraints.
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports sysclk]
# The nn_clk Clocking Wizard IP supplies the 8 ns primary clock constraint.
# Do not redefine it here: doing so overrides clock references in IP constraints.
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
# LEDs are status indicators, not a synchronous data interface.
set_false_path -to [get_ports {led[*]}]
