# Run from Vivado Tcl Console: source {C:/.../Project1_AES_Timing_Repair/BUILD_REPAIRED.tcl}
# Or: vivado -mode batch -source BUILD_REPAIRED.tcl
set root [file dirname [file normalize [info script]]]
cd $root
set mode repaired
if {[info exists argv] && [llength $argv]>0} {set mode [lindex $argv 0]}
if {$mode ni {repaired original}} {error "Mode must be repaired or original"}
set rtl_dir [expr {$mode eq "original" ? "Original_RTL" : "RTL"}]
set build [file join $root build_$mode]
if {[file exists $build]} {error "build_$mode exists. Rename that directory before rerunning; previous outputs are preserved."}
if {[llength [get_projects -quiet]]} {close_project}
create_project aes125_$mode $build -part xc7z020clg400-1
add_files [list [file join $root $rtl_dir aes_core.v] [file join $root $rtl_dir aes_top.v]]
add_files -fileset constrs_1 [file join $root RTL pynq.xdc]
set_property top aes_top [get_filesets sources_1]
# Recreate VIO with the original probe layout and zero initialization.
create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name vio_0
set_property -dict [list CONFIG.C_NUM_PROBE_IN {2} CONFIG.C_NUM_PROBE_OUT {4} \
 CONFIG.C_PROBE_IN0_WIDTH {128} CONFIG.C_PROBE_IN1_WIDTH {1} \
 CONFIG.C_PROBE_OUT0_WIDTH {128} CONFIG.C_PROBE_OUT1_WIDTH {128} \
 CONFIG.C_PROBE_OUT2_WIDTH {1} CONFIG.C_PROBE_OUT3_WIDTH {1} \
 CONFIG.C_EN_PROBE_IN_ACTIVITY {1} \
 CONFIG.C_PROBE_OUT0_INIT_VAL {0x0} CONFIG.C_PROBE_OUT1_INIT_VAL {0x0} \
 CONFIG.C_PROBE_OUT2_INIT_VAL {0x0} CONFIG.C_PROBE_OUT3_INIT_VAL {0x0}] [get_ips vio_0]
generate_target all [get_ips vio_0]
create_ip_run [get_ips vio_0]
# Regression tests cover repaired and original implementations together.
add_files -fileset sim_1 [list [file join $root Testbench tb_aes_repair.sv] \
 [file join $root Testbench aes_core_original.v]]
# Original-only mode tests original twice, which still validates golden outputs.
set_property top tb_aes_repair [get_filesets sim_1]
set_property xsim.simulate.runtime {0ns} [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
# XSim runs from its own directory, so put vector data at the path used by the testbench.
set sim_dir [file join $build aes125_$mode.sim sim_1 behav xsim]
file mkdir [file join $sim_dir Testbench]
file copy [file join $root Testbench vectors.mem] [file join $sim_dir Testbench vectors.mem]
launch_simulation
run all
close_sim
set sim_dir [file join $build aes125_$mode.sim sim_1 behav xsim]
set sim_pass 0
foreach log [glob -nocomplain [file join $sim_dir *.log]] {
 set f [open $log r]; set log_text [read $f]; close $f
 if {[string match "*PASS: cycle-by-cycle original/repaired equivalence throughout*" $log_text]
     && ![string match "*FATAL*" $log_text]} {set sim_pass 1}
}
if {!$sim_pass} {error "Regression did not reach its final PASS marker. Inspect simulation logs; build stopped."}
# Prefer timing-oriented placement, routing and post-route physical optimization.
set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]
launch_runs vio_0_synth_1 -jobs 4
wait_on_run vio_0_synth_1
if {![string match "*Complete*" [get_property STATUS [get_runs vio_0_synth_1]]]} {error "VIO synthesis did not complete"}
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {![string match "*Complete*" [get_property STATUS [get_runs synth_1]]]} {error "Synthesis did not complete"}
launch_runs impl_1 -to_step route_design -jobs 4
wait_on_run impl_1
set impl_dir [get_property DIRECTORY [get_runs impl_1]]
if {![file exists [file join $impl_dir .route_design.end.rst]] || ![file exists [file join $impl_dir aes_top_routed.dcp]]} {error {Routing did not produce a completed checkpoint}}
close_project
open_checkpoint [file join $impl_dir aes_top_routed.dcp]
# Apply the intended post-route optimization explicitly (Vivado 2025.1.1).
phys_opt_design -directive Explore
set out [file join $build verified_outputs]
file mkdir $out
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 20 -file [file join $out timing_summary_routed.rpt]
report_timing -delay_type max -max_paths 20 -file [file join $out setup_paths.rpt]
report_timing -delay_type min -max_paths 20 -file [file join $out hold_paths.rpt]
report_utilization -file [file join $out utilization_routed.rpt]
report_drc -file [file join $out drc_routed.rpt]
report_methodology -file [file join $out methodology_routed.rpt]
report_route_status -file [file join $out route_status.rpt]
report_clocks -file [file join $out clocks.rpt]
check_timing -verbose -file [file join $out check_timing.rpt]
report_bus_skew -file [file join $out bus_skew_routed.rpt]
write_checkpoint [file join $out aes_top_routed.dcp]
# Gate on setup, hold, pulse-width and unconstrained paths. Reports remain available on failure.
set f [open [file join $out timing_summary_routed.rpt] r]
set timing_text [read $f]; close $f
if {![string match "*All user specified timing constraints are met*" $timing_text]} {
 error "TIMING NOT CLOSED: inspect verified_outputs/timing_summary_routed.rpt. No bitstream is exported."
}
foreach check {no_clock unconstrained_internal_endpoints} {
 if {![regexp "checking $check \\(0\\)" $timing_text]} {
  error "Timing coverage check $check is not zero. No bitstream is exported."
 }
}
set f [open [file join $out bus_skew_routed.rpt] r]
set bus_text [read $f]; close $f
if {[string match {*VIOLATED*} $bus_text]} {error {Bus skew failed. No bitstream is exported.}}
# This also enforces Vivado's bitstream DRC checks; do not downgrade their severity.
write_bitstream [file join $out aes_top.bit]
write_debug_probes [file join $out aes_top.ltx]
set f [open [file join $out BUILD_STATUS.txt] w]
puts $f "TIMING PASSED: setup, hold and pulse width under the unchanged 8 ns clock constraint."
puts $f "Mode: $mode. Physical-board verification of this new BIT/LTX remains pending."
close $f
puts "SUCCESS: outputs in $out. Reprogram and verify the new build before calling it board-tested."
