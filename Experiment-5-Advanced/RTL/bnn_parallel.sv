`timescale 1ns/1ps
module bnn_parallel(
 input logic clk,rst,accept,input logic [15:0] x,sample_id,model_id,
 input logic [255:0] hw,input logic [63:0] ow,input logic [79:0] thresholds,input logic [31:0] biases,
 output logic busy,pre_valid,output logic [35:0] pre_scores,output logic [15:0] pre_hidden,pre_sample,pre_model,
 output logic [1:0] pre_class,output logic [8:0] pre_margin,
 output logic valid,output logic [35:0] scores,output logic [15:0] hidden,out_sample,out_model,
 output logic [1:0] out_class,output logic [8:0] margin
);
 import bnn_math_pkg::*;
 logic [4:0] v; logic [15:0] xr,h2,h3,h4;
 logic [79:0] hp; logic [19:0] op;
 logic [15:0] sid[0:4],mid[0:4]; logic [10:0] dec;
 assign busy=|v; assign pre_valid=v[4]; assign pre_hidden=h4;
 assign pre_sample=sid[4]; assign pre_model=mid[4];
 assign dec=decide(pre_scores); assign pre_class=dec[1:0]; assign pre_margin=dec[10:2];
 always_ff @(posedge clk) begin
   if(rst) begin
     v<=0; valid<=0; xr<=0; hp<=0; h2<=0; h3<=0; h4<=0; op<=0; pre_scores<=0;
     scores<=0; hidden<=0; out_sample<=0; out_model<=0; out_class<=3; margin<=0;
     for(int i=0;i<5;i++) begin sid[i]<=0;mid[i]<=0;end
   end else begin
     v<={v[3:0],accept}; valid<=v[4];
     if(accept) begin xr<=x;sid[0]<=sample_id;mid[0]<=model_id;end
     for(int i=1;i<5;i++) begin sid[i]<=sid[i-1];mid[i]<=mid[i-1];end
     if(v[0]) for(int i=0;i<16;i++) hp[i*5+:5]<=pop16(~(xr^hw[i*16+:16]));
     if(v[1]) for(int i=0;i<16;i++) h2[i]<=hp[i*5+:5]>=thresholds[i*5+:5];
     if(v[2]) begin
       h3<=h2;
       for(int i=0;i<4;i++) op[i*5+:5]<=pop16(~(h2^ow[i*16+:16]));
     end
     if(v[3]) begin
       h4<=h3;
       for(int i=0;i<4;i++) pre_scores[i*9+:9]<=score16(op[i*5+:5],biases[i*8+:8]);
     end
     if(v[4]) begin
       scores<=pre_scores;hidden<=h4;out_sample<=sid[4];out_model<=mid[4];
       out_class<=pre_class;margin<=pre_margin;
     end
   end
 end
endmodule
