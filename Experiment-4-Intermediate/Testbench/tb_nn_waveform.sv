`timescale 1ns/1ps
// Supplementary waveform capture. Frozen expected scores come from iris_cases.csv.
module tb_nn_waveform;
    reg clk=0, rst=1, cmd=0;
    reg [31:0] features=0;
    always #10 clk=~clk;
    wire busy,done,mismatch;
    wire [1:0] parallel_class,serial_class;
    wire [7:0] parallel_cycles,serial_cycles;
    wire [31:0] completed_count;
    wire signed [31:0] score0,score1,score2;
    nn_demo_controller d(clk,rst,cmd,features,busy,done,mismatch,
        parallel_class,serial_class,parallel_cycles,serial_cycles,
        completed_count,score0,score1,score2);
    integer cycle=0,accepted=0,expected_count=0;
    reg [1:0] expected_class;
    reg signed [31:0] e0,e1,e2;
    always @(posedge clk) begin
        cycle=cycle+1;
        if (!rst && d.launch) accepted=cycle;
        #1;
        if (!rst && d.pv) begin
            if (cycle-accepted != 4 || d.pc != expected_class ||
                d.p0 !== e0 || d.p1 !== e1 || d.p2 !== e2)
                $fatal(1,"Parallel waveform result/latency mismatch");
            $display("Parallel core result at %0t: class=%0d latency=%0d cycles",$time,d.pc,cycle-accepted);
        end
        if (!rst && d.sv) begin
            if (cycle-accepted != 36 || d.sc != expected_class ||
                d.s0 !== e0 || d.s1 !== e1 || d.s2 !== e2)
                $fatal(1,"Serial waveform result/latency mismatch");
            $display("Serial core result at %0t: class=%0d latency=%0d cycles",$time,d.sc,cycle-accepted);
        end
    end
    task automatic run_case(input [31:0] word,input [1:0] cls,
        input signed [31:0] a,b,c);
        integer age;
        begin
            @(negedge clk);
            features=word; expected_class=cls; e0=a; e1=b; e2=c;
            cmd=~cmd; expected_count=expected_count+1;
            @(negedge clk); age=0;
            while (!done && age<45) begin @(negedge clk); age=age+1; end
            if (!done || busy || mismatch || completed_count != expected_count ||
                parallel_cycles != 4 || serial_cycles != 36 ||
                parallel_class != cls || serial_class != cls ||
                score0 !== a || score1 !== b || score2 !== c)
                $fatal(1,"Controller waveform mismatch for %h",word);
            $display("PASS demo %h: class=%0d scores=%0d,%0d,%0d cycles=4,36 count=%0d",word,cls,a,b,c,completed_count);
            repeat(8) @(negedge clk);
        end
    endtask
    initial begin
        $dumpfile("Simulation/waveform.vcd");
        $dumpvars(0,clk,rst,cmd,features,busy,done,mismatch,
            parallel_class,serial_class,parallel_cycles,serial_cycles,
            completed_count,score0,score1,score2,d.launch,d.pv,d.sv,d.pc,d.sc);
        repeat(4) @(negedge clk); rst=0;
        run_case(32'hd6d528e0,0,19058,2857,-24757);
        run_case(32'h09110b2a,1,-8102,8917,-3790);
        run_case(32'h37281210,2,-13784,-6177,16696);
        $display("WAVEFORM TEST PASS: 3 cases; exact scores; 4/36 cycle latency");
        $finish;
    end
    initial begin #10000; $fatal(1,"Waveform test timeout"); end
endmodule
