set p5_root [file normalize [file join [file dirname [info script]] ..]]
if {[llength $argv]} {set p5_results [file normalize [lindex $argv 0]]} else {
    set p5_results [file join $p5_root Results run_[clock format [clock seconds] -format %Y%m%d_%H%M%S]]
}
file mkdir $p5_results
set rc [catch {
    set ver [version -short]
    if {![string match 2025.1* $ver]} {error "Expected Vivado 2025.1 or 2025.1.1; found $ver"}
    source [file join $p5_root Vivado create_project.tcl]
    set datadir [string map {\\ /} $p5_root]
    foreach {top marker uses_data} {tb_cores CORE 1 tb_diagnostics DIAGNOSTIC 0 tb_config CONFIG 0 tb_safety SAFETY 0 tb_system SYSTEM 1} {
        set pass [file join $p5_results ${marker}_TEST_PASS.txt]
        if {[file exists $pass]} {file delete $pass}
        set passpath [string map {\\ /} $pass]
        set generics [list "PASS_FILE=\"$passpath\""]
        if {$uses_data} {lappend generics "DATA_DIR=\"$datadir\""}
        set_property top $top [get_filesets sim_1]
        set_property generic $generics [get_filesets sim_1]
        set_property xsim.simulate.runtime 100ms [get_filesets sim_1]
        update_compile_order -fileset sim_1
        puts "P5: running $top (all checks required)."
        launch_simulation -simset sim_1 -mode behavioral
        close_sim
        set simdir [file join $p5_build BNN_Safety.sim sim_1 behav xsim]
        foreach logname {xsim.log xvlog.log elaborate.log} {
            set p [file join $simdir $logname]
            if {[file exists $p]} {file copy -force $p [file join $p5_results ${top}_${logname}]}
        }
        if {![file exists $pass]} {error "$top did not complete; missing pass marker. Inspect simulation logs."}
        set fd [open $pass r];set text [read $fd];close $fd
        if {![string match "PASS *" [string trim $text]]} {error "$top has an invalid pass marker."}
    }
    puts "P5: all simulations passed; synthesis and implementation starting."
    launch_runs synth_1 -jobs 2
    wait_on_runs synth_1
    if {![string match "*synth_design Complete*" [get_property STATUS [get_runs synth_1]]]} {error "Synthesis failed."}
    open_run synth_1
    set latches [get_cells -hier -quiet -filter {REF_NAME =~ LD*}]
    if {[llength $latches]} {error "Unexpected inferred latches: $latches"}
    set dsps [get_cells -hier -quiet -filter {REF_NAME =~ DSP* && NAME =~ *system_i/*}]
    if {[llength $dsps]} {error "BNN/safety datapath unexpectedly uses DSP blocks: $dsps"}
    report_utilization -hierarchical -file [file join $p5_results utilization_synthesis.rpt]
    close_design
    launch_runs impl_1 -to_step route_design -jobs 2
    wait_on_runs impl_1
    if {![string match "*route_design Complete*" [get_property STATUS [get_runs impl_1]]]} {error "Routing failed."}
    open_run impl_1
    source [file join $p5_root Vivado collect_reports.tcl]
    # Only publish programming artifacts after the routed checks pass.
    write_bitstream -force [file join $p5_results bnn_board_top.bit]
    write_debug_probes -force [file join $p5_results bnn_board_top.ltx]
    set fd [open [file join $p5_results BUILD_SUCCESS.txt] w]
    puts $fd "Project 5 build complete; hardware testing remains pending."
    puts $fd "Source root: $p5_root"
    puts $fd "Project: [file join $p5_build BNN_Safety.xpr]"
    puts $fd "Vivado: $ver; target xc7z020clg400-1; accelerator clock 50 MHz."
    puts $fd "Simulation: CORE, DIAGNOSTIC, CONFIG, SAFETY and SYSTEM pass."
    puts $fd "Routed setup slack: $wns ns; hold slack: $whs ns; pulse-width failing endpoints: 0."
    puts $fd "DRC errors: 0; datapath DSPs: 0. Review CDC/methodology warnings in these reports."
    puts $fd "Programming pair: bnn_board_top.bit / bnn_board_top.ltx"
    close $fd
    set fd [open [file join $p5_root Results LATEST_SUCCESS_PATH.txt] w];puts $fd $p5_results;close $fd
    puts "P5 BUILD SUCCESS: $p5_results"
} message opts]
if {$rc} {
    catch {close_sim}
    catch {file delete [file join $p5_results BUILD_SUCCESS.txt]}
    set fd [open [file join $p5_results BUILD_FAILED.txt] w]
    puts $fd $message
    if {[dict exists $opts -errorinfo]} {puts $fd [dict get $opts -errorinfo]}
    close $fd;puts stderr "P5 BUILD FAILED: $message";exit 1
}
close_project
exit 0
