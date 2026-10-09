# Generated RTL

`ecg_bandpass_filter.v` is the actual HLS core top module. Its generated pipeline,
multiply-add, register-slice and monitor files were extracted unchanged from
`../HLS_Source/ecg_bandpass_filter_packaged_IP.zip`. Preserve the `.vh` file when
using the core. `system_wrapper.v` is the original Vivado block-design wrapper,
which requires generation of the block-design/vendor IP hierarchy.

Independent RTL simulation has now passed against this unchanged generated core.
The executable Verilog testbench and original HLS C++ testbench are in
`../../Testbench/`; actual results are in `../../Simulation/`.
