`timescale 1ns/1ps
module bnn_safety #(parameter integer WATCHDOG=500000)(
 input logic clk,rst,run_enable,model_valid,emergency,frame_present,sensor_valid,
 input logic [15:0] raw,input logic accepted,input logic [15:0] accepted_id,active_id,
 input logic pipe_busy,commit_pending,committed,clear_request,disarm,
 input logic decision_valid,input logic [15:0] decision_id,decision_model,
 input logic [1:0] proposal,input logic [8:0] margin,min_margin,
 output logic armed,tripped,output logic [1:0] action,output logic [15:0] reasons,history,
 output logic clear_done,clear_ok,output logic [31:0] age
);
 import bnn_math_pkg::*;
 logic guard_pending,latest_legal,have_decision,awaiting;
 logic [15:0] last_accepted,last_completed,last_model;logic [1:0] latest_proposal;
 logic [8:0] latest_margin;logic [15:0] fault_mask,current_mask;
 logic fresh_result,expired,eligible;logic [1:0] chosen;
 assign fresh_result=decision_valid && model_valid && decision_model==active_id;
 assign expired=armed&&run_enable&&!fresh_result&&(age>=WATCHDOG-1);
 assign eligible=run_enable&&model_valid&&!emergency&&latest_legal&&!commit_pending&&!awaiting&&
   !pipe_busy&&!accepted&&have_decision&&(last_completed==last_accepted)&&(last_model==active_id)&&
   (age<WATCHDOG)&&(latest_proposal==0)&&(latest_margin>=min_margin);
 always_comb begin
   fault_mask=0;
   fault_mask[0]=emergency;
   fault_mask[1]=frame_present&&(!sensor_valid||!legal_raw(raw));
   fault_mask[2]=guard_pending;
   fault_mask[3]=expired;
   fault_mask[4]=fresh_result&&run_enable&&(proposal==3);
   current_mask=0;
   current_mask[5]=have_decision&&latest_margin<min_margin;
   current_mask[6]=commit_pending||awaiting;
   current_mask[7]=!armed||!run_enable;
   current_mask[8]=!model_valid;
   current_mask[4:0]=fault_mask[4:0];
   chosen=fresh_result ? proposal : latest_proposal;
   if((fresh_result ? margin : latest_margin)<min_margin && chosen<2) chosen=2;
   if((commit_pending||awaiting)&&chosen<2) chosen=2;
 end
 always_ff @(posedge clk) begin
   if(rst) begin
     guard_pending<=0;latest_legal<=0;have_decision<=0;awaiting<=1;
     last_accepted<=0;last_completed<=0;last_model<=0;latest_proposal<=3;latest_margin<=0;
     armed<=0;tripped<=0;action<=3;reasons<=16'h0180;history<=0;clear_done<=0;clear_ok<=0;age<=WATCHDOG;
   end else begin
     clear_done<=clear_request;clear_ok<=0;
     guard_pending<=frame_present&&sensor_valid&&legal_raw(raw)&&critical_raw(raw);
     if(frame_present) latest_legal<=sensor_valid&&legal_raw(raw);
     if(accepted) last_accepted<=accepted_id;
     if(committed) begin awaiting<=1;have_decision<=0;end
     if(commit_pending) awaiting<=1;
     if(fresh_result) begin
       latest_proposal<=proposal;latest_margin<=margin;last_completed<=decision_id;last_model<=decision_model;
       have_decision<=1;age<=0;
       if(!commit_pending) awaiting<=0;
     end else if(age<WATCHDOG) age<=age+1'b1;
     reasons<=current_mask|history;
     if(disarm||!run_enable||!model_valid) armed<=0;
     if(|fault_mask) begin
       tripped<=1;history<=history|fault_mask;action<=3;
     end else if(clear_request&&eligible) begin
       tripped<=0;history<=0;armed<=1;action<=0;clear_ok<=1;reasons<=0;
     end else if(!model_valid||!run_enable||!armed||disarm||tripped) action<=3;
     else action<=chosen;
   end
 end
endmodule
