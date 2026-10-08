source [file join [file dirname [info script]] hardware_lib.tcl]
proc bnn_assert {condition message} {if {![uplevel 1 [list expr $condition]]} {error $message}}
proc bnn_live_verify {} {
    global p5_hw_root
    set f [open [file join $p5_hw_root Results LATEST_SUCCESS_PATH.txt] r];set out [string trim [read $f]];close $f
    if {[file pathtype $out] eq "relative"} {set out [file normalize [file join $p5_hw_root $out]]}
    set pass [file join $out HARDWARE_LIVE_PASS.txt];catch {file delete $pass}
    bnn_reset;bnn_load normal 0;bnn_commit 0;bnn_load cautious 1
    bnn_live 0000;bnn_arm
    set r [bnn_live 0222];bnn_assert {[dict get $r action]==1} "Normal CAUTION failed."
    bnn_commit 1;after 20;set r [bnn_snapshot]
    bnn_assert {[dict get $r proposal]==2&&[dict get $r action]==2&&[dict get $r model_id]==2} "Live cautious switch failed."
    bnn_commit 0;bnn_live 0000;bnn_arm
    foreach {raw sensor reason label} {2233 1 4 neural_STOP 0024 1 2 critical_guard 0005 1 1 illegal_level 0000 0 1 invalid_sensor} {
        set r [bnn_live $raw $sensor]
        bnn_assert {[dict get $r action]==3&&[dict get $r tripped]&&([dict get $r history]&(1<<$reason))} "$label failed."
        bnn_live 0000;bnn_arm
    }
    bnn_pause 1;set r [bnn_snapshot]
    bnn_assert {[dict get $r action]==3&&[dict get $r tripped]&&([dict get $r history]&8)} "Watchdog failed."
    bnn_pause 0;bnn_live 0000;bnn_arm
    bnn_disarm
    set f [open $pass w]
    puts $f "HARDWARE LIVE PASS: live A/B switch, neural STOP, critical guard, invalid level/sensor, 10 ms watchdog, safe clear."
    puts $f "Physical BTN0 emergency/BTN1 clear/BTN2 scenario/SW1 pause checks require operator evidence."
    puts $f "Build: $out"
    close $f
    puts "HARDWARE LIVE PASS. Now record the physical button checks using Documentation/HARDWARE_GUIDE.md."
}
bnn_live_verify
