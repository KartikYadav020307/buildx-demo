# Run when implementation/bitstream generation has completed.
set nn_root [file normalize [file join [file dirname [info script]] ..]]
set run_status [get_property STATUS [get_runs impl_1]]
if {![string match "*write_bitstream Complete*" $run_status]} {error "Bitstream not complete: $run_status"}
open_run impl_1
set out [file join $nn_root Results]
file mkdir $out
# Refresh methodology before the timing summary includes its results.
report_methodology -file [file join $out methodology.rpt]
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose \
    -file [file join $out timing_summary.rpt]
report_utilization -hierarchical -file [file join $out utilization_hierarchical.rpt]
report_clocks -file [file join $out clocks.rpt]
report_drc -file [file join $out drc.rpt]
# Timing summary does not include the vendor debug IP bus-skew checks.
report_bus_skew -delay_type min_max -warn_on_violation -file [file join $out bus_skew.rpt]
write_debug_probes -force [file join $out nn_board_top.ltx]
set run_dir [get_property DIRECTORY [get_runs impl_1]]
file copy -force [file join $run_dir nn_board_top.bit] [file join $out nn_board_top.bit]
set setup_path [get_timing_paths -quiet -max_paths 1 -delay_type max]
set hold_path [get_timing_paths -quiet -max_paths 1 -delay_type min]
if {[llength $setup_path] == 0 || [llength $hold_path] == 0} {error "No timing paths. Inspect timing_summary.rpt."}
set wns [get_property SLACK $setup_path]
set whs [get_property SLACK $hold_path]
puts "Reports and programming pair saved in $out"
puts "Also inspect bus_skew.rpt and methodology.rpt; BUILD_SUCCESS checks setup/hold only."
puts "Worst setup slack=$wns ns; worst hold slack=$whs ns. Inspect timing summary / DRC / unconstrained paths."
if {$wns < 0 || $whs < 0} {error "Timing failed. Do not report 50 MHz as achieved."}
