`timescale 1ns/1ps
module bnn_board_top(input logic sysclk,input logic [3:0] btn,input logic [1:0] sw,output logic [3:0] led);
 logic clk,locked;logic [3:0] reset_release=4'hf;
 logic vio_reset,request;logic [3:0] command;logic bank;logic [5:0] address;logic [31:0] payload;
 (* ASYNC_REG="TRUE" *) logic [5:0] io_meta=0,io_sync=0;
 logic [1:0] button_last=0;logic [1:0] buttons_event;logic [19:0] debounce=0;
 logic rst;logic [25:0] heartbeat=0;
 logic ack;logic [7:0] status;logic [15:0] readback,model_id,reasons,history,hidden,sample_id,raw,result_model;
 logic active_valid,active_bank,armed,tripped,busy;logic [1:0] action,proposal;logic [8:0] margin;
 (* KEEP="TRUE" *) logic [4:0] state_bits;
 logic [35:0] scores;logic [31:0] fast,folded,seal,commit,comparisons,mismatches,age,accepts,decisions;
 bnn_clk clock_i(.clk_in1(sysclk),.reset(1'b0),.clk_out1(clk),.locked(locked));
 always_ff @(posedge clk or negedge locked) begin
   if(!locked) reset_release<=4'hf;else reset_release<={reset_release[2:0],1'b0};
 end
 assign rst=reset_release[3]||vio_reset||io_sync[3];
 always_ff @(posedge clk) begin
   io_meta<={sw,btn};io_sync<=io_meta;
   buttons_event<=0;
   if(rst) begin heartbeat<=0;button_last<=0;debounce<=0;end
   else begin
     heartbeat<=heartbeat+1'b1;
     if(debounce==0) begin
       buttons_event<=io_sync[2:1]&~button_last;button_last<=io_sync[2:1];
       if(|(io_sync[2:1]&~button_last)) debounce<=20'd1000000;
     end else debounce<=debounce-1'b1;
   end
 end
 bnn_system system_i(.clk,.rst,.request,.command,.bank,.address,.payload,
   .emergency(io_sync[0]),.button_clear(buttons_event[0]),.button_next(buttons_event[1]),
   .switch_run(io_sync[4]),.switch_pause(io_sync[5]),.acknowledge(ack),.status,.readback,
   .active_valid,.active_bank,.model_id,.armed,.tripped,.final_action(action),.neural_class(proposal),.margin,.reasons,.history,
   .scores,.hidden,.sample_id,.result_model_id(result_model),.fast_cycles(fast),.folded_cycles(folded),.seal_cycles(seal),.commit_cycles(commit),
   .comparison_count(comparisons),.mismatch_count(mismatches),.watchdog_age(age),.accepted_count(accepts),.decision_count(decisions),
   .system_busy(busy),.displayed_raw(raw));
 assign led={action,armed,heartbeat[24]};
 assign state_bits={busy,tripped,armed,active_bank,active_valid};
 bnn_vio vio_i(.clk,
   .probe_out0(vio_reset),.probe_out1(request),.probe_out2(command),.probe_out3(bank),.probe_out4(address),.probe_out5(payload),
   .probe_in0(ack),.probe_in1(status),.probe_in2(readback),.probe_in3(state_bits),
   .probe_in4(model_id),.probe_in5(proposal),.probe_in6(action),.probe_in7(margin),.probe_in8(scores),
   .probe_in9(reasons),.probe_in10(history),.probe_in11(sample_id),.probe_in12(hidden),.probe_in13(fast),.probe_in14(folded),
   .probe_in15(seal),.probe_in16(commit),.probe_in17(comparisons),.probe_in18(mismatches),.probe_in19(age),
   .probe_in20(accepts),.probe_in21(decisions),.probe_in22(raw),.probe_in23(heartbeat),.probe_in24(result_model));
endmodule
