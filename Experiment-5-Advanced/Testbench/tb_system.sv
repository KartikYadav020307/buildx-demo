`timescale 1ns/1ps
module tb_system;
 parameter PASS_FILE="SYSTEM_TEST_PASS.txt";
 parameter DATA_DIR=".";
 import bnn_math_pkg::*;
 logic clk=0;always #10 clk=~clk;
 logic rst=1,request=0,bank=0,emergency=0,button_clear=0,button_next=0,switch_run=0,switch_pause=0;
 logic [3:0] command=0;logic [5:0] address=0;logic [31:0] payload=0;
 logic ack,av,ab,armed,trip,busy;logic [7:0] status;logic [15:0] rd,mid,reasons,history,hidden,sid,raw;
 logic [1:0] action,proposal;logic [8:0] margin;logic [35:0] scores;
 logic [31:0] fast,folded,seal,commit,comparisons,mismatches,age,accepts,decisions;
 logic [15:0] image_a[0:41],image_b[0:41];logic [79:0] ga[0:65535],gb[0:65535];
 integer checks=0;logic [15:0] ca,cb;
 bnn_system #(.PERIOD(40),.WATCHDOG(400)) dut(.clk,.rst,.request,.command,.bank,.address,.payload,
 .emergency,.button_clear,.button_next,.switch_run,.switch_pause,.acknowledge(ack),.status,.readback(rd),
 .active_valid(av),.active_bank(ab),.model_id(mid),.armed,.tripped(trip),.final_action(action),.neural_class(proposal),
 .margin,.reasons,.history,.scores,.hidden,.sample_id(sid),.fast_cycles(fast),.folded_cycles(folded),
 .seal_cycles(seal),.commit_cycles(commit),.comparison_count(comparisons),.mismatch_count(mismatches),
 .watchdog_age(age),.accepted_count(accepts),.decision_count(decisions),.system_busy(busy),.displayed_raw(raw));
 task check(input bit okay,input string msg);checks=checks+1;if(!okay)$fatal(1,"SYSTEM FAIL: %s",msg);endtask
 function automatic logic [15:0] calc_crc(input bit which);
   logic [15:0] c,w;logic [23:0] block;
   c=16'hffff;
   for(int a=0;a<42;a++) begin
     w=which?image_b[a]:image_a[a];block={8'(a),w};
     for(int k=23;k>=0;k--) c={c[14:0],1'b0}^((c[15]^block[k])?16'h1021:16'h0000);
   end
   return c;
 endfunction
 task send(input logic [3:0] cmd,input logic bk,input logic [5:0] addr,input logic [31:0] data,input logic [7:0] expected);
   integer n;
   @(negedge clk);command=cmd;bank=bk;address=addr;payload=data;
   @(negedge clk);request=~request;n=0;
   while(ack!==request) begin @(negedge clk);n++;if(n>2000)$fatal(1,"mailbox timeout cmd %0d",cmd);end
   if(status!==expected) $display("DEBUG clear eligible=%b age=%0d legal=%b await=%b pipe=%b have=%b ids=%0d/%0d models=%0d/%0d proposal=%0d margin=%0d run=%b hist=%x",dut.safety_i.eligible,age,dut.safety_i.latest_legal,dut.safety_i.awaiting,dut.pbusy,dut.safety_i.have_decision,dut.safety_i.last_completed,dut.safety_i.last_accepted,dut.safety_i.last_model,mid,dut.safety_i.latest_proposal,dut.safety_i.latest_margin,dut.live_run,history);
   check(status===expected,$sformatf("command %0d status %02x expected %02x",cmd,status,expected));
 endtask
 task load(input bit bk);
   send(1,bk,0,0,0);
   for(int a=0;a<42;a++) begin
     send(2,bk,6'(a),bk?image_b[a]:image_a[a],0);
     send(3,bk,6'(a),0,0);check(rd===(bk?image_b[a]:image_a[a]),"readback");
   end
   send(4,bk,0,bk?cb:ca,0);check(seal==1008,"bit-serial seal cycles");
 endtask
 task compare_case(input logic [15:0] rw,input bit profile);
   logic [79:0] g;integer previous;
   g=profile?gb[encode_raw(rw)]:ga[encode_raw(rw)];previous=comparisons;
   send(7,0,0,{15'b0,1'b1,rw},0);
   check(comparisons==previous+1&&mismatches==0,"one comparison and no mismatch");
   check({1'b0,encode_raw(rw),hidden,scores,margin,proposal}===g,"independent golden");
   check(fast==5&&folded==21,"measured core latency");check(action==3&&!armed,"manual remains disarmed");
 endtask
 task safe_arm;
   send(8,0,0,32'h00030000,0);repeat(60)@(negedge clk);
   // Retry clear only on a fresh, empty pipeline; races return refusal.
   do @(negedge clk); while(!(dut.safety_i.eligible&&dut.period_count>10));
   send(10,0,0,0,0);check(armed&&!trip&&action==0,"safe explicit arm");
 endtask
 initial begin : main
   integer before_count;logic [15:0] rw;
   $readmemh({DATA_DIR,"/Models/normal.mem"},image_a);$readmemh({DATA_DIR,"/Models/cautious.mem"},image_b);
   $readmemh({DATA_DIR,"/Data/normal_golden.mem"},ga);$readmemh({DATA_DIR,"/Data/cautious_golden.mem"},gb);
   ca=calc_crc(0);cb=calc_crc(1);repeat(4)@(negedge clk);rst=0;repeat(2)@(negedge clk);
   check(!av&&action==3&&!armed,"reset safe");send(5,0,0,0,5);send(1,0,0,0,0);send(4,0,0,ca,2);
   send(2,0,42,0,3);send(2,0,20,18,3);send(2,0,36,16'h0080,3);send(2,0,40,0,3);send(2,0,41,288,3);
   load(0);send(5,0,0,0,0);check(av&&mid==1&&!ab,"initial commit");
   send(1,0,0,0,1);send(2,0,0,0,1);send(6,0,0,0,1);
   for(int d=0;d<5;d++)for(int v=0;v<5;v++)for(int a=0;a<5;a++)for(int u=0;u<5;u++)begin
     rw={4'(u),4'(a),4'(v),4'(d)};compare_case(rw,0);
   end
   before_count=comparisons;repeat(30)@(negedge clk);check(comparisons==before_count,"held request never replays");
   $display("SYSTEM normal: all 625 raw cases, hardware-style mailbox and measured 5/21 cycles PASS");
   // Normal model continues making decisions while the inactive bank is loaded and sealed.
   safe_arm();before_count=decisions;load(1);check(mid==1&&decisions>before_count&&armed,"load while live");
   send(1,1,0,0,0);for(int a=0;a<42;a++)send(2,1,6'(a),image_b[a],0);
   send(4,1,0,cb^16'h0001,4);check(mid==1&&armed,"bad CRC keeps active model");
   send(4,1,0,cb,0);send(8,0,0,32'h00030222,0);repeat(60)@(negedge clk);
   check(proposal==1&&action==1,"normal CAUTION scenario");
   send(5,1,0,0,0);check(mid==2&&ab&&commit<=6,"atomic live commit bound");repeat(60)@(negedge clk);
   check(proposal==2&&action==2,"same input cautious BRAKE");
   // Switching models cannot clear an existing STOP.
   @(negedge clk);emergency=1;repeat(3)@(negedge clk);check(trip&&action==3,"emergency stop");
   send(10,0,0,0,8'h12);send(5,0,0,0,0);check(trip&&action==3&&mid==1,"rollback preserves STOP");
   emergency=0;repeat(10)@(negedge clk);check(trip&&action==3,"release never clears");safe_arm();
   send(8,0,0,32'h00030024,0);repeat(60)@(negedge clk);check(trip&&history[2]&&action==3,"critical guard");safe_arm();
   send(8,0,0,32'h00030005,0);repeat(60)@(negedge clk);check(trip&&history[1],"illegal level");safe_arm();
   send(8,0,0,32'h00020000,0);repeat(60)@(negedge clk);check(trip&&history[1],"invalid sensor");safe_arm();
   send(9,0,0,1,0);repeat(410)@(negedge clk);check(trip&&history[3]&&action==3,"paused source watchdog");
   send(9,0,0,0,0);safe_arm();send(11,0,0,0,0);check(!armed&&action==3,"disarm");
   send(5,1,0,0,0);
   for(int d=0;d<5;d++)for(int v=0;v<5;v++)for(int a=0;a<5;a++)for(int u=0;u<5;u++)begin
     rw={4'(u),4'(a),4'(v),4'(d)};compare_case(rw,1);
   end
   // A soft reset aligns to the retained VIO toggle and cancels a pending operation.
   @(negedge clk);rst=1;repeat(2)@(negedge clk);rst=0;repeat(20)@(negedge clk);
   check(ack==request&&status==8'h80&&!av&&comparisons==0,"reset no replay");
   send(1,0,0,0,0);send(2,0,0,image_a[0],0);send(4,0,0,ca,2);send(6,0,0,0,0);
   $display("ALL SYSTEM TESTS PASSED: %0d checks; 1250 raw comparisons, model loading/switch/rollback, CRC/range/readback, live faults and watchdog.",checks);
   begin integer f;f=$fopen(PASS_FILE,"w");$fdisplay(f,"PASS checks=%0d raw_comparisons=1250",checks);$fclose(f);end
   $finish;
 end
 initial begin #20000000;$fatal(1,"System test timeout");end
endmodule
