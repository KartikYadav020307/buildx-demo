# Testbenches

ecg_bandpass_filter_tb.cpp is the original Vitis HLS C++ testbench.
tb_top.v is the independently executed Verilog RTL unit testbench for the
unchanged HLS-generated FIR core. generate_vectors.py makes deterministic
stimuli and fixed-point reference values; run_rtl_sim.py compiles/runs Icarus.

From the experiment folder: python Testbench/run_rtl_sim.py
Requires Python/NumPy and iverilog/vvp on PATH. The test covers 28672 samples,
14 count=2048 invocations, zero-batch flush, signed data, batch history, valid/
ready stalls, output stability, KEEP/STRB and TLAST. No physical board is needed.
