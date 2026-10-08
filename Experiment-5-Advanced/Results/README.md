# Original routed build evidence

run_20261008_121952_125 contains the actual uploaded Vivado 2025.1.1 run, including five XSim PASS markers, complete logs, routed timing/resource/DRC reports and matching bitstream/debug probes. The original BUILD_SUCCESS.txt predates the later physical tests, so its hardware-pending note describes that earlier stage; see Evidence/ and the report for later observations.

The original bitstream is stored losslessly as bnn_board_top.bit.gz. Vivado/program_board.tcl automatically extracts bnn_board_top.bit using Tcl zlib before programming. Vivado/unpack_bitstream.tcl can also be sourced directly with p5_unpack_bitstream <run directory>. The .ltx is uncompressed. No bitstream contents were modified.

Unpacked original bitstream: 4,045,691 bytes; SHA-256: 57ef954277a267cfdd31c883f0cf4a02eff7f1fd5d6542dd7c597ed81cf8a318

RUN_PROJECT5.cmd creates a separate new run and regenerates project/IP and bitstream files.
