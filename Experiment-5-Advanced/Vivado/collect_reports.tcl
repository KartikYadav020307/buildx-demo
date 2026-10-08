# Routed design must be open. Mandatory timing and DRC gates.
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -file [file join $p5_results timing_summary.rpt]
report_utilization -hierarchical -file [file join $p5_results utilization_hierarchical.rpt]
report_clocks -file [file join $p5_results clocks.rpt]
report_drc -file [file join $p5_results drc.rpt]
report_methodology -file [file join $p5_results methodology.rpt]
report_cdc -details -file [file join $p5_results cdc.rpt]
report_bus_skew -warn_on_violation -file [file join $p5_results bus_skew.rpt]
report_pulse_width -file [file join $p5_results pulse_width.rpt]
report_route_status -file [file join $p5_results route_status.rpt]
set setup [get_timing_paths -quiet -max_paths 1 -delay_type max]
set hold [get_timing_paths -quiet -max_paths 1 -delay_type min]
if {![llength $setup]||![llength $hold]} {error "No timing paths; inspect the clock/reset setup."}
set wns [get_property SLACK $setup];set whs [get_property SLACK $hold]
if {$wns<0||$whs<0} {error "Routed timing failed: setup=$wns hold=$whs"}
set errors [get_drc_violations -quiet -filter {SEVERITY == Error}]
if {[llength $errors]} {error "DRC errors: $errors"}
# Parse the standard Design Timing Summary row, including pulse-width endpoints.
set fd [open [file join $p5_results timing_summary.rpt] r];set summary [read $fd];close $fd
set lines [split $summary \n];set found 0
for {set i 0} {$i<[llength $lines]} {incr i} {
    if {[regexp {WNS\(ns\).*TNS\(ns\).*WHS\(ns\).*WPWS\(ns\)} [lindex $lines $i]]} {
        for {set j [expr {$i+1}]} {$j<[llength $lines]&&$j<$i+8} {incr j} {
            set values [regexp -all -inline {[-+]?[0-9]+(?:\.[0-9]+)?} [lindex $lines $j]]
            if {[llength $values]==12} {
                set found 1
                foreach n {2 6 10} {if {[lindex $values $n]!=0} {error "Timing failing endpoints present: [lindex $lines $j]"}}
                break
            }
        }
        break
    }
}
if {!$found} {error "Cannot verify setup/hold/pulse-width summary row. Reports are saved; inspect timing_summary.rpt."}
set fd [open [file join $p5_results bus_skew.rpt] r];set skew [read $fd];close $fd
if {[regexp -nocase {Slack[^\n]*VIOLATED} $skew]} {error "Bus-skew constraint failed; inspect bus_skew.rpt."}
# Unclocked internal sequential endpoints are always blocking.
set ct [check_timing -override_defaults {no_clock unconstrained_internal_endpoints} -return_string]
set fd [open [file join $p5_results check_timing.rpt] w];puts $fd $ct;close $fd
if {[regexp -nocase {There (?:are|is) ([1-9][0-9]*) (?:register|sequential|internal)} $ct]} {error "Unconstrained internal timing endpoints: inspect check_timing.rpt"}
set clocks [get_clocks -quiet -filter {PERIOD > 19.99 && PERIOD < 20.01}]
if {![llength $clocks]} {error "No constrained 50 MHz clock."}
if {![llength [get_clocks -quiet -filter {PERIOD > 7.99 && PERIOD < 8.01}]]} {error "No constrained 125 MHz reference clock."}
set dsp_cells [get_cells -hier -quiet -filter {REF_NAME =~ DSP* && NAME =~ *system_i/*}]
if {[llength $dsp_cells]} {error "Unexpected DSP use in the BNN/system."}
puts "P5 routed gates pass. CDC, methodology and bus-skew reports are saved for review."
