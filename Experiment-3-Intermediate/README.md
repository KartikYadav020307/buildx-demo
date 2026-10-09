# Experiment 3 — FPGA ECG FIR Filtering and Peak Analysis

V-SPACE FPGA Build Challenge 2026 | Intermediate | PYNQ-Z2 / XC7Z020

**Team:** Beyond Boolean
**Members:** Shanshank Pulipati (25BEC0573); Kartik Yadav (25BEC0087).
**Tools:** Vitis HLS and Vivado 2025.1.1; Python/Jupyter on PYNQ.

## What was implemented

A 128-tap Q4.12 FIR filter runs in FPGA programmable logic. AXI DMA sends
16-bit samples between DDR and the filter. Python on the Zynq ARM processor
detects candidate peaks and estimates heart rate. The demonstrated input is
synthetic sine data and prerecorded MIT-BIH ECG, rather than a live ECG sensor.

## Saved physical-board results

| Check | Saved result |
| --- | --- |
| Overlay and DMA | Overlay loaded; `axi_dma_0` detected |
| Synthetic sine reference comparison | 2,048/2,048 exact; maximum error 0 Q4.12 LSB |
| 5 Hz gain | 0.9940 |
| 50 Hz interference reduction | 53.74 dB for the demonstrated sine test |
| Recorded ECG reference comparison | 12,288/12,288 exact; six batches of 2,048 |
| Peak analysis on ARM | 42 peaks; mean RR about 0.812 s; heart rate about 73.9 bpm |
| Python + DMA wall time | 7.55 ms in the saved run; not FPGA-only latency |

These values come from the supplied, executed board notebook and saved JSON/CSV
files. This repository upload did not rerun the physical board. The peak detector
uses a height threshold and 300 ms minimum separation; it is not a clinically
validated arrhythmia classifier or a hardware QRS detector.

## Files

| Folder / file | Contents |
| --- | --- |
| `Documentation/` | Seven-section technical report, readiness audit and demo recording guide |
| `RTL/HLS_Source/` | Original C++, header, configuration, packaged IP ZIP and expanded IP |
| `RTL/Generated_Verilog/` | Actual HLS top module and its generated Verilog dependencies; Vivado wrapper |
| `RTL/Vivado_Block_Design/` | Recovered `system.bd` and original project descriptor |
| `RTL/Constraints/` | Actual generated IP/out-of-context XDC files and provenance |
| `Testbench/` | Original HLS C++ testbench, executable RTL testbench and vector generator |
| `Simulation/` | Original HLS reports plus executed RTL waveform, transcript, samples and report |
| `Images/` | Actual board/Jupyter captures, real Vivado PDF/PNG, original result plots and source-derived block diagram |
| `PYNQ_Hardware/` | Matching BIT/HWH/XSA, executed notebooks, input data and captured results |
| `Video_Link.txt` | Intentionally empty until the final demo URL is supplied |

The synthesis top is named `ecg_bandpass_filter`, rather than the organizer's
generic example `top_module`. Its generated submodules are now included as files
and in the original IP package. `system_wrapper.v` depends on the Vivado block
design and vendor IP; it is not a standalone pure-Verilog whole-system build.

## Run the board demonstration

1. Boot a PYNQ-Z2 with its compatible PYNQ microSD image. Connect Ethernet and
   PROG-UART. Confirm the board IP address from the serial console before opening
   its Jupyter URL; a replacement board may have a different address.
2. Upload the complete `PYNQ_Hardware` folder to the board's Jupyter workspace.
   Open `Project3_ECG_Demo.ipynb` from inside that folder. The notebook expects
   `ecg_filter.bit`, `ecg_filter.hwh`, `fir_reference.json`,
   `ecg_record100_360hz.csv` and `DATA_SOURCE.md` beside it.
3. Run the cells in order on the board. They load the overlay, allocate DMA
   buffers, flush the filter state, check the sine response, process the ECG in
   six batches, compare with the fixed-point model, and plot candidate peaks.
4. Confirm the numerical/frequency checks and `BOARD DEMO CHECKS PASSED` output.
   Save the executed notebook and newly produced result files. Keep the supplied
   `Supporting_Data_and_Results` snapshot as the original saved evidence.
5. Record the board and software demonstration using
   `Documentation/DEMO_RECORDING_GUIDE.md`, then put only the final public Drive
   video URL into `Video_Link.txt`.

The XSA is the matching exported hardware handoff, verified to contain the same
bitstream as `ecg_filter.bit`. PYNQ loading uses the matching BIT and HWH filenames.

## Rebuild and source provenance

Use the complete original HLS and Vivado project archives linked in
`Documentation/SOURCE_PROVENANCE.md` for the original project workspaces.
`project_1.xpr` preserves original file references and may need path repair;
the descriptor alone is not the entire Vivado project. The expanded packaged
HLS IP can be added as a Vivado IP repository. The HLS configuration targets
`xc7z020clg400-1`, a 10 ns clock and `ecg_bandpass_filter` as the top function.
No fresh synthesis or implementation was performed during this update.
Independent RTL simulation was executed against the original generated core.

Independent RTL verification is now included: 28,672 exact samples across 14 batches, with actual waveform, transcript and simulation report. An original Jupyter screenshot has been recovered. The actual Vivado schematic and physical board photograph are now included. Only the final demo URL remains outstanding for Project 3. See the explicit
[submission audit](Documentation/SUBMISSION_READINESS.md).

## ECG data attribution

MIT-BIH Arrhythmia Database v1.0.0, record 100, channel MLII, samples 0–12287 at
360 Hz. Attribution and data license are in `PYNQ_Hardware/DATA_SOURCE.md`.
Source: https://physionet.org/content/mitdb/1.0.0/.

## Completion package update - 9 October 2026

Independent Icarus RTL simulation, the original Jupyter capture, actual PYNQ-Z2 photograph and real Vivado hierarchy PDF/PNG are included. The report incorporates these captures and the confirmed Beyond Boolean team details. See Documentation/SUBMISSION_READINESS.md. The final demo link remains blank by instruction; the physical-board run was not repeated.
