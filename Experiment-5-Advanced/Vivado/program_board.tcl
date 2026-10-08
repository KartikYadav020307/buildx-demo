set p5_program_root [file normalize [file join [file dirname [info script]] ..]]
set f [open [file join $p5_program_root Results LATEST_SUCCESS_PATH.txt] r];set out [string trim [read $f]];close $f
    if {[file pathtype $out] eq "relative"} {set out [file normalize [file join $p5_program_root $out]]}
source [file join $p5_program_root Vivado unpack_bitstream.tcl]
p5_unpack_bitstream $out
foreach file {BUILD_SUCCESS.txt bnn_board_top.bit bnn_board_top.ltx} {
    if {![file exists [file join $out $file]]} {error "Latest successful build is missing $file."}
}
open_hw_manager
if {![llength [get_hw_servers -quiet]]} {connect_hw_server}
set targets [get_hw_targets -quiet]
if {[llength $targets]!=1} {error "Expected one JTAG target. Choose your board in Hardware Manager if several targets are present."}
current_hw_target [lindex $targets 0]
if {![get_property IS_OPENED [current_hw_target]]} {open_hw_target}
set devices [get_hw_devices -quiet -filter {PART =~ xc7z020*}]
if {[llength $devices]!=1} {error "Expected exactly one connected xc7z020 device. Found $devices"}
set dev [lindex $devices 0];current_hw_device $dev
set_property PROGRAM.FILE [file join $out bnn_board_top.bit] $dev
set_property PROBES.FILE [file join $out bnn_board_top.ltx] $dev
set_property FULL_PROBES.FILE [file join $out bnn_board_top.ltx] $dev
program_hw_devices $dev
refresh_hw_device $dev
puts "Project 5 programmed from $out; next source Vivado/hardware_test.tcl."
