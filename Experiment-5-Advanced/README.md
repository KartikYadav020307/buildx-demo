# Project 5 | Advanced

## Reconfigurable FPGA BNN for autonomous safety response

Team: **Beyond Boolean** — Shanshank Pulipati (25BEC0573), Kartik Yadav (25BEC0087).

PYNQ-Z2, xc7z020clg400-1, Vivado 2025.1.1. A 16-16-4 binary neural network supplies four proposals; an independent safety controller enforces emergency and timeout STOP. Two checked model banks allow live normal/cautious policy switching without rebuilding the bitstream.

- [Project report](Documentation/Project5_Report.pdf)
- [Simulation report](Simulation/simulation_report.pdf)
- [Evidence and requirement checklist](Documentation/SUBMISSION_CHECKLIST.md)
- [Final demo](https://drive.google.com/file/d/11JItdx7IdNwuDhve5nBIV5tBiZsHoPV7/view?usp=sharing)
- [Recorded implementation reports and bitstream](Results/run_20261008_121952_125/)

## Reproduce the build

Clone the complete repository; open this folder locally. On Windows run `RUN_PROJECT5.cmd`, optionally passing your full `vivado.bat` path. It creates `build/BNN_Safety.xpr`, generates clock/VIO IP, runs five XSim suites, synthesizes, routes and records a new Results directory. Vivado 2025.1.1 was used for the included build. The original generated .xpr/cache was not archived; `Vivado/create_project.tcl` regenerates it from the committed sources. Preserve both model files and all Data files.

The included `.bit.gz` (lossless gzip) and `.ltx` preserve the original pair from the recorded successful run. `Results/LATEST_SUCCESS_PATH.txt` uses a portable relative path; programming/test scripts accept relative or absolute pointers. The programming script automatically unpacks the original `.bit` before use. Follow `Documentation/HARDWARE_GUIDE.md` for USB-JTAG and Tcl commands. Hardware programming requires a physical board and Vivado Hardware Manager. Do not rerun a full build merely to view the recorded evidence.

Optional CPU/HDL reproduction: install Icarus Verilog, then run `python Python/run_open_source_tests.py`. Reference/training dependencies are in `Python/requirements_optional.txt`. The extra waveform test is described in Simulation/README.md.

## Measured results

Five actual XSim suites passed. Exhaustive core tests cover 65,536 binary inputs per profile per core. Parallel/folded latency is 5/21 cycles, or 100/420 ns at 50 MHz; initiation interval is 1/22 cycles. Whole routed design: 5,772 LUTs, 6,501 FFs, zero BRAM/DSP; setup slack +4.534 ns and hold slack +0.035 ns. DRC: zero errors, five warnings; see raw reports. Folded uses fewer FFs but more LUTs than parallel in this implementation.

The recorded physical core check shows 64/64 PASS; the supplied Tcl log ends HARDWARE LIVE PASS. Live model switching and emergency/clear were recorded. Earlier operator logs show watchdog latch, resume and eligible clear. The earlier recording ends with an unsuccessful watchdog clear and then disarm. A replacement final edit is linked; its content/access review is documented in Documentation/VIDEO_REVIEW.md. This is a synthetic-policy demonstration, not a validated vehicle controller.

## Package structure

Organizer-required Documentation, RTL, Testbench, Simulation, Images and Video_Link.txt are present. Models/Data/Python/Vivado support reproduction; Results contains original routed artifacts; Evidence preserves available hardware evidence. SHA256SUMS.txt inventories the package. Team identity and the combined report for all five projects remain repository-wide tasks.
