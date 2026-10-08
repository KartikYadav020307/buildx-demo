`timescale 1ns/1ps
module tb_config;
 parameter PASS_FILE="CONFIG_TEST_PASS.txt";
 logic clk=0;always #10 clk=~clk;
 logic rst=1,start=0,bank=0,cores_busy=0;logic [2:0] command=0;logic [5:0] address=0;logic [15:0] data=0;
 logic busy,done,active_valid,active_bank,committing,committed;logic [7:0] status;logic [15:0] readback,active_id;
 logic [8:0] min_margin;logic [255:0] hw;logic [63:0] ow;logic [79:0] thresholds;logic [31:0] biases,seal_cycles,commit_cycles;
 logic [15:0] words[0:1][0:41];integer seed=32'h12340578,checks=0;
 bnn_config dut(.*);
 task check(input bit ok,input string msg);checks++;if(!ok)$fatal(1,"CONFIG FAIL %s",msg);endtask
 function automatic logic [15:0] image_crc(input bit b);
   logic [15:0] c;logic [23:0] stream;c=16'hffff;
   for(int a=0;a<42;a++)begin stream={8'(a),words[b][a]};for(int k=23;k>=0;k--)c={c[14:0],1'b0}^((c[15]^stream[k])?16'h1021:16'h0);end
   return c;
 endfunction
 task cmd(input logic [2:0] c,input logic bk,input logic [5:0] a,input logic [15:0] w,input logic [7:0] e);
   @(negedge clk);command=c;bank=bk;address=a;data=w;start=1;
   @(posedge clk);#2;@(negedge clk);start=0;
   while(!done)begin @(posedge clk);#2;end
   check(status==e,$sformatf("cmd %0d status %0d/%0d",c,status,e));
 endtask
 task load(input bit b);
   cmd(1,b,0,0,0);
   for(int a=0;a<42;a++)cmd(2,b,6'(a),words[b][a],0);
   // Duplicate writes replace data and keep completeness.
   cmd(2,b,0,words[b][0],0);cmd(4,b,0,image_crc(b),0);check(seal_cycles==1008,"seal cycle count");
 endtask
 initial begin
   for(int b=0;b<2;b++)for(int a=0;a<42;a++)begin
     if(a<20)words[b][a]=16'($urandom(seed));
     else if(a<36)words[b][a]=16'($urandom(seed)%18);
     else if(a<40)begin words[b][a]=16'($urandom(seed));words[b][a]={{8{words[b][a][7]}},words[b][a][7:0]};end
     else if(a==40)words[b][a]=16'(b+1);else words[b][a]=16'($urandom(seed)%288);
   end
   repeat(3)@(negedge clk);rst=0;load(0);load(1);cmd(5,0,0,0,0);
   // Every possible occupancy of the 5-cycle parallel and 21-cycle folded cores.
   for(int delay=0;delay<=21;delay++)begin
     @(negedge clk);cores_busy=1;command=5;bank=~active_bank;start=1;
     @(posedge clk);#2;check(committing&&!done,"commit blocks acceptance");
     @(negedge clk);start=0;if(delay==0)cores_busy=0;
     repeat(delay)begin @(posedge clk);#2;check(!done&&active_bank!=bank,"no switch while occupied");end
     if(delay!=0)begin @(negedge clk);cores_busy=0;end
     @(posedge clk);#2;
     check(done&&committed&&active_bank==bank&&active_id==words[bank][40],"atomic bank/ID switch");
     check(commit_cycles==delay+1,"measured drain budget");
     cmd(2,active_bank,0,0,1);
   end
   // Corrupt seals, begin/abort, readback and reset partway through the checker.
   for(int n=0;n<8;n++)begin
     load(~active_bank);cmd(1,~active_bank,0,0,0);cmd(3,~active_bank,0,0,2);
     for(int a=0;a<42;a++)cmd(2,~active_bank,6'(a),words[~active_bank][a],0);
     cmd(4,~active_bank,0,image_crc(~active_bank)^16'h0080,4);check(active_valid,"failed inactive seal leaves active valid");
     cmd(4,~active_bank,0,image_crc(~active_bank),0);cmd(6,~active_bank,0,0,0);cmd(5,~active_bank,0,0,5);
   end
   cmd(1,~active_bank,0,0,0);for(int a=0;a<42;a++)cmd(2,~active_bank,6'(a),words[~active_bank][a],0);
   @(negedge clk);command=4;bank=~active_bank;data=image_crc(bank);start=1;
   @(negedge clk);start=0;repeat(17)@(negedge clk);rst=1;@(negedge clk);rst=0;
   repeat(10)@(negedge clk);check(!active_valid&&!busy&&!done,"reset during seal invalidates models and transaction");
   $display("ALL CONFIG TESTS PASSED: %0d checks, occupancy 0..21, duplicate writes, random images, CRC rejection, abort and mid-seal reset.",checks);
   begin integer f;f=$fopen(PASS_FILE,"w");$fdisplay(f,"PASS checks=%0d occupancies=22",checks);$fclose(f);end
   $finish;
 end
 initial begin #3000000;$fatal(1,"Configuration test timeout");end
endmodule
