`timescale 1ns/1ps
module tb_aes_repair;
reg clk=0;
always #4 clk=~clk; // Same 125 MHz clock as hardware constraints.
reg reset=1, start=0;
reg [127:0] plaintext=0, key=0;
wire [127:0] ciphertext, original_ciphertext;
wire done, original_done;
aes_core dut(clk,reset,start,plaintext,key,ciphertext,done);
aes_core_original original(clk,reset,start,plaintext,key,original_ciphertext,original_done);
reg [127:0] vectors [0:311];
integer i, cycles, completions;
reg [127:0] expected;
// Check exact cycle-by-cycle equivalence, including reset and held start.
always @(posedge clk) begin
 #1;
 if (done !== original_done || ciphertext !== original_ciphertext)
  $fatal(1,"Original/repaired outputs differ at time %t",$time);
end
task run_vector(input integer n);
begin
 @(negedge clk); key=vectors[3*n]; plaintext=vectors[3*n+1];
 expected=vectors[3*n+2]; start=1;
 @(posedge clk); #2;
 @(negedge clk); start=0;
 cycles=0;
 while (done !== 1'b1 && cycles<30) begin
  @(posedge clk); #2; cycles=cycles+1;
 end
 if (cycles!=21 || done!==1 || ciphertext!==expected)
  $fatal(1,"Vector %0d failed: cycles=%0d actual=%h expected=%h",n,cycles,ciphertext,expected);
 @(posedge clk); #2;
 if(done!==0 || ciphertext!==expected) $fatal(1,"Pulse/retention failed");
end
endtask
initial begin
 $readmemh("Testbench/vectors.mem",vectors);
 #17; reset=0;
 for(i=0;i<104;i=i+1) run_vector(i);
 // Inputs are captured at start and may change while busy.
 @(negedge clk); key=vectors[0]; plaintext=vectors[1]; start=1;
 @(negedge clk); start=0; key=0; plaintext=0;
 repeat(21) begin @(posedge clk); #2; end
 if(done!==1 || ciphertext!==vectors[2]) $fatal(1,"Busy input capture failed");
 // Abort midway, clear output, then successfully start again.
 @(negedge clk); start=1;
 @(negedge clk); start=0;
 repeat(5) @(negedge clk);
 #1; reset=1; #1;
 if(done!==0 || ciphertext!==0) $fatal(1,"Asynchronous reset failed");
 @(negedge clk); reset=0;
 run_vector(1);
 // Preserve the existing VIO held-start behavior; it retriggers in IDLE.
 @(negedge clk); key=vectors[0]; plaintext=vectors[1]; start=1;
 completions=0;
 repeat(70) begin
  @(posedge clk); #2;
  if(done) begin
   completions=completions+1;
   if(ciphertext!==vectors[2]) $fatal(1,"Held-start output failed");
  end
 end
 if(completions!=3) $fatal(1,"Held-start completion count failed");
 @(negedge clk); start=0; reset=1;
 #2;
 $display("PASS: 104 independent AES vectors at 125 MHz simulation clock");
 $display("PASS: 21-cycle completion, one-cycle done, retained ciphertext");
 $display("PASS: input capture, mid-encryption reset, restart, held start");
 $display("PASS: cycle-by-cycle original/repaired equivalence throughout");
 $finish;
end
initial begin #100000; $fatal(1,"Simulation timeout"); end
endmodule
