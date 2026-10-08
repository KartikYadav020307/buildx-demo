`timescale 1ns/1ps
package bnn_math_pkg;
  function automatic logic [4:0] pop16(input logic [15:0] x);
    logic [1:0] a[0:7]; logic [2:0] b[0:3]; logic [3:0] c[0:1];
    for (int i=0;i<8;i++) a[i]={1'b0,x[2*i]}+{1'b0,x[2*i+1]};
    for (int i=0;i<4;i++) b[i]={1'b0,a[2*i]}+{1'b0,a[2*i+1]};
    for (int i=0;i<2;i++) c[i]={1'b0,b[2*i]}+{1'b0,b[2*i+1]};
    return {1'b0,c[0]}+{1'b0,c[1]};
  endfunction
  function automatic logic signed [8:0] score16(input logic [4:0] p,input logic [7:0] bias);
    logic signed [8:0] pp,bb;
    pp=$signed({4'b0,p}); bb=$signed({bias[7],bias});
    return (pp <<< 1)-9'sd16+bb;
  endfunction
  // {margin[8:0], class[1:0]}; greatest index wins ties.
  function automatic logic [10:0] decide(input logic [35:0] scores);
    logic signed [8:0] best,second,s;
    logic signed [9:0] difference; logic [1:0] cls;
    best=$signed(scores[8:0]); second=9'sh100; cls=0;
    for (int i=1;i<4;i++) begin
      s=$signed(scores[i*9+:9]);
      if (s>=best) begin second=best; best=s; cls=2'(i); end
      else if (s>second) second=s;
    end
    difference=$signed({best[8],best})-$signed({second[8],second});
    return {difference[8:0],cls};
  endfunction
  function automatic logic legal_raw(input logic [15:0] raw);
    return raw[3:0]<=4 && raw[7:4]<=4 && raw[11:8]<=4 && raw[15:12]<=4;
  endfunction
  function automatic logic [15:0] encode_raw(input logic [15:0] raw);
    logic [15:0] x;
    for (int f=0;f<4;f++) for (int k=0;k<4;k++) x[f*4+k]=(raw[f*4+:4]>4'(k));
    return x;
  endfunction
  function automatic logic critical_raw(input logic [15:0] raw);
    return (raw[3:0]==4) && ((raw[7:4]>=2)||(raw[11:8]>=2));
  endfunction
  function automatic logic [15:0] crc_bit(input logic [15:0] crc,input logic b);
    return {crc[14:0],1'b0} ^ ((crc[15]^b) ? 16'h1021 : 16'h0000);
  endfunction
endpackage
