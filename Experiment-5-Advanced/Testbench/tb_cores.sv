`timescale 1ns/1ps
module tb_cores;
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
 task check(input bit okay,input string msg);
   if(!okay) $fatal(1,"CORE FAIL: %s at cycle %0d",msg,cycle);
 endtask
 always @(posedge clk) begin
   cycle=cycle+1;
   if(pa) stamps[sid]=cycle;
   #1;
   if(phase==1&&pv) begin
     check({1'b0,ps,ph,psc,pmar,pc}===golden[ps],$sformatf("stream scores vector %04x",ps));
     check(pm==mid,"stream model tag");check(cycle-stamps[ps]==5,"stream latency");stream_count=stream_count+1;
   end
 end
 initial begin : main
   integer count,expected;logic [15:0] enc;
   hw=0;ow=0;ts=0;bs=0;
   for(int pat=0;pat<65536;pat++) begin
     expected=0;for(int k=0;k<16;k++) expected=expected+((pat>>k)&1);
     check(pop16(16'(pat))==expected,"exhaustive popcount");
     check(legal_raw(16'(pat))==((pat&15)<=4&&((pat>>4)&15)<=4&&((pat>>8)&15)<=4&&((pat>>12)&15)<=4),"raw legality");
     if(legal_raw(16'(pat))) begin
       enc=encode_raw(16'(pat));
       for(int f=0;f<4;f++) for(int k=0;k<4;k++) check(enc[f*4+k]==(((pat>>(4*f))&15)>k),"encoding");
     end
   end
   for(int pop=0;pop<=16;pop++) for(int bias=-128;bias<=127;bias++)
     check($signed(score16(5'(pop),8'(bias)))==2*pop-16+bias,"score width extrema");
   check(decide({9'sd1,9'sd1,9'sd1,9'sd1})==11'd3,"tie picks STOP and zero margin");
   check(decide({9'sd143,-9'sd144,-9'sd144,-9'sd144})=={9'd287,2'd3},"maximal margin");
   for(int profile=0;profile<2;profile++) begin
     phase=0;rst=1;pa=0;sa=0;repeat(3) @(negedge clk);
     if(profile==0) begin
       $readmemh({DATA_DIR,"/Models/normal.mem"},words);$readmemh({DATA_DIR,"/Data/normal_golden.mem"},golden);
     end else begin
       $readmemh({DATA_DIR,"/Models/cautious.mem"},words);$readmemh({DATA_DIR,"/Data/cautious_golden.mem"},golden);
     end
     for(int j=0;j<16;j++) begin hw[j*16+:16]=words[j];ts[j*5+:5]=words[20+j][4:0];end
     for(int j=0;j<4;j++) begin ow[j*16+:16]=words[16+j];bs[j*8+:8]=words[36+j][7:0];end
     mid=words[40];rst=0;phase=1;count=stream_count;
     for(int i=0;i<65536;i++) begin @(negedge clk);pa=1;x=16'(i);sid=16'(i);end
     @(negedge clk);pa=0;repeat(7) @(negedge clk);
     check(stream_count-count==65536,"stream output count/II=1");phase=0;
     $display("PARALLEL PASS profile %0d: 65536 vectors, latency 5, II 1",profile);
     for(int i=0;i<65536;i++) begin
       @(negedge clk);check(!sb,"folded ready");x=16'(i);sid=16'(i);sa=1;
       @(negedge clk);sa=0;
       for(int n=1;n<=21;n++) begin
         @(posedge clk);#2;
         if(n<21) check(!sv,"folded no early result");
         else begin
           check(sv,"folded exact 21-cycle latency");
           check({1'b0,ss,sh,ssc,smar,sc}===golden[i],$sformatf("folded vector %04x",i));
           check(sm==mid,"folded model tag");total_folded=total_folded+1;
         end
       end
     end
     $display("FOLDED PASS profile %0d: 65536 vectors, latency 21, II 22",profile);
   end
   // Reset cancels every possible parallel/folded occupancy.
   for(int stage=0;stage<22;stage++) begin
     @(negedge clk);pa=1;sa=1;x=0;sid=0;
     @(negedge clk);pa=0;sa=0;repeat(stage) @(negedge clk);
     rst=1;@(negedge clk);rst=0;repeat(23) begin @(negedge clk);check(!pv&&!sv,"reset flush");end
   end
   $display("ALL CORE TESTS PASSED: %0d parallel + %0d folded golden vectors; 65536 popcounts; 4352 score extremes; reset/latency/encoding.",stream_count,total_folded);
   begin integer f;f=$fopen(PASS_FILE,"w");$fdisplay(f,"PASS parallel=131072 folded=131072 latency=5/21 II=1/22");$fclose(f);end
   $finish;
 end
 initial begin #100000000; $fatal(1,"Core test timeout");end
endmodule
