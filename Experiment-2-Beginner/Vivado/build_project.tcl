set p2_dir [file normalize [file join [file dirname [info script]] ..]]
cd $p2_dir
foreach d {Results Simulation Hardware Reports Build} {file mkdir [file join $p2_dir $d]}
foreach f {Results/BUILD_SUCCESS.txt Results/BUILD_FAILED.txt Results/HARDWARE_PASS.txt Results/tb_cfar_core_PASS.txt Results/tb_radar_demo_PASS.txt Hardware/radar_top.bit Hardware/radar_top.ltx} {
    if {[file exists $f]} {file delete $f}
}
proc p2_write {path content} {set f [open $path w];puts $f $content;close $f}
proc p2_complete {name} {
    if {![string match *Complete* [get_property STATUS [get_runs $name]]]} {
        error "Run $name did not complete: [get_property STATUS [get_runs $name]]"
    }
}
proc p2_main {} {
    global p2_dir
    # A fresh independent project; only this package's generated Build is used.
    if {[regexp {\s} $p2_dir]} {error "Extract to a path without spaces, for example C:/FPGA_Projects/Project2_Radar_Final"}
    set build_path [file join $p2_dir Build run_[clock format [clock seconds] -format %Y%m%d_%H%M%S]]
    create_project project2_radar $build_path -part xc7z020clg400-1
    p2_write [file join $p2_dir Results project_path.txt] [file join $build_path project2_radar.xpr]
    set_property target_language Verilog [current_project]
    set_property simulator_language Mixed [current_project]
    add_files [list [file join $p2_dir RTL cfar_core.v] [file join $p2_dir RTL radar_demo.v] [file join $p2_dir RTL radar_top.v]]
    add_files -fileset constrs_1 [file join $p2_dir RTL pynq_z2.xdc]
    set_property top radar_top [get_filesets sources_1]
    create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name vio_radar
    set props [list CONFIG.C_NUM_PROBE_IN 17 CONFIG.C_NUM_PROBE_OUT 5]
    set widths {1 1 8 16 16 16 16 16 19 16 16 1 2 2 1 128 32}
    for {set i 0} {$i < [llength $widths]} {incr i} {
        lappend props CONFIG.C_PROBE_IN${i}_WIDTH [lindex $widths $i]
    }
    set widths {1 1 2 2 1}
    set initial {1 0 0 2 0}
    for {set i 0} {$i < 5} {incr i} {
        lappend props CONFIG.C_PROBE_OUT${i}_WIDTH [lindex $widths $i]
        lappend props CONFIG.C_PROBE_OUT${i}_INIT_VAL [lindex $initial $i]
    }
    set_property -dict $props [get_ips vio_radar]
    generate_target all [get_ips vio_radar]
    add_files -fileset utils_1 -norecurse [file join $p2_dir Vivado debug_clock.tcl]
    set_property STEPS.OPT_DESIGN.TCL.PRE [file join $p2_dir Vivado debug_clock.tcl] [get_runs impl_1]
    set n 0
    foreach top {tb_cfar_core tb_radar_demo} {
        incr n
        if {$n == 1} {set simset sim_1} else {set simset sim_demo;create_fileset -simset $simset}
        add_files -fileset $simset [file join $p2_dir Testbench ${top}.sv]
        set_property SOURCE_SET sources_1 [get_filesets $simset]
        set_property top $top [get_filesets $simset]
        set_property xsim.simulate.runtime 0ns [get_filesets $simset]
        # Values beginning with '-' require the explicit named-argument form.
        set_property -name {xsim.simulate.xsim.more_options} -value "-testplusarg OUTDIR=$p2_dir" -objects [get_filesets $simset]
        update_compile_order -fileset $simset
        launch_simulation -simset $simset -mode behavioral
        log_wave -r /
        run all
        close_sim
        set marker [file join $p2_dir Results ${top}_PASS.txt]
        if {![file exists $marker]} {error "Simulation $top did not produce its PASS marker"}
        set f [open $marker r];set result [read $f];close $f
        if {![string match PASS* $result]} {error "Invalid PASS marker for $top"}
    }
    update_compile_order -fileset sources_1
    launch_runs synth_1 -jobs 4
    wait_on_run synth_1
    p2_complete synth_1
    launch_runs impl_1 -to_step route_design -jobs 4
    wait_on_run impl_1
    p2_complete impl_1
    open_run impl_1
    report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -file [file join $p2_dir Reports timing_summary.rpt]
    report_utilization -hierarchical -file [file join $p2_dir Reports utilization.rpt]
    report_drc -file [file join $p2_dir Reports drc.rpt]
    report_methodology -file [file join $p2_dir Reports methodology.rpt]
    report_clock_utilization -file [file join $p2_dir Reports clock_utilization.rpt]
    report_pulse_width -file [file join $p2_dir Reports pulse_width.rpt]
    check_timing -verbose -file [file join $p2_dir Reports check_timing.rpt]
    set wns_path [get_timing_paths -setup -max_paths 1]
    set whs_path [get_timing_paths -hold -max_paths 1]
    if {[llength $wns_path] == 0 || [llength $whs_path] == 0} {error "No internal timing paths found"}
    set wns [get_property SLACK $wns_path];set whs [get_property SLACK $whs_path]
    if {$wns < 0 || $whs < 0} {error "Timing failed: WNS=$wns WHS=$whs"}
    # Check the design timing summary's setup/hold/pulse-width summary row.
    set f [open [file join $p2_dir Reports timing_summary.rpt] r];set ts [read $f];close $f
    set wpws "";set pending 0
    foreach line [split $ts \n] {
        if {[string match *WNS*WPWS* $line]} {set pending 1;continue}
        if {$pending && [regexp {^\s*(-?[0-9]+\.[0-9]+)\s} $line]} {
            set row [regexp -all -inline {\S+} $line]
            if {[llength $row] < 12} {error "Unexpected timing summary row: $line"}
            set wpws [lindex $row 8]
            if {[lindex $row 2]!=0 || [lindex $row 6]!=0 || [lindex $row 10]!=0} {error "Failing timing endpoints in summary"}
            break
        }
    }
    if {$wpws eq "" || ![string is double -strict $wpws] || $wpws < 0} {error "Pulse-width check failed or was not parsed"}
    set drc_bad [get_drc_violations -quiet -filter {SEVERITY == "Error" || SEVERITY == "Critical Warning"}]
    if {[llength $drc_bad]} {error "DRC has errors/critical warnings: $drc_bad"}
    write_debug_probes -force [file join $p2_dir Hardware radar_top.ltx]
    write_bitstream -force [file join $p2_dir Hardware radar_top.bit]
    write_checkpoint -force [file join $p2_dir Reports routed_design.dcp]
    foreach f {Hardware/radar_top.bit Hardware/radar_top.ltx} {
        if {![file exists $f] || [file size $f]==0} {error "Missing hardware output $f"}
    }
    set manifest "Vivado: [version -short]\nPart: xc7z020clg400-1\nClock: 50 MHz\nWNS: $wns ns\nWHS: $whs ns\nWPWS: $wpws ns\n"
    foreach f [concat [glob RTL/*] [glob Testbench/*] [glob Vivado/*.tcl]] {
        set h [open $f rb];set bytes [read $h];close $h
        append manifest "$f bytes=[string length $bytes] crc32=[format %08x [zlib crc32 $bytes]]\n"
    }
    p2_write [file join $p2_dir Results build_manifest.txt] $manifest
    p2_write [file join $p2_dir Results BUILD_SUCCESS.txt] "BUILD SUCCESS\n[clock format [clock seconds]]\n$manifest\nSimulation + routed timing + DRC + bitstream complete. Physical board verification is a separate step. Review Reports/methodology.rpt and other warnings before final submission."
    puts "PROJECT 2 BUILD SUCCESS: Hardware/radar_top.bit and Hardware/radar_top.ltx"
}
if {[catch {p2_main} err options]} {
    p2_write [file join $p2_dir Results BUILD_FAILED.txt] "$err\n[dict get $options -errorinfo]"
    puts stderr "PROJECT 2 BUILD FAILED: $err"
    return -options $options $err
}
