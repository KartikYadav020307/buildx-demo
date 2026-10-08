set root [lindex $argv 0]
set outs [dict create vio_reset 0 request 0 command 0 bank 0 address 0 payload 0]
set ins [dict create ack 0 status 128 readback 0 state_bits 0 model_id 0 result_model 0 action 3 proposal 3 margin 0 scores 0 reasons 0 history 0 sample_id 0 hidden 0 fast 0 folded 0 seal 0 commit 0 comparisons 0 mismatches 0 age 0 accepts 0 decisions 0 raw 0 heartbeat 0]
set active -1;array set mem {};array set sealed {};array set loading {}
proc current_hw_device {} {return MOCK_DEVICE}
proc get_hw_vios {args} {return MOCK_VIO}
proc get_hw_probes {args} {global outs ins;return [concat [dict keys $outs] [dict keys $ins]]}
proc get_property {property obj} {
 global outs ins
 if {$property eq "NAME"} {return $obj}
 if {$property eq "OUTPUT_VALUE"} {return [format %x [dict get $outs $obj]]}
 if {$property eq "INPUT_VALUE"} {return [format %x [dict get $ins $obj]]}
 error "Unexpected property $property $obj"
}
proc set_property {property value obj} {global outs;scan $value %x n;dict set outs $obj $n}
proc refresh_hw_vio {args} {global ins;dict incr ins heartbeat}
proc after {args} {}
proc hw_math {raw} {
 global active mem ins
 set x 0
 for {set f 0} {$f<4} {incr f} {set level [expr {($raw>>(4*$f))&15}];for {set k 0} {$k<4} {incr k} {if {$level>$k} {set x [expr {$x|(1<<($f*4+$k))}]}}}
 set h 0
 for {set j 0} {$j<16} {incr j} {
  set w $mem($active,$j);set p 0
  for {set k 0} {$k<16} {incr k} {incr p [expr {(($x>>$k)&1)==(($w>>$k)&1)}]}
  if {$p>=$mem($active,[expr {20+$j}])} {set h [expr {$h|(1<<$j)}]}
 }
 set s {}
 for {set j 0} {$j<4} {incr j} {
  set w $mem($active,[expr {16+$j}]);set dot 0
  for {set k 0} {$k<16} {incr k} {incr dot [expr {(((($h>>$k)&1)*2)-1)*(((($w>>$k)&1)*2)-1)}]}
  set b $mem($active,[expr {36+$j}]);if {$b>=32768} {incr b -65536};lappend s [expr {$dot+$b}]
 }
 set cls 0;set best [lindex $s 0];set second -256;set packed 0
 for {set j 0} {$j<4} {incr j} {
  set val [lindex $s $j];set packed [expr {$packed|(($val&511)<<(9*$j))}]
  if {$j>0} {if {$val>=$best} {set second $best;set best $val;set cls $j} elseif {$val>$second} {set second $val}}
 }
 dict set ins proposal $cls;dict set ins hidden $h;dict set ins scores $packed;dict set ins margin [expr {$best-$second}]
 dict set ins fast 5;dict set ins folded 21;dict incr ins comparisons;dict incr ins sample_id
 dict set ins result_model [dict get $ins model_id]
}
proc commit_hw_vio {obj} {
 global outs ins active mem sealed loading
 if {$obj eq "vio_reset"&&[dict get $outs vio_reset]} {
  set active -1;array unset mem;array unset sealed;array unset loading
  foreach {k v} {status 128 state_bits 0 model_id 0 result_model 0 comparisons 0 action 3} {dict set ins $k $v}
  dict set ins ack [dict get $outs request];return
 }
 if {$obj ne "request"} {return}
 if {[dict get $outs vio_reset]} {dict set ins ack [dict get $outs request];return}
 if {[dict get $outs request]==[dict get $ins ack]} {return}
 set c [dict get $outs command];set b [dict get $outs bank];set a [dict get $outs address];set d [dict get $outs payload];set status 0
 dict set ins readback 0
 switch $c {
  1 {if {$b==$active} {set status 1} else {set loading($b) 1;set sealed($b) 0}}
  2 {if {$b==$active} {set status 1} else {set mem($b,$a) [expr {$d&65535}]}}
  3 {dict set ins readback $mem($b,$a)}
  4 {set words {};for {set i 0} {$i<42} {incr i} {lappend words $mem($b,$i)}
     set crc [bnn_crc $words];dict set ins readback $crc;dict set ins seal 1008
     if {$crc!=($d&65535)} {set status 4;set sealed($b) 0} else {set sealed($b) 1}}
  5 {if {![info exists sealed($b)]||!$sealed($b)||$b==$active} {set status 5} else {set active $b;dict set ins model_id $mem($b,40);dict set ins state_bits [expr {1|($b<<1)}];dict set ins commit 1}}
  6 {set sealed($b) 0}
  7 {hw_math [expr {$d&65535}]}
  default {error "Unexpected mocked command $c"}
 }
 dict set ins status $status;dict set ins ack [dict get $outs request]
}
source [file join $root Vivado hardware_test.tcl]
puts "MOCK HARDWARE SCRIPT API CHECKS COMPLETED; not a physical hardware test."
