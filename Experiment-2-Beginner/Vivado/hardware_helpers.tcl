namespace eval p2 {
    variable dir [file normalize [file join [file dirname [info script]] ..]]
    variable dev
    variable vio
}
proc p2::probe {direction port} {
    variable vio
    set matches {}
    foreach p [get_hw_probes -of_objects $vio] {
        if {[string equal -nocase [get_property TYPE $p] vio_$direction] &&
            [get_property PROBE_PORT $p] == $port} {lappend matches $p}
    }
    if {[llength $matches]!=1} {error "Expected one VIO $direction probe at port $port; got $matches"}
    return [lindex $matches 0]
}
proc p2::read {port} {
    set raw [string trim [get_property INPUT_VALUE [p2::probe input $port]]]
    regsub -nocase {^0x} $raw {} raw
    regsub -all {_} $raw {} raw
    if {![regexp {^[0-9a-fA-F]+$} $raw]} {error "Invalid VIO hexadecimal value: $raw"}
    # Tcl bignums preserve the full 128-bit detection mask.
    return [expr "0x$raw"]
}
proc p2::setout {port value} {
    set_property OUTPUT_VALUE [format %x $value] [p2::probe output $port]
}
proc p2::commit {} {variable vio;commit_hw_vio $vio}
proc p2::refresh {} {variable vio;refresh_hw_vio $vio}
proc p2::attach {} {
    variable dev;variable vio
    set devs [get_hw_devices -quiet -filter {PART =~ "xc7z020*"}]
    if {[llength $devs]!=1} {error "Expected one PYNQ-Z2 xc7z020 device; connect/select that board in Hardware Manager"}
    set dev [lindex $devs 0];current_hw_device $dev
    set candidates [get_hw_vios -quiet -of_objects $dev]
    set matches {}
    foreach v $candidates {
        if {[string match *u_vio* [get_property CELL_NAME $v]]} {lappend matches $v}
    }
    if {[llength $matches]!=1} {error "Radar VIO was not found; program this package's radar_top.bit with its matching radar_top.ltx"}
    set vio [lindex $matches 0]
    p2::refresh
    if {[p2::read 16]!=0x52414432} {error "Design identifier mismatch; this is not the Project 2 radar design"}
}
proc radar_reset {} {
    p2::setout 1 0;p2::setout 0 1;p2::commit;after 20
    p2::setout 0 0;p2::commit;after 20;p2::refresh
    if {[p2::read 0] || [p2::read 1] || [p2::read 10]!=0} {error "Radar reset did not clear state"}
    puts "Radar reset complete."
}
proc radar_run_case {scenario alpha {gap 0}} {
    if {![string is integer -strict $scenario] || $scenario<0 || $scenario>3 ||
        ![string is integer -strict $gap] || $gap<0 || $gap>1} {error "Usage: radar_run_case scenario(0..3) alpha(1/2/4/8) gap(0/1)"}
    switch -- $alpha {1 {set shift 0} 2 {set shift 1} 4 {set shift 2} 8 {set shift 3} default {error "alpha must be 1, 2, 4 or 8"}}
    p2::refresh
    if {[p2::read 0]} {error "Radar is busy"}
    set old_id [p2::read 10]
    p2::setout 0 0;p2::setout 1 0
    p2::setout 2 $scenario;p2::setout 3 $shift;p2::setout 4 $gap
    p2::commit;after 20
    p2::setout 1 1;p2::commit;after 20
    p2::setout 1 0;p2::commit
    set next_id [expr {($old_id+1)&65535}]
    set deadline [expr {[clock milliseconds]+5000}]
    while {1} {
        p2::refresh
        if {[p2::read 10]==$next_id && [p2::read 1] && ![p2::read 0]} {break}
        if {[clock milliseconds]>$deadline} {error "Frame did not finish (check reset, PL reference clock, and other board-programming sessions)"}
        after 20
    }
    set expected_mask 0;set expected_count 0
    if {$scenario==1} {
        set expected_mask [expr {(1<<30)|(1<<60)|(1<<85)}];set expected_count 3
    } elseif {($scenario==2 || $scenario==3) && $alpha<=2} {
        set expected_mask [expr {1<<30}];set expected_count 1
    }
    set last_base [expr {$scenario==3?20000:($scenario==1?150:100)}]
    set last_full [expr {$last_base*$alpha}]
    set cycles [expr {$gap?302:104}]
    set expects [dict create 0 0 1 1 2 $expected_count 3 80 \
        4 [expr {$expected_count>0?30:65535}] \
        5 [expr {$expected_count==3?60:65535}] \
        6 [expr {$expected_count==3?85:65535}] \
        7 [expr {min(65535,$last_full)}] 8 $last_full 9 $cycles \
        10 $next_id 11 0 12 $scenario 13 $shift 14 $gap 15 $expected_mask 16 0x52414432]
    dict for {port value} $expects {
        set got [p2::read $port]
        if {$got!=$value} {error "HARDWARE FAIL scenario=$scenario alpha=$alpha gap=$gap probe_in$port expected=$value got=$got"}
    }
    set positions [expr {$expected_count==3?"30,60,85":($expected_count==1?"30":"none")}]
    puts "HARDWARE CASE PASS: scenario=$scenario alpha=$alpha gap=$gap detections=$expected_count positions=$positions results=80 cycles=$cycles"
    set csv [file join $p2::dir Results hardware_results.csv]
    set exists [file exists $csv];set f [open $csv a]
    if {!$exists} {puts $f "frame,scenario,alpha,gap,detections,results,cycles,last_threshold_full,status"}
    puts $f "$next_id,$scenario,$alpha,$gap,$expected_count,80,$cycles,$last_full,PASS";close $f
    return $expected_count
}
