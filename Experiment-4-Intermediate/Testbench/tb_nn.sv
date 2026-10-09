`timescale 1ns/1ps
`include "vector_count.vh"
// Four modes, run concurrently: streamed parallel, serial, wrapper, reset aborts.
// Golden file contains Python-computed integer scores, not RTL-derived expectations.
module tb_nn;
    parameter GOLDEN_FILE = "golden_vectors.mem";
    parameter PASS_FILE = "nn_simulation_pass.flag";
    reg clk=0;
    always #10 clk=~clk;
    reg [129:0] golden [0:`VECTOR_COUNT-1];
    reg rst=1;
    reg pin=0;
    reg [31:0] px=0;
    wire pv;
    wire [1:0] pc;
    wire signed [31:0] p0,p1,p2;
    nn_parallel p(clk,rst,pin,px,pv,pc,p0,p1,p2);
    reg sin=0;
    reg [31:0] sx=0;
    wire sr,sv;
    wire [1:0] sc;
    wire signed [31:0] s0,s1,s2;
    nn_serial s(clk,rst,sin,sx,sr,sv,sc,s0,s1,s2);
    reg drst=1,cmd=0;
    reg [31:0] dx=0;
    wire busy,done,mismatch;
    wire [1:0] dc,dsc;
    wire [7:0] dpcycles,dscycles;
    wire [31:0] count;
    wire signed [31:0] d0,d1,d2;
    nn_demo_controller d(clk,drst,cmd,dx,busy,done,mismatch,dc,dsc,dpcycles,dscycles,count,d0,d1,d2);
    integer cyc=0;
    integer p_sent=0,p_got=0;
    integer acceptance_cycle[0:`VECTOR_COUNT-1];
    reg p_finished=0,s_finished=0,d_finished=0;
    // Dedicated cores for reset-abort test; avoid disturbing the streaming scoreboard.
    reg rrst=1,rin=0; reg [31:0] rx=0;
    wire rpv,rsv,rsr;
    wire [1:0] rpc,rsc;
    wire signed [31:0] rp0,rp1,rp2,rs0,rs1,rs2;
    reg r_finished=0;
    nn_parallel rp(clk,rrst,rin,rx,rpv,rpc,rp0,rp1,rp2);
    nn_serial rs(clk,rrst,rin,rx,rsr,rsv,rsc,rs0,rs1,rs2);

    task automatic check_output(input integer idx,input [1:0] c,
        input signed [31:0] a,input signed [31:0] b,input signed [31:0] e);
        begin
            if ({c,e,b,a} !== golden[idx][129:32])
                $fatal(1,"vector %0d mismatch class=%0d scores=%0d,%0d,%0d expected=%h",idx,c,a,b,e,golden[idx][129:32]);
        end
    endtask
    initial begin
        $readmemh(GOLDEN_FILE,golden);
        if (^golden[0] === 1'bx || ^golden[`VECTOR_COUNT-1] === 1'bx)
            $fatal(1,"Golden data missing. Check GOLDEN_FILE / memory file location.");
        repeat(4) @(negedge clk);
        rst=0; drst=0; rrst=0;
    end
    // Sample accepted inputs before NBA, check output after NBA.
    always @(posedge clk) begin
        cyc=cyc+1;
        if (!rst && pin) begin
            acceptance_cycle[p_sent]=cyc; p_sent=p_sent+1;
        end
        #1;
        if (!rst && pv) begin
            check_output(p_got,pc,p0,p1,p2);
            if (cyc-acceptance_cycle[p_got] != 4) $fatal(1,"Parallel latency not four periods");
            p_got=p_got+1;
        end
    end
    initial begin : stream_parallel
        integer k;
        wait(!rst);
        for (k=0;k<`VECTOR_COUNT;k=k+1) begin
            @(negedge clk); pin=1; px=golden[k][31:0];
            if (k%17 == 16) begin @(negedge clk); pin=0; end
        end
        @(negedge clk); pin=0;
        repeat(7) @(negedge clk);
        if (p_got != `VECTOR_COUNT) $fatal(1,"Lost parallel outputs");
        p_finished=1;
        $display("PASS parallel: %0d vectors, full-rate bursts + bubbles, latency=4 periods",p_got);
    end
    initial begin : serial_vectors
        integer k,age,start_cycle;
        wait(!rst);
        for (k=0;k<`VECTOR_COUNT;k=k+1) begin
            @(negedge clk);
            if (!sr) $fatal(1,"Serial core unexpectedly not ready");
            sx=golden[k][31:0]; sin=1;
            @(posedge clk); start_cycle=cyc; #2;
            @(negedge clk); sin=0; age=0;
            // Change external data immediately: accepted sample must be latched.
            sx=~golden[k][31:0];
            while (!sv && age<45) begin @(negedge clk); age=age+1; end
            if (!sv || age != 36) $fatal(1,"Serial latency=%0d, expected 36",age);
            check_output(k,sc,s0,s1,s2);
        end
        s_finished=1;
        $display("PASS serial: %0d vectors, input latching, latency=36 periods",`VECTOR_COUNT);
    end
    initial begin : wrapper_vectors
        integer k,age;
        wait(!drst);
        for (k=0;k<150;k=k+1) begin
            @(negedge clk); dx=golden[k][31:0]; cmd=~cmd;
            @(negedge clk); age=0;
            while (!done && age<45) begin @(negedge clk); age=age+1; end
            if (!done || busy || mismatch || count != k+1 || dpcycles != 4 || dscycles != 36)
                $fatal(1,"Wrapper status/counters incorrect k=%0d p=%0d s=%0d count=%0d",k,dpcycles,dscycles,count);
            check_output(k,dc,d0,d1,d2);
            if (dc != dsc) $fatal(1,"Wrapper classes differ");
            repeat(4) @(negedge clk);
            if (count != k+1 || !done) $fatal(1,"Held toggle retriggers / result not sticky");
        end
        // A toggle while busy must not queue another operation.
        @(negedge clk); dx=golden[0][31:0]; cmd=~cmd;
        repeat(3) @(negedge clk); cmd=~cmd;
        repeat(45) @(negedge clk);
        if (count != 151 || mismatch) $fatal(1,"Busy command handling failed");
        // Reset cancels a command in flight and resets sticky state.
        cmd=~cmd; repeat(3) @(negedge clk); drst=1;
        repeat(3) @(negedge clk); drst=0;
        repeat(45) @(negedge clk);
        if (count != 0 || done || busy) $fatal(1,"Wrapper reset abort failed");
        dx=golden[100][31:0]; cmd=~cmd;
        repeat(40) @(negedge clk);
        check_output(100,dc,d0,d1,d2);
        if (count != 1 || mismatch || dpcycles != 4 || dscycles != 36) $fatal(1,"Wrapper recovery failed");
        d_finished=1;
        $display("PASS wrapper: 150 Iris samples, held toggle, busy rejection, reset abort, counters");
    end
    initial begin : reset_tests
        integer n;
        wait(!rrst);
        @(negedge clk); rin=1; rx=golden[0][31:0];
        @(negedge clk); rin=0;
        @(negedge clk); rrst=1;
        repeat(3) @(negedge clk); rrst=0;
        repeat(40) begin
            @(negedge clk);
            if (rpv || rsv) $fatal(1,"Output leaked after reset abort");
        end
        rin=1; rx=golden[50][31:0];
        @(negedge clk); rin=0;
        n=0;
        repeat(40) begin
            @(negedge clk);
            if (rpv) begin check_output(50,rpc,rp0,rp1,rp2); n=n+1; end
            if (rsv) begin check_output(50,rsc,rs0,rs1,rs2); n=n+1; end
        end
        if (n != 2) $fatal(1,"Recovery output missing");
        // Deterministic argmax ties: lower index wins.
        if (rp.nn_argmax(0,0,0) != 0 || rp.nn_argmax(-5,3,3) != 1 || rp.nn_argmax(-5,-5,3) != 2)
            $fatal(1,"Argmax tie rule failed");
        if (rp.nn_relu(-1) != 0 || rp.nn_relu(32'sh7fffffff) != 32767) $fatal(1,"ReLU saturation failed");
        r_finished=1;
        $display("PASS reset abort/recovery, argmax ties, ReLU saturation");
    end
    integer pass_handle;
    initial begin
        wait(p_finished && s_finished && d_finished && r_finished);
        pass_handle = $fopen(PASS_FILE,"w");
        if (pass_handle == 0) $fatal(1,"Cannot write simulation pass marker");
        $fdisplay(pass_handle,"ALL TESTS PASSED");
        $fclose(pass_handle);
        $display("ALL TESTS PASSED");
        $finish;
    end
    initial begin
        #5000000;
        $fatal(1,"Global simulation timeout");
    end
endmodule
