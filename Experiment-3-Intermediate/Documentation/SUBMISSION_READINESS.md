# Project 3 submission readiness - 9 October 2026

Team: **Beyond Boolean**. Confirmed members: **Shanshank Pulipati (25BEC0573)**
and **Kartik Yadav (25BEC0087)**, using the spellings supplied by the team.

The Project 3 documentation, source and evidence file set is complete.
The final demonstration URL remains blank by instruction, so the complete
Project 3 submission is not yet 100% finished.

| Organizer item | File / evidence | Status |
| --- | --- | --- |
| Seven-section project PDF | Project3_ECG_Report.pdf; confirmed team details, actual captures, board and RTL results | Complete |
| Block diagram | Images/block_diagram.png; source-derived architecture | Complete |
| Actual Vivado RTL schematic | Images/rtl_schematic.pdf; full-page rtl_schematic.png and magnified input detail | Complete |
| Physical board photo | Images/board_setup.jpg; original team-supplied JPEG | Complete |
| Actual hardware screenshot | Images/hardware_output.jpg; original Jupyter PNG retained | Complete |
| RTL, dependencies, constraints | RTL/; original generated core/IP, block design and generated XDC | Complete |
| Verilog testbench | Testbench/tb_top.v; independent generated-core unit test | Complete |
| Simulation waveform | Simulation/waveform.png and waveform_tlast.png; actual VCD data | Complete |
| Simulation transcript | Simulation/transcript.txt; actual commands and passing outputs | Complete |
| Simulation PDF | Simulation/simulation_report.pdf | Complete |
| FPGA execution files | PYNQ_Hardware/; matching BIT/HWH/XSA, executed notebooks, data and saved results | Complete |
| File manifest | Documentation/FILE_MANIFEST.json; SHA-256 and sizes for every other Project 3 file | Complete |
| Final demo video URL | Video_Link.txt | Intentionally blank; outstanding |

The RTL test passed 28,672/28,672 exact signed Q4.12 samples (20,480 payload and
8,192 zero-flush samples) across 14 batches. The maximum error is 0 LSB; stalls,
output stability, KEEP/STRB and TLAST/completion checks pass. This tests the
unchanged generated FIR core. Saved physical-board evidence separately covers
the PS/DMA demonstration. No new physical-board test is claimed by this update.

The real Vivado export is a selected module hierarchy: one filter pipeline and
eight AXI-stream register-slice instances. Top-level primitive logic is in the
original RTL. The original vector PDF supports detailed zoom; the PNG and report
excerpt are rendered from that PDF. The physical photo documents the actual
PYNQ-Z2 setup and is not a substitute for the numerical test logs.

The combined five-experiment team report and repository naming are separate
whole-entry requirements; this audit describes only Experiment 3.
