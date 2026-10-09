# Project 2 - use the verified package

Read `README.md` for scope, evidence, all required files and remaining inputs. The original successful build and physical board results are included. The final demo link is intentionally blank.

To program the existing original BIT/LTX, open Vivado Hardware Manager, use the board's normal working power/boot setup and USB/JTAG, and source `Vivado/program_board.tcl` from this folder. Source `Vivado/hardware_test.tcl` to run the complete verification. No rebuild or original `.xpr` is needed to program the included hardware files. Programming and tests clear/rewrite old physical result files, so work in a separate copy to preserve the archive.

To reproduce the entire build, use a folder path without spaces, run `RUN_PROJECT2.cmd`, wait for BUILD SUCCESS, then run `OPEN_PROJECT2.cmd`. The build creates a genuine native `.xpr` and generated VIO IP and records the project path in `Results/project_path.txt`. The original generated laptop `.xpr` was not supplied; the open-project launcher becomes usable after a fresh build. A build clears existing result markers/hardware outputs before creating new ones.

`Documentation/SUBMISSION_READINESS.md` lists the final video gap and requests the original routed reports and `.xpr`/IP source archive. The technical report, simulation report, exact RTL/testbenches, real waveforms and actual board/PASS images are already present.
