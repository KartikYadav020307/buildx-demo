`timescale 1ns/1ps
module tb_diagnostics;
 parameter PASS_FILE="DIAGNOSTIC_TEST_PASS.txt";
 import bnn_math_pkg::*;
 logic clk=0;always #10 clk=~clk;
 logic rst=1,accept=0;logic [15:0] x=0,sid=0,mid=16'hbabe;
 logic [255:0] hw=0;logic [63:0] ow=0;logic [79:0] ts=0;logic [31:0] bs=0;
 logic pb,pv,prv,sb,sv;logic [35:0] ps,prs,ss;logic [15:0] ph,prh,sh,pid,prid,sidout,pm,prm,sm;
 logic [1:0] pc,prc,sc;logic [8:0] pmar,prmar,smar;
 integer seed=32'h55aa1144;integer checks=0;
 bnn_parallel p(.clk,.rst,.accept,.x,.sample_id(sid),.model_id(mid),.hw,.ow,.thresholds(ts),.biases(bs),
 .busy(pb),.pre_valid(prv),.pre_scores(prs),.pre_hidden(prh),.pre_sample(prid),.pre_model(prm),.pre_class(prc),.pre_margin(prmar),
 .valid(pv),.scores(ps),.hidden(ph),.out_sample(pid),.out_model(pm),.out_class(pc),.margin(pmar));
 bnn_folded s(.clk,.rst,.accept,.x,.sample_id(sid),.model_id(mid),.hw,.ow,.thresholds(ts),.biases(bs),
 .busy(sb),.valid(sv),.scores(ss),.hidden(sh),.out_sample(sidout),.out_model(sm),.out_class(sc),.margin(smar));
 task check(input bit ok,input string msg);checks++;if(!ok)$fatal(1,"DIAGNOSTIC FAIL %s",msg);endtask
 initial begin
   logic [15:0] hgold;logic [35:0] sgold;integer score[0:3],dot,pop,bias,best,second,cls;
   repeat(3)@(negedge clk);rst=0;
   for(int n=0;n<1024;n++) begin
     @(negedge clk);x=16'($urandom(seed));sid=16'(n);
     for(int j=0;j<16;j++) begin hw[j*16+:16]=16'($urandom(seed));ts[j*5+:5]=5'($urandom(seed)%18);end
     for(int j=0;j<4;j++) begin ow[j*16+:16]=16'($urandom(seed));bs[j*8+:8]=8'($urandom(seed));end
     if(n==0)begin hw=0;ts=0;ow=0;bs={8'h7f,8'h80,8'h80,8'h80};x=16'hffff;end
     if(n==1)begin hw=0;ts={16{5'd17}};ow=0;bs=0;x=0;end
     hgold=0;
     for(int j=0;j<16;j++)begin
       pop=0;for(int k=0;k<16;k++)pop+=(x[k]==hw[j*16+k]);hgold[j]=(pop>=ts[j*5+:5]);
     end
     for(int j=0;j<4;j++)begin
       dot=0;for(int k=0;k<16;k++)dot+=(hgold[k]?1:-1)*(ow[j*16+k]?1:-1);
       bias=$signed(bs[j*8+:8]);score[j]=dot+bias;sgold[j*9+:9]=9'(score[j]);
     end
     cls=0;best=score[0];second=-256;
     for(int j=1;j<4;j++)if(score[j]>=best)begin second=best;best=score[j];cls=j;end else if(score[j]>second)second=score[j];
     accept=1;@(negedge clk);accept=0;
     for(int t=1;t<=21;t++)begin
       @(posedge clk);#2;
       if(t==5)begin check(pv&&ph===hgold&&ps===sgold,"random parallel arithmetic");check(pc==cls&&pmar==best-second,"parallel signed argmax");end
       if(t==21)begin check(sv&&sh===hgold&&ss===sgold,"random folded arithmetic");check(sc==cls&&smar==best-second,"folded signed argmax");end
     end
   end
   $display("ALL DIAGNOSTIC TESTS PASSED: 1024 arbitrary parameter/input images including extrema and ties; %0d checks.",checks);
   begin integer f;f=$fopen(PASS_FILE,"w");$fdisplay(f,"PASS random_images=1024 checks=%0d",checks);$fclose(f);end
   $finish;
 end
endmodule
