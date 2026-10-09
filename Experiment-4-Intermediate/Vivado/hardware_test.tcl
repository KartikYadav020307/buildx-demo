# Source only AFTER programming Results/nn_board_top.bit with its matching .ltx.
# Uses Vivado Hardware Manager, not the PYNQ/Jupyter runtime.
# Automatically resets the accelerator and validates the 45 held-out Iris cases.
set nn_hw_root [file normalize [file join [file dirname [info script]] ..]]
set nn_hw_vios [get_hw_vios -of_objects [current_hw_device]]
if {[llength $nn_hw_vios] != 1} {
    error "Expected one VIO. Check the programmed bitstream and matching .ltx. Found: $nn_hw_vios"
}
set nn_hw_vio [lindex $nn_hw_vios 0]
proc nn_hw_resolve {base} {
    global nn_hw_vio
    set matches {}
    set pattern [format {(^|/)%s(\[.*\])?$} $base]
    foreach obj [get_hw_probes -of_objects $nn_hw_vio] {
        if {[regexp $pattern [get_property NAME $obj]]} {lappend matches $obj}
    }
    if {[llength $matches] != 1} {
        error "Cannot uniquely find probe '$base'. Inspect: get_hw_probes -of_objects \[get_hw_vios\]. Found $matches"
    }
    return [lindex $matches 0]
}
foreach nn_hw_name {control_reset cmd_toggle features busy done mismatch parallel_class serial_class parallel_cycles serial_cycles score0 score1 score2 completed_count} {
    set nn_hw_probe($nn_hw_name) [nn_hw_resolve $nn_hw_name]
}
proc nn_hw_write {name hexvalue} {
    global nn_hw_probe
    set_property OUTPUT_VALUE $hexvalue $nn_hw_probe($name)
    commit_hw_vio $nn_hw_probe($name)
}
proc nn_hw_read {name} {
    global nn_hw_probe
    set probe $nn_hw_probe($name)
    set raw [string map {_ ""} [get_property INPUT_VALUE $probe]]
    set radix [get_property INPUT_VALUE_RADIX $probe]
    # INPUT_VALUE follows the VIO dashboard display radix. Decimal display
    # must not be parsed as hexadecimal; signed scores need two's complement.
    switch -nocase -- $radix {
        HEX - HEXADECIMAL {scan $raw %x value}
        UNSIGNED - SIGNED {scan $raw %d value}
        BINARY {set value [expr "0b$raw"]}
        OCTAL {scan $raw %o value}
        default {error "Unsupported radix for $name: $radix"}
    }
    return [expr {$value & 0xffffffff}]
}
proc nn_hw_signed32 {v} {if {$v >= 2147483648} {return [expr {$v-4294967296}]} ; return $v}
proc nn_hw_reset {} {
    global nn_hw_toggle nn_hw_expected nn_hw_vio
    nn_hw_write control_reset 1
    nn_hw_write cmd_toggle 0
    nn_hw_write features 00000000
    after 20
    nn_hw_write control_reset 0
    after 20
    refresh_hw_vio $nn_hw_vio
    if {[nn_hw_read busy] != 0 || [nn_hw_read completed_count] != 0} {error "Reset did not take effect. Check the design clock."}
    set nn_hw_toggle 0; set nn_hw_expected 0
}
proc nn_run_case {packed_hex} {
    global nn_hw_vio nn_hw_toggle nn_hw_expected
    if {![regexp {^[0-9a-fA-F]{8}$} $packed_hex]} {error "Use exactly eight hexadecimal digits, e.g. c5d550dc."}
    refresh_hw_vio $nn_hw_vio
    if {[nn_hw_read busy]} {error "Accelerator busy. Wait for completed_count."}
    # Commit input data first. Toggling in a later JTAG transaction guarantees stability.
    nn_hw_write features $packed_hex
    set nn_hw_toggle [expr {1-$nn_hw_toggle}]
    nn_hw_write cmd_toggle $nn_hw_toggle
    incr nn_hw_expected
    set deadline [expr {[clock milliseconds]+3000}]
    while {1} {
        refresh_hw_vio $nn_hw_vio
        if {[nn_hw_read completed_count] == $nn_hw_expected} {break}
        if {[clock milliseconds] > $deadline} {error "No result within 3 s. Check clock, reset, and correct programming files."}
        after 5
    }
    set result [dict create]
    foreach name {done busy mismatch parallel_class serial_class parallel_cycles serial_cycles completed_count} {
        dict set result $name [nn_hw_read $name]
    }
    foreach name {score0 score1 score2} {dict set result $name [nn_hw_signed32 [nn_hw_read $name]]}
    if {[dict get $result busy] || ![dict get $result done] || [dict get $result mismatch]} {error "Hardware consistency failure: $result"}
    if {[dict get $result parallel_cycles] != 4 || [dict get $result serial_cycles] != 36} {error "Unexpected core latency: $result"}
    return $result
}
proc nn_run_test {{which test}} {
    global nn_hw_root
    if {$which ni {test all}} {error "Choose 'test' (45 held-out cases) or 'all' (150 cases)."}
    nn_hw_reset
    set f [open [file join $nn_hw_root Data iris_cases.csv] r]
    gets $f header
    set output_dir [file join $nn_hw_root Results]; file mkdir $output_dir
    set log [open [file join $output_dir hardware_${which}_results.csv] w]
    puts $log "index,split,true_class,predicted_class,score0,score1,score2,parallel_cycles,serial_cycles,reference_match"
    set total 0; set correct 0
    try {
        while {[gets $f line] >= 0} {
            if {[string trim $line] eq ""} {continue}
            set row [split [string trim $line] ,]
            if {$which eq "test" && [lindex $row 1] ne "test"} {continue}
            set r [nn_run_case [lindex $row 8]]
            set got [list [dict get $r parallel_class] [dict get $r score0] [dict get $r score1] [dict get $r score2]]
            set expected [list [lindex $row 7] [lindex $row 13] [lindex $row 14] [lindex $row 15]]
            if {$got ne $expected} {error "Case [lindex $row 0] differs from Python: got=$got expected=$expected"}
            incr total
            if {[dict get $r parallel_class] == [lindex $row 6]} {incr correct}
            puts $log "[lindex $row 0],[lindex $row 1],[lindex $row 6],[dict get $r parallel_class],[dict get $r score0],[dict get $r score1],[dict get $r score2],4,36,1"
        }
    } finally {close $f; close $log}
    puts "HARDWARE PASS: $total/$total cases match every Python integer score."
    puts [format "Model classification accuracy: %d/%d = %.2f%%" $correct $total [expr {100.0*$correct/$total}]]
    puts "Core cycles: parallel=4, sequential=36; latency reduction=9x at the same clock."
    puts "Saved $output_dir/hardware_${which}_results.csv"
}
nn_run_test test
