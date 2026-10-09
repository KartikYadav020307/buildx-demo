# Project 2 - use the verified package

Read `README.md` for scope, evidence, all required files and remaining inputs. The original successful build and physical board results are included. The final demo link is intentionally blank.

To program the existing original BIT/LTX, open Vivado Hardware Manager, use the board's normal working power/boot setup and USB/JTAG, and source `Vivado/program_board.tcl` from this folder. Source `Vivado/hardware_test.tcl` to run the complete verification. No rebuild or original `.xpr` is needed to program the included hardware files. Programming and tests clear/rewrite old physical result files, so work in a separate copy to preserve the archive.

To reproduce the entire build, use a folder path without spaces, run `RUN_PROJECT2.cmd`, wait for BUILD SUCCESS, then run `OPEN_PROJECT2.cmd`. The build creates a genuine native `.xpr` and generated VIO IP and records the project path in `Results/project_path.txt`. To open the recovered original laptop project instead, extract the whole `FPGA_Project/Project2_Radar_Vivado_Source.zip` and open `Project2_Radar_Final/Build/run_20261008_222502/project2_radar.xpr`. Preserve its folder layout; Vivado may need to regenerate IP/build products. A build clears existing result markers/hardware outputs before creating new ones.

`Documentation/SUBMISSION_READINESS.md` lists the final video as the only remaining Project 2 input. Original routed reports/checkpoint and native `.xpr`/IP source archive are now included; `Reports/README.md` documents the reviewed implementation warnings. The technical report, simulation report, exact RTL/testbenches, real waveforms and actual board/PASS images are already present.
