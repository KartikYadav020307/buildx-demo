`timescale 1ns/1ps
module bnn_config(
 input logic clk,rst,start,input logic [2:0] command,input logic bank,input logic [5:0] address,
 input logic [15:0] data,input logic cores_busy,
 output logic busy,done,output logic [7:0] status,output logic [15:0] readback,
 output logic active_valid,active_bank,committing,committed,
 output logic [15:0] active_id,output logic [8:0] min_margin,
 output logic [255:0] hw,output logic [63:0] ow,output logic [79:0] thresholds,output logic [31:0] biases,
 output logic [31:0] seal_cycles,commit_cycles
);
 import bnn_math_pkg::*;
 logic [15:0] words[0:1][0:41];logic [41:0] written[0:1];logic [1:0] loading,sealed;
 logic target;logic [1:0] state;logic [5:0] index;logic [4:0] bit_index;
 logic [15:0] crc,expected,next_crc;logic [23:0] stream;logic [31:0] elapsed;
 function automatic logic legal_word(input logic [5:0] a,input logic [15:0] d);
   if(a<20) return 1;
   if(a<36) return d<=17;
   if(a<40) return d[15:8]=={8{d[7]}};
   if(a==40) return d!=0;
   if(a==41) return d<=287;
   return 0;
 endfunction
 always_comb begin
   hw=0;ow=0;thresholds=0;biases=0;active_id=0;min_margin=0;
   if(active_valid) begin
     for(int j=0;j<16;j++) begin hw[j*16+:16]=words[active_bank][j];thresholds[j*5+:5]=words[active_bank][j+20][4:0];end
     for(int j=0;j<4;j++) begin ow[j*16+:16]=words[active_bank][j+16];biases[j*8+:8]=words[active_bank][j+36][7:0];end
     active_id=words[active_bank][40];min_margin=words[active_bank][41][8:0];
   end
 end
 assign stream={2'b0,index,words[target][index]};
 assign next_crc=crc_bit(crc,stream[bit_index]);
 assign committing=(state==2);
 always_ff @(posedge clk) begin
   if(rst) begin
     busy<=0;done<=0;status<=8'h80;readback<=0;active_valid<=0;active_bank<=0;
     loading<=0;sealed<=0;written[0]<=0;written[1]<=0;target<=0;state<=0;index<=0;bit_index<=0;
     crc<=16'hffff;expected<=0;elapsed<=0;seal_cycles<=0;commit_cycles<=0;committed<=0;
     // Payload registers need no reset: validity and written bits gate every use.
   end else begin
     done<=0;committed<=0;
     if(state==1) begin
       crc<=next_crc;elapsed<=elapsed+1'b1;
       if(bit_index==0) begin
         bit_index<=23;
         if(index==41) begin
           state<=0;busy<=0;done<=1;readback<=next_crc;seal_cycles<=elapsed+1'b1;
           if(next_crc==expected) begin sealed[target]<=1;loading[target]<=0;status<=0;end
           else begin sealed[target]<=0;loading[target]<=1;status<=8'h04;end
         end else index<=index+1'b1;
       end else bit_index<=bit_index-1'b1;
     end else if(state==2) begin
       elapsed<=elapsed+1'b1;
       if(!cores_busy) begin
         active_valid<=1;active_bank<=target;state<=0;busy<=0;done<=1;status<=0;
         committed<=1;commit_cycles<=elapsed+1'b1;
       end
     end else if(start&&!busy) begin
       status<=0;readback<=0;done<=1;
       case(command)
         1: if(active_valid&&bank==active_bank) status<=1;
            else begin loading[bank]<=1;sealed[bank]<=0;written[bank]<=0;end
         2: if(active_valid&&bank==active_bank) status<=1;
            else if(!loading[bank]) status<=2;
            else if(!legal_word(address,data)) status<=3;
            else begin words[bank][address]<=data;written[bank][address]<=1;end
         3: if(address>41) status<=3;
            else if(!written[bank][address]) status<=2;
            else readback<=words[bank][address];
         4: if(active_valid&&bank==active_bank) status<=1;
            else if(!loading[bank] || !(&written[bank])) status<=2;
            else begin state<=1;busy<=1;done<=0;target<=bank;index<=0;bit_index<=23;crc<=16'hffff;expected<=data;elapsed<=0;end
         5: if(!sealed[bank] || (active_valid&&bank==active_bank)) status<=5;
            else begin state<=2;busy<=1;done<=0;target<=bank;elapsed<=0;end
         6: if(active_valid&&bank==active_bank) status<=1;
            else begin loading[bank]<=0;sealed[bank]<=0;written[bank]<=0;end
         default: status<=6;
       endcase
     end
   end
 end
endmodule
