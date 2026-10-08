# Generated RTL

`ecg_bandpass_filter.v` is the actual HLS core top module. Its generated pipeline,
multiply-add, register-slice and monitor files were extracted unchanged from
`../HLS_Source/ecg_bandpass_filter_packaged_IP.zip`. Preserve the `.vh` file when
using the core. `system_wrapper.v` is the original Vivado block-design wrapper,
which requires generation of the block-design/vendor IP hierarchy.

No independent RTL simulation has been run in this packaging step. The original
HLS C++ testbench is in `../../Testbench/`.
