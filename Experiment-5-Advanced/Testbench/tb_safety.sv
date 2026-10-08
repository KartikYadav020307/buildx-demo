`timescale 1ns/1ps
module tb_safety;
 parameter PASS_FILE="SAFETY_TEST_PASS.txt";
 logic clk=0;always #10 clk=~clk;
 logic rst=1,run_enable=1,model_valid=1,emergency=0,frame_present=0,sensor_valid=1;
 logic [15:0] raw=0,accepted_id=1,active_id=1,decision_id=1,decision_model=1;
 logic accepted=0,pipe_busy=0,commit_pending=0,committed=0,clear_request=0,disarm=0,decision_valid=0;
 logic [1:0] proposal=0;logic [8:0] margin=4,min_margin=1;
 logic armed,tripped,clear_done,clear_ok;logic [1:0] action;logic [15:0] reasons,history;logic [31:0] age;
 integer checks=0;
 bnn_safety #(.WATCHDOG(8)) dut(.*);
 task check(input bit ok,input string msg);checks++;if(!ok)$fatal(1,"SAFETY FAIL %s",msg);endtask
 task edge_clock;@(posedge clk);#2;endtask
 task fresh_arm;
   @(negedge clk);rst=1;edge_clock();@(negedge clk);rst=0;frame_present=1;accepted=1;decision_valid=1;proposal=0;raw=0;sensor_valid=1;
   edge_clock();@(negedge clk);frame_present=0;accepted=0;decision_valid=0;clear_request=1;
   edge_clock();check(armed&&clear_ok&&!tripped&&action==0,"eligible clear/arm");@(negedge clk);clear_request=0;
 endtask
 initial begin
   edge_clock();fresh_arm();
   // Exact boundary: last result age 0, clear consumes one period, six more => age 7, next expires.
   repeat(6)edge_clock();check(age==7&&!tripped,"watchdog N-1");edge_clock();check(age==8&&tripped&&history[3],"watchdog N boundary");
   fresh_arm();repeat(6)edge_clock();@(negedge clk);decision_valid=1;edge_clock();check(age==0&&!tripped,"fresh result wins expiry");decision_valid=0;
   fresh_arm();@(negedge clk);emergency=1;clear_request=1;decision_valid=1;edge_clock();check(tripped&&action==3&&!clear_ok&&history[0],"emergency wins clear and safe result");
   @(negedge clk);emergency=0;clear_request=0;decision_valid=1;edge_clock();check(tripped&&action==3,"sticky emergency");decision_valid=0;
   fresh_arm();@(negedge clk);frame_present=1;raw=16'h0024;edge_clock();check(!tripped,"critical captured at E0");
   @(negedge clk);frame_present=0;edge_clock();check(tripped&&history[2]&&action==3,"critical at E1");
   fresh_arm();@(negedge clk);frame_present=1;raw=16'h0005;clear_request=1;edge_clock();check(tripped&&history[1]&&!clear_ok,"invalid level immediate");
   @(negedge clk);frame_present=0;clear_request=0;
   fresh_arm();@(negedge clk);decision_valid=1;margin=0;proposal=0;edge_clock();check(action==2&&!tripped,"ambiguous decision floors BRAKE");decision_valid=0;margin=4;
   fresh_arm();@(negedge clk);decision_valid=1;proposal=3;edge_clock();check(tripped&&action==3&&history[4],"neural STOP latches");decision_valid=0;proposal=0;
   fresh_arm();@(negedge clk);commit_pending=1;edge_clock();check(action==2&&!tripped,"commit floor");
   @(negedge clk);commit_pending=0;committed=1;active_id=2;edge_clock();check(action==2,"await new model");
   @(negedge clk);committed=0;decision_valid=1;decision_model=1;edge_clock();check(dut.awaiting,"old model cannot refresh");
   @(negedge clk);decision_model=2;edge_clock();@(negedge clk);decision_valid=0;edge_clock();check(!dut.awaiting&&action==0,"new model releases floor");active_id=1;decision_model=1;
   fresh_arm();@(negedge clk);pipe_busy=1;clear_request=1;edge_clock();check(!clear_ok,"clear refused with pipeline busy");pipe_busy=0;clear_request=0;
   fresh_arm();@(negedge clk);disarm=1;edge_clock();check(!armed&&action==3,"disarm STOP");disarm=0;
   $display("ALL SAFETY TESTS PASSED: %0d directed race/priority/boundary checks.",checks);
   begin integer f;f=$fopen(PASS_FILE,"w");$fdisplay(f,"PASS checks=%0d",checks);$fclose(f);end
   $finish;
 end
endmodule
