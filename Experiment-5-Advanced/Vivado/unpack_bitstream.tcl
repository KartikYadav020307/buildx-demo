# Lossless transport of the original uploaded bitstream; no synthesis change.
proc p5_unpack_bitstream {out} {
    set bit [file join $out bnn_board_top.bit]
    set packed ${bit}.gz
    if {![file exists $bit] && [file exists $packed]} {
        set f [open $packed rb];set bytes [read $f];close $f
        set decoded [zlib gunzip $bytes]
        if {[string length $decoded] != 4045691} {error "Unexpected unpacked bitstream size."}
        set f [open $bit wb];puts -nonewline $f $decoded;close $f
        puts "Unpacked original uploaded bnn_board_top.bit from gzip."
    }
}
