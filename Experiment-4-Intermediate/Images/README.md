# Image provenance

- block_diagram.png/.svg: original architecture drawing from the recovered repair pack.
- board_setup.jpg: JPEG conversion of the actual team board photo; no semantic changes.
- hardware_output.jpg: JPEG conversion of the actual final VIO screenshot after numeric formats were corrected.
- hardware_pass.png, three_case_console.png, vivado_build_complete.png: genuine supplied PNG screenshots.
- rtl_schematic.png/.svg/.dot: actual Yosys 0.33 elaboration of the original top-level source, rendered with Graphviz. Clock/VIO are port-accurate black boxes for this view. This is not a Vivado GUI screenshot or a vendor gate-level model. See Simulation/SCHEMATIC_REPRODUCTION.md and the real netlist/tool transcript.

The actual signal-level latency trace is Simulation/waveform.png, rendered from the VCD.
