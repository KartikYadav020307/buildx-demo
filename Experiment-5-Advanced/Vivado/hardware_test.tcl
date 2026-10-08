source [file join [file dirname [info script]] hardware_lib.tcl]
proc bnn_verify {{limit 32}} {
    global p5_hw_root
    if {$limit<1||$limit>625} {error "Choose 1..625 cases per profile."}
    set f [open [file join $p5_hw_root Results LATEST_SUCCESS_PATH.txt] r];set out [string trim [read $f]];close $f
    if {[file pathtype $out] eq "relative"} {set out [file normalize [file join $p5_hw_root $out]]}
    set pass [file join $out HARDWARE_CORE_PASS.txt]
    catch {file delete $pass}
    bnn_reset
    set log [open [file join $out hardware_test_results.csv] w]
    puts $log "profile,raw_hex,class,margin,score0,score1,score2,score3,hidden,fast_cycles,folded_cycles,model_id,reference_match"
    set total 0
    try {
        foreach {profile bank model} {normal 0 1 cautious 1 2} {
            bnn_load $profile $bank;bnn_commit $bank
            set f [open [file join $p5_hw_root Data ${profile}_hardware_cases.csv] r];gets $f header
            set count 0
            try {
                while {$count<$limit&&[gets $f line]>=0} {
                    set row [split [string trim $line] ,]
                    set r [bnn_run_case [lindex $row 0]]
                    scan [lindex $row 1] %x eh
                    set got [list [dict get $r hidden] [dict get $r score0] [dict get $r score1] [dict get $r score2] [dict get $r score3] [dict get $r proposal] [dict get $r margin]]
                    set expected [concat [list $eh] [lrange $row 2 7]]
                    if {$got ne $expected||[dict get $r model_id]!=$model||[dict get $r result_model]!=$model} {error "Hardware golden mismatch $profile [lindex $row 0]: got=$got expected=$expected"}
                    puts $log "$profile,[lindex $row 0],[dict get $r proposal],[dict get $r margin],[dict get $r score0],[dict get $r score1],[dict get $r score2],[dict get $r score3],[dict get $r hidden],[dict get $r fast],[dict get $r folded],$model,1"
                    incr count;incr total
                }
            } finally {close $f}
            if {$count!=$limit} {error "Too few hardware cases."}
        }
        # Rollback and protected active bank; corrupt seal rejection and corrected seal.
        bnn_commit 0;bnn_cmd 2 0 0 0 1;bnn_load cautious 1 1
        bnn_run_case 0111;bnn_commit 1;bnn_run_case 0111;bnn_commit 0
        set fd [open $pass w]
        puts $fd "HARDWARE CORE PASS: $total/$total independent golden matches; hidden/scores/class/margin; 5/21 measured cycles."
        puts $fd "CRC rejection, protected active write, model switch and rollback exercised."
        puts $fd "Programming pair from $out. Physical/live safety demonstration still requires the guide's checks."
        close $fd
        puts "HARDWARE CORE PASS: $total/$total; output $out"
    } finally {close $log}
}
bnn_verify 32
