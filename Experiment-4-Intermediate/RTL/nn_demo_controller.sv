`timescale 1ns/1ps
// Sticky results make nanosecond computations visible over slow JTAG/VIO.
// Toggle cmd_toggle only while busy=0. One toggle creates exactly one request.
module nn_demo_controller (
    input wire clk, input wire rst,
    input wire cmd_toggle, input wire [31:0] features,
    output reg busy, output reg done, output reg mismatch,
    output reg [1:0] parallel_class, serial_class,
    output reg [7:0] parallel_cycles, serial_cycles,
    output reg [31:0] completed_count,
    output reg signed [31:0] score0,score1,score2
);
    reg toggle_previous;
    reg [7:0] age;
    wire serial_ready;
    wire launch = (cmd_toggle != toggle_previous) && !busy && serial_ready && !rst;
    wire pv,sv;
    wire [1:0] pc,sc;
    wire signed [31:0] p0,p1,p2,s0,s1,s2;
    nn_parallel u_parallel(clk,rst,launch,features,pv,pc,p0,p1,p2);
    nn_serial u_serial(clk,rst,launch,features,serial_ready,sv,sc,s0,s1,s2);
    always @(posedge clk) begin
        if (rst) begin
            toggle_previous <= cmd_toggle;
            busy <= 0; done <= 0; mismatch <= 0; age <= 0;
            parallel_class <= 0; serial_class <= 0;
            parallel_cycles <= 0; serial_cycles <= 0; completed_count <= 0;
            score0 <= 0; score1 <= 0; score2 <= 0;
        end else begin
            toggle_previous <= cmd_toggle;
            if (launch) begin
                busy <= 1; done <= 0; mismatch <= 0; age <= 0;
            end else if (busy) age <= age+1'b1;
            if (pv && busy) begin
                parallel_cycles <= age; parallel_class <= pc;
                score0 <= p0; score1 <= p1; score2 <= p2;
            end
            if (sv && busy) begin
                serial_cycles <= age; serial_class <= sc;
                mismatch <= (parallel_class != sc) || (score0 != s0) || (score1 != s1) || (score2 != s2);
                done <= 1; busy <= 0; completed_count <= completed_count+1'b1;
            end
        end
    end
endmodule
