set script_dir [file dirname [info script]]
source [file join $script_dir hardware_helpers.tcl]
set root $p2::dir
foreach f {Results/BUILD_SUCCESS.txt Hardware/radar_top.bit Hardware/radar_top.ltx} {
    if {![file exists [file join $root $f]]} {error "Missing $f; finish RUN_PROJECT2.cmd first"}
}
open_hw_manager
if {[llength [get_hw_servers -quiet]]==0} {connect_hw_server}
if {[llength [get_hw_targets -quiet -filter {IS_OPENED == 1}]]==0} {
    set targets [get_hw_targets -quiet]
    if {[llength $targets]!=1} {error "Select and open the PYNQ-Z2 hardware target manually; found [llength $targets] targets"}
    current_hw_target [lindex $targets 0];open_hw_target
}
set devs [get_hw_devices -quiet -filter {PART =~ "xc7z020*"}]
if {[llength $devs]!=1} {error "Expected exactly one connected xc7z020 board; select the intended PYNQ-Z2"}
set dev [lindex $devs 0];current_hw_device $dev
set_property PROGRAM.FILE [file join $root Hardware radar_top.bit] $dev
set_property PROBES.FILE [file join $root Hardware radar_top.ltx] $dev
set_property FULL_PROBES.FILE [file join $root Hardware radar_top.ltx] $dev
program_hw_devices $dev
refresh_hw_device $dev
p2::attach
foreach f {HARDWARE_PASS.txt hardware_results.csv} {
    if {[file exists [file join $root Results $f]]} {file delete [file join $root Results $f]}
}
radar_reset
puts "PROJECT 2 PROGRAMMED. Try radar_run_case 1 4 (expected: 3 targets at 30,60,85)."
