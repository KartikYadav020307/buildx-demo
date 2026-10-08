if {[info exists ::env(TCL_LIBRARY)]&&[file isdirectory [file join $::env(TCL_LIBRARY) tcl8]]} {::tcl::tm::path add [file join $::env(TCL_LIBRARY) tcl8]}
set mode [lindex $argv 0]
set target [lindex $argv 1]
set out [file join $target Results mocked_$mode]
file mkdir $out
set argv [list $out]
set top "";set sim_generics {};set stages {}
proc version {args} {return 2025.1.1}
proc current_project {} {return mock_project}
proc create_project {name path args} {file mkdir $path;set f [open [file join $path BNN_Safety.xpr] w];puts $f mock;close $f}
proc get_filesets {name} {return $name}
proc get_ips {args} {return ips}
proc add_files {args} {}
proc create_ip {args} {}
proc generate_target {args} {}
proc update_compile_order {args} {}
proc set_property {args} {
 global top sim_generics
 if {[lindex $args 0] eq "top"} {set top [lindex $args 1]}
 if {[lindex $args 0] eq "generic"} {set sim_generics [lindex $args 1]}
}
proc launch_simulation {args} {
 global top sim_generics mode stages
 lappend stages sim
 if {$mode eq "simfail"&&$top eq "tb_diagnostics"} {return}
 foreach g $sim_generics {if {[regexp {PASS_FILE="(.*)"} $g dummy p]} {set f [open $p w];puts $f "PASS MOCK";close $f}}
}
proc close_sim {} {}
proc get_runs {name} {return $name}
proc launch_runs {args} {global stages;lappend stages [lindex $args 0]}
proc wait_on_runs {args} {}
proc get_property {key obj} {
 global mode
 if {$key eq "STATUS"} {
  if {$obj eq "synth_1"} {if {$mode eq "synthfail"} {return Failed};return "synth_design Complete!"}
  return "route_design Complete!"
 }
 if {$key eq "SLACK"} {if {$mode eq "timingfail"&&$obj eq "setup"} {return -0.01};return 1.5}
 error "Unexpected property $key $obj"
}
proc get_cells {args} {
 global mode
 set f [lindex $args end]
 if {$mode eq "latchfail"&&[string match *LD* $f]} {return LATCH}
 if {$mode eq "dspfail"&&[string match *DSP* $f]} {return DSP}
 return {}
}
proc open_run {args} {}
proc close_design {} {}
proc get_timing_paths {args} {if {[lindex $args end] eq "max"} {return setup};return hold}
proc get_drc_violations {args} {global mode;if {$mode eq "drcfail"} {return violation};return {}}
proc get_clocks {args} {return clock}
proc check_timing {args} {global mode;if {$mode eq "clockfail"} {return "There are 3 register/latch pins with no clock."};return "There are 0 register/latch pins with no clock."}
proc report_timing_summary {args} {
 global mode
 set fail [expr {$mode eq "pulsefail" ? 1 : 0}]
 set path [lindex $args end];set f [open $path w]
 puts $f "WNS(ns) TNS(ns) TNS Failing Endpoints TNS Total Endpoints WHS(ns) THS(ns) THS Failing Endpoints THS Total Endpoints WPWS(ns) TPWS(ns) TPWS Failing Endpoints TPWS Total Endpoints"
 puts $f "---- ---- ----"
 puts $f "1.500 0.000 0 2500 0.050 0.000 0 2500 1.000 0.000 $fail 200"
 close $f
}
proc generic_report {args} {
 global mode
 set p [lindex $args end];set f [open $p w];puts $f "MOCK REPORT"
 if {$mode eq "skewfail"&&[string match *bus_skew* $p]} {puts $f "Slack (VIOLATED) : -1.0"}
 close $f
}
foreach p {report_utilization report_clocks report_drc report_methodology report_cdc report_bus_skew report_pulse_width report_route_status} {proc $p {args} {generic_report {*}$args}}
proc write_bitstream {args} {set f [open [lindex $args end] w];puts $f "MOCK BITSTREAM";close $f}
proc write_debug_probes {args} {set f [open [lindex $args end] w];puts $f "MOCK PROBES";close $f}
proc close_project {} {}
source [file join $target Vivado run_all.tcl]
