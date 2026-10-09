# Unattended LOCAL Vivado build. No hardware is programmed by this script.
set nn_root [file normalize [file join [file dirname [info script]] ..]]
set nn_results [file join $nn_root Results]
file mkdir $nn_results
set nn_pass [file join $nn_results simulation_pass.flag]
set nn_success [file join $nn_results BUILD_SUCCESS.txt]
set nn_failure [file join $nn_results BUILD_FAILED.txt]
# A previous run must never authorize this run's build.
foreach nn_old [list $nn_pass $nn_success $nn_failure] {
    if {[file exists $nn_old]} {file delete $nn_old}
}
set nn_rc [catch {
    set nn_version [version -short]
    if {![string match "2025.1*" $nn_version]} {
        error "This pack targets Vivado 2025.1/2025.1.1; found $nn_version."
    }
    set nn_xpr [file join $nn_root build NN_Inference.xpr]
    if {[file exists $nn_xpr]} {
        open_project $nn_xpr
    } else {
        source [file join $nn_root Vivado create_project.tcl]
    }
    set nn_mem [string map {\\ /} [file join $nn_root Data golden_vectors.mem]]
    set nn_marker [string map {\\ /} $nn_pass]
    set_property generic [list "GOLDEN_FILE=\"$nn_mem\"" "PASS_FILE=\"$nn_marker\""] [get_filesets sim_1]
    set_property xsim.simulate.runtime 4ms [get_filesets sim_1]
    puts "PROJECT4: Running all HDL checks before synthesis."
    launch_simulation -simset sim_1 -mode behavioral
    catch {close_sim}
    if {![file exists $nn_pass]} {
        error "Simulation did not finish all checks. Inspect the XSim logs and vivado_batch.log."
    }
    set nn_fd [open $nn_pass r]
    set nn_pass_text [string trim [read $nn_fd]]
    close $nn_fd
    if {$nn_pass_text ne "ALL TESTS PASSED"} {error "Invalid simulation pass marker."}
    # Rebuild generated implementation outputs on repeated runs; sources are retained.
    if {[get_property STATUS [get_runs synth_1]] ne "Not started"} {
        reset_run synth_1
    }
    puts "PROJECT4: HDL checks passed. Building with two worker jobs."
    launch_runs impl_1 -to_step write_bitstream -jobs 2
    wait_on_runs impl_1
    source [file join $nn_root Vivado collect_reports.tcl]
    foreach nn_artifact {nn_board_top.bit nn_board_top.ltx timing_summary.rpt utilization_hierarchical.rpt clocks.rpt drc.rpt} {
        if {![file exists [file join $nn_results $nn_artifact]]} {
            error "Required output missing: $nn_artifact"
        }
    }
    set nn_fd [open $nn_success w]
    puts $nn_fd "Project 4 LOCAL Vivado build completed."
    puts $nn_fd "Vivado: $nn_version"
    puts $nn_fd "Simulation: ALL TESTS PASSED"
    puts $nn_fd "Worst setup slack: $wns ns; worst hold slack: $whs ns"
    puts $nn_fd "Bitstream: [file join $nn_results nn_board_top.bit]"
    puts $nn_fd "Debug probes: [file join $nn_results nn_board_top.ltx]"
    puts $nn_fd "Next: inspect timing/DRC reports, then program and test the PYNQ-Z2."
    puts $nn_fd "Physical board validation has not been performed by this build script."
    close $nn_fd
    puts "PROJECT4: BUILD SUCCESS. Outputs: $nn_results"
} nn_message nn_options]
if {$nn_rc} {
    catch {close_sim}
    if {[file exists $nn_success]} {file delete $nn_success}
    set nn_fd [open $nn_failure w]
    puts $nn_fd $nn_message
    if {[dict exists $nn_options -errorinfo]} {puts $nn_fd [dict get $nn_options -errorinfo]}
    close $nn_fd
    puts stderr "PROJECT4: BUILD FAILED: $nn_message"
    exit 1
}
close_project
exit 0
