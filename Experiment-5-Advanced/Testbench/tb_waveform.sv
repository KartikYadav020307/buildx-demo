`timescale 1ns/1ps
module tb_waveform;
 parameter PASS_FILE="CORE_TEST_PASS.txt";
 parameter DATA_DIR=".";
 import bnn_math_pkg::*;
 logic clk=0;always #10 clk=~clk;
 logic rst=1,pa=0,sa=0;logic [15:0] x=0,sid=0,mid=1;
 logic [255:0] hw;logic [63:0] ow;logic [79:0] ts;logic [31:0] bs;
 logic pb,pv,prv,sb,sv;logic [35:0] psc,prsc,ssc;logic [15:0] ph,prh,sh,ps,prs,ss,pm,prm,sm;
 logic [1:0] pc,prc,sc;logic [8:0] pmar,prmar,smar;
 logic [79:0] golden[0:65535];logic [15:0] words[0:41];
 integer cycle=0,phase=0,stream_count=0,total_folded=0;integer stamps[0:65535];
 bnn_parallel p(.clk,.rst,.accept(pa),.x,.sample_id(sid),.model_id(mid),.hw,.ow,.thresholds(ts),.biases(bs),
 .busy(pb),.pre_valid(prv),.pre_scores(prsc),.pre_hidden(prh),.pre_sample(prs),.pre_model(prm),.pre_class(prc),.pre_margin(prmar),
 .valid(pv),.scores(psc),.hidden(ph),.out_sample(ps),.out_model(pm),.out_class(pc),.margin(pmar));
 bnn_folded s(.clk,.rst,.accept(sa),.x,.sample_id(sid),.model_id(mid),.hw,.ow,.thresholds(ts),.biases(bs),
 .busy(sb),.valid(sv),.scores(ssc),.hidden(sh),.out_sample(ss),.out_model(sm),.out_class(sc),.margin(smar));

 logic [15:0] raw_case=0;
 logic [15:0] raw_cases[0:5];
 integer fd;
 always @(posedge clk) cycle=cycle+1;
 task check(input bit okay,input string msg);
   if(!okay) $fatal(1,"WAVEFORM FAIL: %s at cycle %0d",msg,cycle);
 endtask
 initial begin : trace
   integer stamp; time accept_time,p_time,f_time;
   $timeformat(-9,0,"",0);
   $dumpfile("waveform.vcd");
   $dumpvars(0,clk,rst,pa,sa,raw_case,x,mid,pv,sv,pc,sc,pm,sm,psc,ssc,pb,sb);
   fd=$fopen("waveform_measurements.csv","w");
   $fdisplay(fd,"profile,raw_hex,encoded_hex,model_id,accept_ns,parallel_valid_ns,folded_valid_ns,parallel_class,folded_class,parallel_cycles,folded_cycles");
   raw_cases[0]=16'h0000;raw_cases[1]=16'h0111;raw_cases[2]=16'h0222;
   raw_cases[3]=16'h0233;raw_cases[4]=16'h2233;raw_cases[5]=16'h0024;
   hw=0;ow=0;ts=0;bs=0;
   for(int profile=0;profile<2;profile++) begin
     rst=1;pa=0;sa=0;repeat(3) @(negedge clk);
     if(profile==0) begin
       $readmemh({DATA_DIR,"/Models/normal.mem"},words);
       $readmemh({DATA_DIR,"/Data/normal_golden.mem"},golden);
     end else begin
       $readmemh({DATA_DIR,"/Models/cautious.mem"},words);
       $readmemh({DATA_DIR,"/Data/cautious_golden.mem"},golden);
     end
     for(int j=0;j<16;j++) begin hw[j*16+:16]=words[j];ts[j*5+:5]=words[20+j][4:0];end
     for(int j=0;j<4;j++) begin ow[j*16+:16]=words[16+j];bs[j*8+:8]=words[36+j][7:0];end
     mid=words[40];rst=0;
     for(int k=0;k<6;k++) begin
       @(negedge clk);raw_case=raw_cases[k];x=encode_raw(raw_case);sid=16'(k);pa=1;sa=1;
       @(posedge clk);#2;stamp=cycle;accept_time=$time;
       @(negedge clk);pa=0;sa=0;
       for(int n=1;n<=21;n++) begin
         @(posedge clk);#2;
         check(pv===(n==5),"parallel exact valid pulse");
         check(sv===(n==21),"folded exact valid pulse");
         if(n==5) begin
           p_time=$time;
           check({1'b0,x,ph,psc,pmar,pc}===golden[x],"parallel golden match");
           check(pm==mid&&cycle-stamp==5,"parallel tag and latency");
         end
         if(n==21) begin
           f_time=$time;
           check({1'b0,x,sh,ssc,smar,sc}===golden[x],"folded golden match");
           check(sm==mid&&cycle-stamp==21,"folded tag and latency");
         end
       end
       $fdisplay(fd,"%s,%04x,%04x,%0d,%0t,%0t,%0t,%0d,%0d,5,21",profile==0?"normal":"cautious",raw_case,x,mid,accept_time,p_time,f_time,pc,sc);
       $display("TRACE PASS profile=%0d raw=%04x class=%0d/%0d cycles=5/21",profile,raw_case,pc,sc);
       repeat(3) @(negedge clk);
     end
   end
   $fclose(fd);$display("WAVEFORM TRACE PASS: 12 cases, independent golden matches, model tags, exact 5/21-cycle latency.");$finish;
 end
endmodule
