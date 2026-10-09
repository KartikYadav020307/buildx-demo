// Offline schematic-only port declarations for proprietary Vivado IP.
// NOT functional simulation models. NOT added by create_project.tcl.
(* blackbox *) module nn_clk(input clk_in1,reset,output clk_out1,locked);
endmodule
(* blackbox *) module nn_vio(input clk,
 input probe_in0,probe_in1,probe_in2,
 input [1:0] probe_in3,probe_in4,
 input [7:0] probe_in5,probe_in6,
 input [31:0] probe_in7,probe_in8,probe_in9,probe_in10,
 output probe_out0,probe_out1,output [31:0] probe_out2);
endmodule
