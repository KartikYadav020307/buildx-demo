# Project 4: review of the actual Vivado 2025.1.1 build

Reviewed on 6 October 2026 from the ten uploaded Results files.
Verdict: simulation and routed setup/hold/pulse-width checks pass, and bitstream
generation completed. Apply the small clock-constraint correction and review
the missing bus-skew report before considering implementation review complete.
Physical PYNQ-Z2 testing remains outstanding.

## Apply this patch to your existing project

1. Close the project in Vivado. Keep the existing build folder and all sources.
2. Copy this patch's `RTL/pynq_z2.xdc` over your project's file with the same path.
3. Copy this patch's `Vivado/collect_reports.tcl` over your project's file with
   the same path. No other source/model/testbench files change.
4. Run your existing `RUN_PROJECT4.cmd` again. It already resets generated
   synthesis/implementation runs and reruns simulation. Do not recreate the project.
5. Require a new `Results/BUILD_SUCCESS.txt`. Upload the new `vivado_batch.log`,
   `clocks.rpt`, `timing_summary.rpt`, `bus_skew.rpt`, and `methodology.rpt` for review.
   The setup/hold success marker does not automatically certify bus skew.
6. After review, program the board with the newly generated `.bit` and `.ltx`
   pair; do not mix programming files from different builds.

The patch removes the duplicate top-level primary clock declaration. The actual
build log shows that `nn_clk.xdc` already declares the same 8 ns clock on `sysclk`.
The board pin assignments and LED false paths are retained. The patch also
creates bus-skew and fresh methodology reports using AMD-documented commands.
It has not been executed in Vivado in this cloud session; rerouting results
must be taken from the new local build, not assumed to match the old numbers.

## Verified evidence from the uploaded build

| Item | Result |
|---|---|
| Tool/device | Vivado 2025.1.1; xc7z020clg400-1 |
| Simulation | XSim: all tests passed, final completion at 3,421,600 ns |
| Parallel test | 4,502 golden vectors; streamed bursts/bubbles; latency 4 periods |
| Sequential test | 4,502 golden vectors; input latching; latency 36 periods |
| Controller | 150 Iris cases; reset, held command, busy rejection, counters |
| Additional HDL checks | Reset abort/recovery, argmax ties, ReLU saturation |
| Clock | External 125 MHz; generated accelerator/debug clock 50 MHz |
| Worst setup slack | +5.815 ns; zero failing setup endpoints |
| Worst hold slack | +0.048 ns overall; +0.052 ns in the 50 MHz clock group |
| Worst pulse-width slack | +2.000 ns; zero failing pulse-width endpoints |
| Unclocked registers | 0 |
| Unconstrained internal data endpoints | 0 reported by check_timing |
| LED output exceptions | Four LED ports intentionally false-pathed |
| Bitstream | Bitgen completed successfully; DRC had 0 errors |
| Bitstream header | nn_board_top; device 7z020clg400; 2026/10/06 20:16:30 |
| Bitstream payload | 4,045,564 bytes; full declared payload present |
| Debug probes | VIO names/widths match the supplied hardware-test script |
| VIO identity | Uploaded LTX UUID matches the VIO UUID printed in the build log |

The debug hub's unconstrained table contains BSCAN SHIFT/RESET control paths.
Do not claim that every path in the entire design has a timing constraint;
the zero internal data-endpoint count is a narrower statement. Review the
fresh methodology report and test the debug interface on the physical board.

## Measured resources in this routed build

| Scope | Total LUTs | Flip-flops | DSP48 blocks | RAMB36/RAMB18 |
|---|---:|---:|---:|---:|
| Parallel neural core | 247 | 263 | 28 | 0/0 |
| Sequential neural core | 208 | 330 | 1 | 0/0 |
| Whole design including VIO/debug/controller | 1,515 | 2,648 | 29 | 0/0 |

These are implementation results from the hierarchy report. Constant trained
weights did not require block RAM. Whole-design figures include substantial
debug-interface overhead. The sequential core's control/indexing logic costs
more flip-flops here despite using fewer DSPs. Use the core rows for the
parallel-versus-sequential comparison. Hierarchy totals can differ from sums
of child rows because Vivado combines LUTs across hierarchy boundaries.

At the implemented 50 MHz clock, simulated core edge-to-edge latencies correspond
to 80 ns parallel and 720 ns sequential, a 9x latency reduction. These are
simulation-derived cycle counts at an implemented clock frequency; they are
not yet board-measured latencies or host/JTAG round-trip times.

## Warnings and unresolved checks

- **Constraints 18-1055 / XDCC-7:** the supplied board XDC redefined the clock
  supplied by Clocking Wizard. Both periods are 8 ns, but Vivado explicitly
  warned that references to the overridden clock could be ignored. This is
  the issue corrected by the patch. The new log must confirm it is gone.
- **Timing 38-436:** bus-skew constraints exist, but timing summary does not
  report them. The new `bus_skew.rpt` must be reviewed for violations.
- **DSP pipeline warnings:** 30 DPIP-1, eight DPOP-1, one DPOP-2 warnings advise
  further DSP pipelining. The existing arithmetic meets reported 50 MHz timing;
  do not add latency stages just to remove optimization suggestions now.
- **Debug IP warnings:** three PDCN-1569 and one RTSTAT-10 warning refer to
  `dbg_hub` cells/nets. Keep them documented; verify VIO operation on hardware.
  The four LUTAR-1 methodology warnings also require the fresh report to locate
  the actual cells; their exact paths were not included in the uploaded summary.
- **ZPS7-1:** no PS7 cell is instantiated. This remains a configuration warning,
  not an error, in the uploaded DRC report. The design uses an external PL clock
  and JTAG/VIO. Board boot/PHY clock availability must be verified; do not claim
  that successful bitstream generation proves correct board initialization.
- **Simulation display warnings:** XSim did not display two large testbench
  arrays because of its waveform size limit. The comparisons still ran and passed.
  The `glbl` parameter-override warning did not prevent the parameterized
  testbench from loading its golden file and writing the fresh pass marker.
- **Power 33-332:** reset switching activity may make the tool's power estimate
  inaccurate. No measured power result was provided, so do not claim one.

## Next physical test after implementation review

Open the existing `build/NN_Inference.xpr`, power/connect the PYNQ-Z2, then use
Hardware Manager -> Open Target -> Auto Connect. Program the xc7z020 FPGA with
the new `Results/nn_board_top.bit` and matching `Results/nn_board_top.ltx`.
Check the heartbeat and VIO. Then source the test script using your actual path:

```tcl
source {C:/Users/yamle/OneDrive/Desktop/Project4_NN_Complete_Pack/Project4_NN/Vivado/hardware_test.tcl}
```

Expected hardware results: all 45 held-out cases match the reference integer
scores, both cores agree, counters are 4 and 36, and classification is 43/45.
Upload `Results/hardware_test_results.csv` as physical validation evidence.
The 45/45 arithmetic matches and 43/45 correct species labels measure different
things. The latter is the frozen model's classification accuracy.

AMD references:
- https://docs.amd.com/r/2025.1-English/ug835-vivado-tcl-commands/report_bus_skew
- https://docs.amd.com/r/2025.1-English/ug903-vivado-using-constraints/About-Bus-Skew-Constraints
