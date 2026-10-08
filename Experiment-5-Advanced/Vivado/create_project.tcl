# Called by run_all.tcl; recreate a clean project, preserving earlier builds.
if {![info exists p5_root]} {set p5_root [file normalize [file join [file dirname [info script]] ..]]}
set p5_build [file join $p5_root build]
if {[file exists $p5_build]} {
    set archive [file join $p5_root build_archive [clock format [clock seconds] -format %Y%m%d_%H%M%S]]
    file mkdir [file dirname $archive]
    if {[file exists $archive]} {append archive _[clock clicks]}
    file rename $p5_build $archive
}
create_project BNN_Safety $p5_build -part xc7z020clg400-1
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set p5_sources {}
foreach f {bnn_math_pkg.sv bnn_parallel.sv bnn_folded.sv bnn_config.sv bnn_safety.sv bnn_system.sv bnn_board_top.sv} {
    lappend p5_sources [file join $p5_root RTL $f]
}
add_files $p5_sources
set_property top bnn_board_top [get_filesets sources_1]
add_files -fileset constrs_1 [file join $p5_root RTL pynq_z2.xdc]
add_files -fileset sim_1 [glob [file join $p5_root Testbench tb_*.sv]]
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name bnn_clk
set_property -dict [list CONFIG.PRIM_IN_FREQ {125.000} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50.000} \
 CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} CONFIG.USE_RESET {true} \
 CONFIG.RESET_TYPE {ACTIVE_HIGH} CONFIG.USE_LOCKED {true}] [get_ips bnn_clk]
create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name bnn_vio
set p5_props [list CONFIG.C_NUM_PROBE_IN 25 CONFIG.C_NUM_PROBE_OUT 6]
set widths_in {1 8 16 5 16 2 2 9 36 16 16 16 16 32 32 32 32 32 32 32 32 32 16 26 16}
set widths_out {1 1 4 1 6 32}
for {set i 0} {$i<25} {incr i} {lappend p5_props CONFIG.C_PROBE_IN${i}_WIDTH [lindex $widths_in $i]}
for {set i 0} {$i<6} {incr i} {
    lappend p5_props CONFIG.C_PROBE_OUT${i}_WIDTH [lindex $widths_out $i]
    lappend p5_props CONFIG.C_PROBE_OUT${i}_INIT_VAL 0x0
}
set_property -dict $p5_props [get_ips bnn_vio]
generate_target all [get_ips {bnn_clk bnn_vio}]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "P5 project created at $p5_build/BNN_Safety.xpr"
