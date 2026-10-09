source [file join [file dirname [info script]] hardware_helpers.tcl]
set marker [file join $p2::dir Results HARDWARE_PASS.txt]
if {[file exists $marker]} {file delete $marker}
p2::attach
radar_reset
set passed 0
foreach scenario {0 1 2 3} {
    foreach alpha {1 2 4 8} {
        foreach gap {0 1} {radar_run_case $scenario $alpha $gap;incr passed}
    }
}
radar_run_case 1 4 0
set f [open $marker w]
puts $f "PHYSICAL HARDWARE PASS: $passed scenario/alpha/gap combinations plus a repeated standard target frame."
puts $f "Time: [clock format [clock seconds]]"
puts $f "PROGRAM.FILE: [get_property PROGRAM.FILE $p2::dev]"
puts $f "PROBES.FILE: [get_property PROBES.FILE $p2::dev]"
puts $f "Part: [get_property PART $p2::dev]"
puts $f "All cases: 80 valid windows; exact counts, positions, full detection masks, thresholds, cycle counts and latched configuration verified."
close $f
puts "PROJECT 2 HARDWARE VERIFICATION PASS: $passed cases plus repeat. Results saved; standard 3-target case is displayed."
