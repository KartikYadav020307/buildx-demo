`timescale 1ns/1ps
module nn_board_top(input wire sysclk,output wire [3:0] led);
    wire clk,locked;
    nn_clk u_clock(.clk_in1(sysclk),.reset(1'b0),.clk_out1(clk),.locked(locked));
    (* ASYNC_REG = "TRUE" *) reg [1:0] lock_reset = 2'b11;
    always @(posedge clk or negedge locked)
        if (!locked) lock_reset <= 2'b11;
        else lock_reset <= {lock_reset[0],1'b0};
    wire control_reset,cmd_toggle;
    wire [31:0] features;
    wire rst = lock_reset[1] | control_reset;
    wire busy,done,mismatch;
    wire [1:0] parallel_class,serial_class;
    wire [7:0] parallel_cycles,serial_cycles;
    wire [31:0] completed_count;
    wire signed [31:0] score0,score1,score2;
    nn_demo_controller u_demo(.clk(clk),.rst(rst),.cmd_toggle(cmd_toggle),.features(features),
        .busy(busy),.done(done),.mismatch(mismatch),.parallel_class(parallel_class),.serial_class(serial_class),
        .parallel_cycles(parallel_cycles),.serial_cycles(serial_cycles),.completed_count(completed_count),
        .score0(score0),.score1(score1),.score2(score2));
    nn_vio u_vio(.clk(clk),
        .probe_out0(control_reset),.probe_out1(cmd_toggle),.probe_out2(features),
        .probe_in0(busy),.probe_in1(done),.probe_in2(mismatch),
        .probe_in3(parallel_class),.probe_in4(serial_class),
        .probe_in5(parallel_cycles),.probe_in6(serial_cycles),
        .probe_in7(score0),.probe_in8(score1),.probe_in9(score2),.probe_in10(completed_count));
    reg [24:0] heartbeat = 0;
    always @(posedge clk) heartbeat <= heartbeat+1'b1;
    assign led[0] = heartbeat[24];
    assign led[1] = done;
    assign led[2] = parallel_class[0];
    assign led[3] = parallel_class[1];
endmodule
