`timescale 1ns/1ps
module bnn_folded(
 input logic clk,rst,accept,input logic [15:0] x,sample_id,model_id,
 input logic [255:0] hw,input logic [63:0] ow,input logic [79:0] thresholds,input logic [31:0] biases,
 output logic busy,valid,output logic [35:0] scores,output logic [15:0] hidden,out_sample,out_model,
 output logic [1:0] out_class,output logic [8:0] margin
);
 import bnn_math_pkg::*;
 logic [4:0] step; logic [15:0] xr; logic [10:0] dec;
 logic [15:0] selected_w;logic [4:0] pc;
 always_comb begin
   selected_w=0;
   if(step<16) selected_w=hw[step*16+:16];
   else if(step<20) selected_w=ow[(step-16)*16+:16];
 end
 assign pc=pop16(~((step<16 ? xr : hidden)^selected_w));
 assign dec=decide(scores);
 always_ff @(posedge clk) begin
   if(rst) begin
     step<=0;xr<=0;busy<=0;valid<=0;scores<=0;hidden<=0;out_sample<=0;out_model<=0;out_class<=3;margin<=0;
   end else begin
     valid<=0;
     if(accept&&!busy) begin
       xr<=x;out_sample<=sample_id;out_model<=model_id;busy<=1;step<=0;hidden<=0;
     end else if(busy) begin
       step<=step+1'b1;
       if(step<16) hidden[step[3:0]]<=pc>=thresholds[step*5+:5];
       else if(step<20) scores[(step-16)*9+:9]<=score16(pc,biases[(step-16)*8+:8]);
       else begin valid<=1;busy<=0;out_class<=dec[1:0];margin<=dec[10:2];end
     end
   end
 end
endmodule
