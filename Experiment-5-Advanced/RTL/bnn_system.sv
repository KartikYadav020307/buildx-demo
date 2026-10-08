`timescale 1ns/1ps
module bnn_system #(parameter integer PERIOD=50000,WATCHDOG=500000)(
 input logic clk,rst,input logic request,input logic [3:0] command,input logic bank,
 input logic [5:0] address,input logic [31:0] payload,
 input logic emergency,button_clear,button_next,switch_run,switch_pause,
 output logic acknowledge,output logic [7:0] status,output logic [15:0] readback,
 output logic active_valid,active_bank,output logic [15:0] model_id,
 output logic armed,tripped,output logic [1:0] final_action,neural_class,
 output logic [8:0] margin,output logic [15:0] reasons,history,
 output logic [35:0] scores,output logic [15:0] hidden,sample_id,result_model_id,
 output logic [31:0] fast_cycles,folded_cycles,seal_cycles,commit_cycles,comparison_count,mismatch_count,
 output logic [31:0] watchdog_age,accepted_count,decision_count,output logic system_busy,
 output logic [15:0] displayed_raw
);
 import bnn_math_pkg::*;
 logic seen,mail_busy;logic [3:0] saved_command;
 logic cfg_start,cfg_busy,cfg_done,cfg_commit,cfg_committed;logic [7:0] cfg_status;
 logic [15:0] cfg_read;logic cfg_bank;logic [5:0] cfg_addr;logic [15:0] cfg_data;logic [2:0] cfg_cmd;
 logic [255:0] hw;logic [63:0] ow;logic [79:0] ts;logic [31:0] bs;logic [8:0] min_margin;
 logic pbusy,pvalid,prevalid,sbusy,svalid,accept,accept_folded,hold_accept;
 logic [35:0] prescores,pscores,sscores;logic [15:0] prehidden,phidden,shidden,presid,premid,psid,pmid,ssid,smid;
 logic [1:0] preclass,pclass,sclass;logic [8:0] premargin,pmargin,smargin;
 logic manual_pending,manual_wait,live_pending,live_mode,host_run,host_pause;
 logic [15:0] manual_raw,live_raw,pending_raw;logic manual_sensor,live_sensor,pending_sensor;
 logic [31:0] period_count,tick,compare_start;logic [15:0] sequence_id;
 logic frame_present,frame_sensor;logic [15:0] frame_raw;logic live_run,paused;
 logic clear_req,disarm_req,clear_done,clear_ok;
 logic [35:0] fast_snapshot;logic [15:0] fast_hidden,fast_model,fast_sample;
 logic [1:0] fast_class;logic [8:0] fast_margin;logic [3:0] preset;
 function automatic logic [15:0] preset_raw(input logic [3:0] n);
   case(n)
     0:return 16'h0000; 1:return 16'h0111; 2:return 16'h0222;
     3:return 16'h0233; 4:return 16'h2233; 5:return 16'h0024;
     default:return 16'h0000;
   endcase
 endfunction
 assign live_run=live_mode&&(host_run||switch_run);
 assign paused=host_pause||switch_pause;
 assign frame_present=manual_pending||live_pending;
 assign frame_raw=manual_pending ? manual_raw : pending_raw;
 assign frame_sensor=manual_pending ? manual_sensor : pending_sensor;
 assign hold_accept=cfg_commit||(mail_busy&&saved_command==5)||((request!=seen)&&command==5);
 assign accept=frame_present&&frame_sensor&&legal_raw(frame_raw)&&active_valid&&!hold_accept;
 assign accept_folded=accept&&manual_pending;
 assign system_busy=mail_busy||pbusy||sbusy||cfg_busy;
 assign displayed_raw=live_mode ? live_raw : manual_raw;
 bnn_config config_i(.clk,.rst,.start(cfg_start),.command(cfg_cmd),.bank(cfg_bank),.address(cfg_addr),.data(cfg_data),
   .cores_busy(pbusy||sbusy),.busy(cfg_busy),.done(cfg_done),.status(cfg_status),.readback(cfg_read),
   .active_valid,.active_bank,.committing(cfg_commit),.committed(cfg_committed),.active_id(model_id),.min_margin,
   .hw,.ow,.thresholds(ts),.biases(bs),.seal_cycles,.commit_cycles);
 bnn_parallel parallel_i(.clk,.rst,.accept,.x(encode_raw(frame_raw)),.sample_id(sequence_id),.model_id,
   .hw,.ow,.thresholds(ts),.biases(bs),.busy(pbusy),.pre_valid(prevalid),.pre_scores(prescores),.pre_hidden(prehidden),
   .pre_sample(presid),.pre_model(premid),.pre_class(preclass),.pre_margin(premargin),.valid(pvalid),.scores(pscores),
   .hidden(phidden),.out_sample(psid),.out_model(pmid),.out_class(pclass),.margin(pmargin));
 bnn_folded folded_i(.clk,.rst,.accept(accept_folded),.x(encode_raw(frame_raw)),.sample_id(sequence_id),.model_id,
   .hw,.ow,.thresholds(ts),.biases(bs),.busy(sbusy),.valid(svalid),.scores(sscores),.hidden(shidden),
   .out_sample(ssid),.out_model(smid),.out_class(sclass),.margin(smargin));
 bnn_safety #(.WATCHDOG(WATCHDOG)) safety_i(.clk,.rst,.run_enable(live_run),.model_valid(active_valid),.emergency,
   .frame_present,.sensor_valid(frame_sensor),.raw(frame_raw),.accepted(accept),.accepted_id(sequence_id),.active_id(model_id),
   .pipe_busy(pbusy||sbusy),.commit_pending(hold_accept),.committed(cfg_committed),.clear_request(clear_req||button_clear),.disarm(disarm_req),
   .decision_valid(prevalid),.decision_id(presid),.decision_model(premid),.proposal(preclass),.margin(premargin),.min_margin,
   .armed,.tripped,.action(final_action),.reasons,.history,.clear_done,.clear_ok,.age(watchdog_age));
 always_ff @(posedge clk) begin
   if(rst) begin
     seen<=request;acknowledge<=request;status<=8'h80;readback<=0;mail_busy<=0;saved_command<=0;
     cfg_start<=0;cfg_cmd<=0;cfg_bank<=0;cfg_addr<=0;cfg_data<=0;
     manual_pending<=0;manual_wait<=0;live_pending<=0;live_mode<=0;host_run<=0;host_pause<=0;
     manual_raw<=0;live_raw<=0;pending_raw<=0;manual_sensor<=1;live_sensor<=1;pending_sensor<=1;
     period_count<=0;tick<=0;compare_start<=0;sequence_id<=0;clear_req<=0;disarm_req<=0;preset<=0;
     scores<=0;hidden<=0;sample_id<=0;result_model_id<=0;neural_class<=3;margin<=0;fast_cycles<=0;folded_cycles<=0;
     comparison_count<=0;mismatch_count<=0;accepted_count<=0;decision_count<=0;
     fast_snapshot<=0;fast_hidden<=0;fast_model<=0;fast_sample<=0;fast_class<=3;fast_margin<=0;
   end else begin
     tick<=tick+1'b1;cfg_start<=0;clear_req<=0;disarm_req<=0;
     if(live_run&&!paused) begin
       if(period_count==0&&!live_pending) begin
         pending_raw<=live_raw;pending_sensor<=live_sensor;live_pending<=1;period_count<=PERIOD-1;
       end else if(period_count!=0) period_count<=period_count-1'b1;
     end
     if(!live_run) begin live_pending<=0;period_count<=0;end
     if(button_next) begin preset<=preset==5 ? 0 : preset+1'b1;live_raw<=preset_raw(preset==5 ? 0 : preset+1'b1);live_sensor<=1;end
     if(frame_present&&(!frame_sensor||!legal_raw(frame_raw)||accept)) begin
       if(manual_pending) manual_pending<=0;else live_pending<=0;
       if(manual_pending&&(!frame_sensor||!legal_raw(frame_raw))) begin manual_wait<=0;mail_busy<=0;status<=8'h13;acknowledge<=seen;end
     end
     if(accept) begin
       accepted_count<=accepted_count+1'b1;sequence_id<=sequence_id+1'b1;
       if(manual_pending) compare_start<=tick;
     end
     if(prevalid) begin
       decision_count<=decision_count+1'b1;scores<=prescores;hidden<=prehidden;sample_id<=presid;result_model_id<=premid;neural_class<=preclass;margin<=premargin;
       if(manual_wait) begin
         fast_cycles<=tick-compare_start;fast_snapshot<=prescores;fast_hidden<=prehidden;fast_model<=premid;fast_sample<=presid;
         fast_class<=preclass;fast_margin<=premargin;
       end
     end
     if(svalid&&manual_wait) begin
       folded_cycles<=tick-compare_start-1'b1;comparison_count<=comparison_count+1'b1;
       if(sscores!=fast_snapshot||shidden!=fast_hidden||smid!=fast_model||ssid!=fast_sample||sclass!=fast_class||smargin!=fast_margin) begin
         mismatch_count<=mismatch_count+1'b1;status<=8'h14;
       end else status<=0;
       manual_wait<=0;mail_busy<=0;acknowledge<=seen;
     end
     if(mail_busy&&saved_command<=6&&cfg_done) begin
       status<=cfg_status;readback<=cfg_read;acknowledge<=seen;mail_busy<=0;
     end
     if(mail_busy&&saved_command==10&&clear_done) begin
       status<=clear_ok ? 0 : 8'h12;acknowledge<=seen;mail_busy<=0;
     end
     if(mail_busy&&saved_command==11&&!pbusy&&!sbusy) begin
       status<=0;acknowledge<=seen;mail_busy<=0;
     end
     if(request!=seen&&!mail_busy) begin
       seen<=request;saved_command<=command;status<=0;readback<=0;
       if(command>=1&&command<=6) begin
         cfg_cmd<=command[2:0];cfg_bank<=bank;cfg_addr<=address;cfg_data<=payload[15:0];cfg_start<=1;mail_busy<=1;
       end else case(command)
         7: if(live_mode||pbusy||sbusy||!active_valid) begin status<=8'h11;acknowledge<=request;end
            else begin manual_raw<=payload[15:0];manual_sensor<=payload[16];manual_pending<=1;manual_wait<=1;mail_busy<=1;end
         8: if(!live_mode&&(armed||pbusy||sbusy)) begin status<=8'h11;acknowledge<=request;end
            else begin
              live_mode<=1;host_run<=payload[17];live_raw<=payload[15:0];live_sensor<=payload[16];
              // Apply the new scenario only to the next generated frame.
              acknowledge<=request;
            end
         9: begin host_pause<=payload[0];acknowledge<=request;end
         10: begin clear_req<=1;mail_busy<=1;end
         11: begin host_run<=0;live_mode<=0;disarm_req<=1;live_pending<=0;mail_busy<=1;end
         default: begin status<=6;acknowledge<=request;end
       endcase
     end
   end
 end
endmodule
