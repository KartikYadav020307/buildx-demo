# Simulation evidence

Original HLS C-simulation logs and synthesis/implementation reports are retained.
Independent Icarus Verilog 12.0 simulation now passes 28672/28672 exact Q4.12
samples (20480 payload + 8192 zero-flush samples) across 14 batches, with output
stability under backpressure, KEEP/STRB preservation and TLAST/completion checks.

Testbench/tb_top.v targets the original HLS-generated core, not the whole Zynq
PS/vendor DMA system. Actual waveform.png, waveform_tlast.png, transcript.txt,
simulation_report.pdf, full compressed VCD, output CSV and run metadata are
included. Testbench/run_rtl_sim.py reproduces the test using installed Icarus.
