# Source-elaborated schematic reproduction

From the experiment folder, with Yosys 0.33 and Graphviz:
```sh
yosys -p 'read_verilog -sv -I RTL RTL/nn_parallel.sv RTL/nn_serial.sv RTL/nn_demo_controller.sv RTL/nn_board_top.sv Simulation/ip_blackboxes_for_schematic.v; hierarchy -check -top nn_board_top; proc; opt; write_json Simulation/rtl_schematic_netlist.json; show -format dot -prefix Images/rtl_schematic nn_board_top' > Simulation/schematic_transcript.txt
dot -Tpng -Gdpi=140 Images/rtl_schematic.dot -o Images/rtl_schematic.png
dot -Tsvg Images/rtl_schematic.dot -o Images/rtl_schematic.svg
```

The declarations in ip_blackboxes_for_schematic.v match the original clock/VIO interface ports. They are not added to Vivado design sources and do not model IP behavior. All four original RTL modules are parsed/checked; the selected top view preserves the hierarchical controller, clock/reset, heartbeat, LED wiring and VIO connections. Actual FPGA timing/resource evidence is the original Vivado report set, not this portable schematic synthesis.
