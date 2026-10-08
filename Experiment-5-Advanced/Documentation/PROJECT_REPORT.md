# Project 5 - Reconfigurable FPGA BNN Safety Response

PYNQ-Z2 | Advanced experiment | Evidence reviewed 8 October 2026

## 1. Objective

Build and verify a parameter-reconfigurable, DSP-free 16-16-4 binarized neural network on PYNQ-Z2, with an independent fault controller. Demonstrate normal/cautious policy changes, emergency STOP, explicit safe clear and a stale-input watchdog using real FPGA telemetry and LEDs.

Inputs are synthetic four features, each with levels 0..4, represented as four nibbles, converted to 16 thermometer bits. Outputs are CONTINUE (0), CAUTION (1), BRAKE (2), STOP (3). No camera, external sensor, motor or real vehicle is connected. Low neural latency is demonstrated; complete sensor-to-actuator safety is not established.

## 2. Block diagram

bnn_board_top maps PYNQ pins, generated clock and VIO to bnn_system. The system produces tagged frames, routes commands to checked model banks, launches inference, and passes the parallel proposal to bnn_safety. The folded engine is used in controlled comparison tests; live operation uses the parallel engine.

Each model bank contains 42 canonical 16-bit words. CRC-16/CCITT-FALSE scans address/high-byte/low-byte for 1,008 cycles. The bank is sealed only after a correct CRC; active-bank writes are protected. Commit drains in-flight inference and changes the bank/model identity atomically. Old sealed parameters support rollback.

## 3. RTL design

Seven SystemVerilog files: bnn_math_pkg supplies arithmetic/encoding rules; bnn_parallel pipelines the 16-16-4 network; bnn_folded reuses arithmetic across hidden/output stages; bnn_config manages parameter banks, CRC and commit; bnn_safety arbitrates faults/arm/clear; bnn_system handles commands, sampling and tagged results; bnn_board_top connects the clock/VIO IP, switches, buttons and LEDs. pynq_z2.xdc constrains the board pins and clocks.

XNOR/popcount implements binary dot products. Output score = 2*popcount - 16 + signed bias, with 9-bit signed scores (-144..143). Equal scores choose the higher class index; margin is best minus runner-up. Raw neural proposal and enforced safety action are distinct.

BTN0 requests emergency STOP, BTN1 eligible clear, BTN2 advances a preset, BTN3 resets. SW0 selects run behavior; SW1 pauses frames for watchdog testing. Sampling period is 50,000 cycles (1 ms); watchdog threshold is 500,000 cycles (10 ms). LD0 is heartbeat, LD1 armed, LD2/LD3 encode action. STOP is sticky. Safe input alone, bank switching or fresh frames do not clear it. Eligible clear requires a current, fresh, matching-model CONTINUE result and no competing fault.

## 4. Simulation

Original Vivado batch output and five suite PASS files are retained. Core tests verify 65,536 binary vectors per profile per core (131,072 results per core), including full hidden bits, all signed scores, class, margin and model tags. Parallel latency is 5 cycles, folded 21; initiation intervals are 1 and 22. Arithmetic checks include all 65,536 popcounts and 4,352 score extremes.

Diagnostics use 1,024 randomized model images / 4,096 output checks. Configuration covers 1,216 checks and occupancies 0..21. Safety uses 26 directed checks; integrated system tests cover 6,615 checks and 1,250 raw comparisons. The additional real Icarus VCD trace verifies 12 directed cases against the same frozen goldens and illustrates the model-dependent action for 0222.

Normal/cautious synthetic classifiers achieve 125/125 held-out cases each; 625/625 checks cover the full valid domain, including training cases. These measurements are synthetic policy agreement, not real-world safety accuracy. Training uses discrete binary/integer search with a fixed monotone hidden projection.

## 5. Hardware implementation

Actual uploaded Vivado 2025.1.1 run: xc7z020clg400-1, 125 MHz physical reference and 50 MHz design clock. Routed setup slack +4.534 ns; hold +0.035 ns; pulse-width violations 0; all four bus-skew constraints pass. DRC has 0 errors and 5 warnings (debug LUT/unloaded-net issues and absent PS7/startup-clock caution). Raw DRC, methodology and CDC reports are included rather than treating warnings as zero.

Whole routed board/debug design uses 5,772 LUTs and 6,501 FFs, with 0 BRAM and 0 DSP. Parallel core: 204 total LUTs, 288 FFs. Folded: 314 LUTs, 120 FFs. Thus folding saves FFs but increases LUTs here. Neural result latencies are 100 and 420 ns at 50 MHz; their 4.2 ratio is not a complete system-speedup measurement.

Physical core verification shows HARDWARE CORE PASS: 64/64 (32 cases/profile). The supplied complete live Tcl log ends HARDWARE LIVE PASS. Operator telemetry and video demonstrate model 1 CAUTION to model 2 BRAKE for raw 0222, emergency latching, fresh input retaining STOP, explicit emergency clear and watchdog history 8.

The final accepted video does not successfully finish watchdog recovery: final state remains action 3/tripped 1/history 8 after rollback, then disarms. Earlier operator snapshots did show eligible watchdog clear to action 0/tripped 0. Missing raw core CSV/PASS files are identified in Evidence/README.md. Original generated .xpr was not supplied; Tcl/IP scripts regenerate it.

## 6. Applications

Demonstrates fixed-topology model updates for small embedded policy engines and a separate interlock for emergency/stale-input handling. Two parameter banks allow runtime policy selection while retaining a rollback model. Deterministic core cycle counts and integer arithmetic support repeatable verification.

A deployment would need representative measured sensor data, interface and actuator validation, independent timing/fault analysis, and an external response to loss of the FPGA clock. The present watchdog depends on a running clock. No production or vehicle safety claim is made.

## 7. Conclusion

The supplied design has passed exhaustive arithmetic/core simulation, directed system/fault tests, routed timing checks and available physical FPGA verification. Main learning outcomes are pipeline/folded tradeoffs, signed integer correctness, guarded parameter updates, tagged-result freshness and latched fault recovery.

Future work: complete the full narrated presentation and a clean final watchdog-recovery take if stronger video evidence is desired; export the original core CSV/PASS files; expand real sensor validation and compare power/area on additional architectures. The required Project 5 file categories are present. Whole-entry completion still needs team details, Experiments 1-4, the combined report and the prescribed repository naming.

## Evidence references

Results/run_20261008_121952_125/ (original implementation and XSim outputs); Simulation/ (local traces and transcripts); Evidence/ (physical log and screenshot); Documentation/DEMO_EVIDENCE.md (recording interpretation); Documentation/CONTRACT.md and SOURCES.md (technical contract and background); Video_Link.txt (final supplied demo).

The original bitstream is stored losslessly as .bit.gz and automatically unpacked by the programming script; no FPGA configuration bytes were changed.
