# Experiment 4 - Intermediate

## Design of an FPGA-Based Hardware Accelerator for Low-Latency Neural Network Inference

A trained **4 -> 4 ReLU -> 3 Iris classifier** on PYNQ-Z2 compares a parallel pipeline and a sequential shared-MAC core using identical frozen weights, fixed-point arithmetic and clock frequency. The host transfers inputs over USB/JTAG; neural inference executes in FPGA logic.

- [Project report: seven organizer sections](Documentation/Project4_NN_Report.pdf)
- [Simulation report](Simulation/simulation_report.pdf)
- [Organizer checklist and remaining work](Documentation/SUBMISSION_READINESS.md)
- [Original routed programming files and reports](Results/)
- [Original physical-board CSV](Evidence/hardware_test_results.csv)
- [Source schematic](Images/rtl_schematic.png) and [actual waveform](Simulation/waveform.png)

**Team:** Beyond Boolean — Shanshank Pulipati (25BEC0573), Kartik Yadav (25BEC0087).

**Final demo:** [Drive video](https://drive.google.com/file/d/1iKShZ_66BI91TXDw6vPuZwFjw929anQ-/view?usp=sharing). See [video review](Documentation/VIDEO_REVIEW.md) for content/access review status. The raw recording remains in Evidence/RAW_VIDEO.md.

| Verified metric | Result |
| --- | --- |
| Board/device/tool | PYNQ-Z2, xc7z020clg400-1, Vivado 2025.1.1 |
| Accelerator clock | 50 MHz from 125 MHz board clock |
| Parallel / sequential latency | 4 / 36 cycles; 80 / 720 ns; 9x lower core latency |
| Physical arithmetic correctness | 45/45 held-out inputs match every frozen integer score |
| Model classification accuracy | 43/45 = 95.56%; errors at dataset indices 68 and 138 |
| Parallel core resources | 247 LUTs, 263 FFs, 28 DSPs |
| Sequential core resources | 208 LUTs, 330 FFs, 1 DSP |
| Whole design | 1,515 LUTs, 2,648 FFs, 29 DSPs, zero BRAM |
| Routed setup / hold | +5.813 / +0.048 ns; zero setup/hold/pulse-width failures |
| Bus skew | All four pass; minimum slack +19.066 ns |
| Full RTL suite | 4,502 vectors per core; streaming, reset, controller and arithmetic checks pass |

Core latency excludes host/USB/JTAG overhead. The wrapper waits for both cores; the parallel core alone can accept one input per clock. Raw DRC contains 44 warnings and no errors; methodology contains four debug-hub reset warnings. They are preserved and explained rather than described as a zero-warning build.

## Use the included physical build

Keep the board's working power/SD boot setup, connect USB/JTAG, then use Vivado Hardware Manager to program **the matching `Results/nn_board_top.bit` and `Results/nn_board_top.ltx` pair**. No rebuild is needed for the demonstrated frozen model.

Source `Vivado/hardware_test.tcl` using this folder's actual absolute path on your PC. It resets and validates all 45 held-out cases, writing fresh `Results/hardware_test_results.csv`. The original recorded CSV remains separately preserved in `Evidence/`.

Then run:
```tcl
nn_hw_reset
nn_run_case d6d528e0
nn_run_case 09110b2a
nn_run_case 37281210
```

Expected classes: 0 Setosa, 1 Versicolor, 2 Virginica; mismatch 0, cycles 4/36. Reset synchronizes FPGA and Tcl counters together. Jupyter, Ethernet, Python notebooks and Vitis HLS are not needed for this implementation.

The permanent `nn_hw_read` fix honors `INPUT_VALUE_RADIX`: use Unsigned Decimal for counters/classes and Signed Decimal for scores without false timeouts. Keep features Hex and control bits Binary. The corrected reader succeeded on the board in the recorded session; it changes no RTL/model/programming files.

## Rebuild and reproduce

On Windows run `RUN_PROJECT4.cmd` with Vivado 2025.1.1. It recreates `build/NN_Inference.xpr`, generates clock/VIO IP, runs XSim, builds and collects reports. The [native source archive](FPGA_Project/) preserves the original laptop project descriptor and IP configurations; generated caches/runs are excluded and original machine paths remain. Use the generation scripts for a clean relocated build. `START_HERE.md` is the original detailed guide; this README/checklist reflects the later hardware completion.

Both the full regression and three-case waveform test passed again in local Vivado XSim 2025.1.1 on 9 October 2026 (IST). Their fresh outputs are in `Simulation/current_xsim_regression.txt` and `Simulation/current_xsim_waveform.txt`.

Optional HDL reproduction: install Icarus Verilog 12.0 and run `python python/run_open_source_tests.py`. Rebuild the PDF/waveform plot with `python Documentation/build_report.py` (reportlab, matplotlib and Pillow). Training dependencies are in `python/requirements.txt`; attribution is in `Data/ATTRIBUTION.md`.

The organizer folders Documentation/RTL/Testbench/Simulation/Images and Video_Link.txt are present. Additional Data/python/Vivado/Results/Evidence preserve reproducibility. Real SystemVerilog `.sv` filenames are retained rather than renamed to the checklist's illustrative `.v` names. SHA256SUMS.txt and Documentation/FILE_MANIFEST.json inventory the package.
