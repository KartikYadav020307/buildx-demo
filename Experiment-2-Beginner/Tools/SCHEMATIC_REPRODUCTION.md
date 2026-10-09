# Genuine source-elaborated schematic

Generated on 9 October 2026 with Yosys 0.33 and Graphviz. Original RTL bytes are unchanged. The schematic is a structural netlist view, not a Vivado GUI capture or a measurement of routed performance.

From the experiment root, with Yosys/Graphviz installed, set `YOSYS_XILINX_LIB` to the installed Yosys `share/yosys/xilinx` directory, then run:

```sh
yosys -p "read_verilog -lib $YOSYS_XILINX_LIB/cells_sim.v $YOSYS_XILINX_LIB/cells_xtra.v; read_verilog Simulation/vio_elaboration_stub.v RTL/cfar_core.v RTL/radar_demo.v RTL/radar_top.v; hierarchy -check -top radar_top; proc; opt; check -assert; stat; write_json Simulation/rtl_netlist.json; show -format dot -prefix Images/rtl_schematic radar_top" > Simulation/schematic_transcript.txt 2>&1
dot -Tpng -Gdpi=170 Images/rtl_schematic.dot -o Images/rtl_schematic.png
dot -Tsvg Images/rtl_schematic.dot -o Images/rtl_schematic.svg
```

The shipped JSON omits unused vendor-library modules only; its seven retained modules are `radar_top`, `radar_demo`, `cfar_core`, `vio_radar`, `IBUF`, `BUFG` and the specialized MMCM module. Cell/net data inside retained modules are unchanged.

VIO is a black box in this offline check. Vendor clock primitives are library declarations. The real vendor IP and clock behavior are supplied by the original successful Vivado build, not by the schematic generation. `Simulation/vio_elaboration_stub.v` is not part of the Vivado hardware sources.
