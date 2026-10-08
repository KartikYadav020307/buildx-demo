# Original testbench

`ecg_bandpass_filter_tb.cpp` is the actual Vitis HLS C++ testbench supplied with
the design. Its C-simulation logs are preserved in `../Simulation/HLS_C_Simulation`.
It is not a Verilog `tb_top.v`. A separate RTL testbench and executed waveform
are still required for the organizer's literal RTL simulation checklist.
