# Executed as the implementation opt_design pre-hook, inside its live netlist.
set hubs [get_debug_cores -quiet dbg_hub]
if {[llength $hubs] != 1} {error "Expected one debug hub for the radar VIO"}
set_property C_CLK_INPUT_FREQ_HZ 50000000 $hubs
set_property C_ENABLE_CLK_DIVIDER false $hubs
set_property C_USER_SCAN_CHAIN 1 $hubs
