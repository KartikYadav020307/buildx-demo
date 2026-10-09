`timescale 1ns/1ps
// Same trained model and rounding, with one shared multiply-accumulate path.
// Only accept when in_ready is high. E0 acceptance -> E36 output: 36 periods.
module nn_serial (
    input wire clk, input wire rst,
    input wire in_valid, input wire [31:0] features,
    output wire in_ready,
    output reg out_valid, output reg [1:0] class_id,
    output reg signed [31:0] score0, score1, score2
);
    `include "nn_weights.vh"
    `include "nn_math.vh"
    localparam IDLE=0,H_MAC=1,H_STORE=2,O_MAC=3,O_STORE=4,EMIT=5;
    reg [2:0] state;
    reg [1:0] node,term;
    reg signed [7:0] x [0:3];
    reg signed [15:0] hidden [0:3];
    reg signed [31:0] scores [0:2];
    reg signed [31:0] accumulator;
    wire signed [15:0] mac_a = (state == H_MAC) ? {{8{x[term][7]}},x[term]} : hidden[term];
    wire signed [7:0] mac_b = (state == H_MAC) ? nn_w1(node,term) : nn_w2(node,term);
    (* use_dsp = "yes" *) wire signed [23:0] product = mac_a * mac_b;
    assign in_ready = (state == IDLE) && !rst;
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE; node <= 0; term <= 0; accumulator <= 0;
            out_valid <= 0; class_id <= 0; score0 <= 0; score1 <= 0; score2 <= 0;
            for (i=0;i<4;i=i+1) begin x[i] <= 0; hidden[i] <= 0; end
            for (i=0;i<3;i=i+1) scores[i] <= 0;
        end else begin
            out_valid <= 0;
            case (state)
                IDLE: if (in_valid) begin
                    for (i=0;i<4;i=i+1) x[i] <= $signed(features[i*8 +: 8]);
                    node <= 0; term <= 0; accumulator <= nn_b1(0); state <= H_MAC;
                end
                H_MAC: begin
                    accumulator <= accumulator + nn_sx24(product);
                    if (term == 3) state <= H_STORE;
                    else term <= term+1'b1;
                end
                H_STORE: begin
                    hidden[node] <= nn_relu(accumulator); term <= 0;
                    if (node == 3) begin node <= 0; accumulator <= nn_b2(0); state <= O_MAC; end
                    else begin node <= node+1'b1; accumulator <= nn_b1(node+1); state <= H_MAC; end
                end
                O_MAC: begin
                    accumulator <= accumulator + nn_sx24(product);
                    if (term == 3) state <= O_STORE;
                    else term <= term+1'b1;
                end
                O_STORE: begin
                    scores[node] <= accumulator; term <= 0;
                    if (node == 2) state <= EMIT;
                    else begin node <= node+1'b1; accumulator <= nn_b2(node+1); state <= O_MAC; end
                end
                EMIT: begin
                    score0 <= scores[0]; score1 <= scores[1]; score2 <= scores[2];
                    class_id <= nn_argmax(scores[0],scores[1],scores[2]);
                    out_valid <= 1; state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
