# Current verification scope

The original preparation scope is preserved in `Evidence/Historical/verification_scope_preboard.md`.
This document records the current evidence rather than the earlier pre-board state.

- Original Vivado 2025.1.1 XSim, synthesis, implementation and bitstream generation succeeded on 6 October 2026. The matching original BIT/LTX and all supplied routed reports/logs are in `Results/`.
- Physical PYNQ-Z2 programming and JTAG/VIO testing were performed by the team. The saved 45-case CSV, board photograph, PASS/console/VIO screenshots and recorded demo provide the evidence.
- Independent offline inspection of that CSV matches every score and prediction to the frozen reference: 45/45 exact integer results, 43/45 correct ground-truth labels. This audit is not a new physical board run.
- Fresh Icarus Verilog 12.0 simulation passes 4,502 vectors per core, controller tests, reset recovery, input latching, streaming/bubbles, argmax ties and saturation. Actual output is in `Simulation/transcript.txt`.
- A supplementary three-case trace bench checks the demo classes/scores and 4/36-cycle latencies. Its VCD, waveform, measurements and actual console output are preserved.
- The live VIO reader correction was retained in `Vivado/hardware_test.tcl`; independent host parser tests cover ten numeric representations, signed restoration and unsupported-radix rejection. They do not exercise FPGA logic.
- Yosys generates the included source-derived schematic. Proprietary clock/VIO IP is represented by port-accurate black boxes for this view, not functional vendor models.

No new Vivado run, FPGA programming, vendor-IP simulation, power measurement or end-to-end host latency benchmark was performed during this repository packaging. Timing/resource claims come from the original routed reports; 80/720 ns are core latencies at the verified 50 MHz implementation.

The final narrated demo is linked in Video_Link.txt; content/access review status is in VIDEO_REVIEW.md. The original laptop `.xpr` and IP source files are now preserved in the native source archive; generated caches/runs are excluded and original machine paths remain. Use the Tcl scripts for a clean relocated rebuild. Both RTL benches were rerun successfully in local XSim 2025.1.1 on 9 October 2026 (IST). Members and registration numbers are filled; team name is Beyond Boolean. Current status is tracked in `SUBMISSION_READINESS.md`.
