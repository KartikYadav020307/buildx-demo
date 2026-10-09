`timescale 1ns/1ps
// 4 -> 4 ReLU -> 3 classifier. Accepts a new input on every clock.
// Input/hidden scale: 32. Weight scale: 64. Raw output scale: 2048.
// An input sampled at edge E0 produces out_valid at E4: 4 clock periods.
module nn_parallel (
    input wire clk, input wire rst,
    input wire in_valid, input wire [31:0] features,
    output reg out_valid, output reg [1:0] class_id,
    output reg signed [31:0] score0, score1, score2
);
    `include "nn_weights.vh"
    `include "nn_math.vh"
    wire signed [7:0] x [0:3];
    (* use_dsp = "yes" *) reg signed [15:0] p1 [0:3][0:3];
    reg signed [15:0] hidden [0:3];
    (* use_dsp = "yes" *) reg signed [23:0] p2 [0:2][0:3];
    wire signed [31:0] hsum [0:3];
    wire signed [31:0] osum [0:2];
    reg signed [31:0] scores [0:2];
    reg [3:0] valid_pipe;
    genvar g;
    generate
        for (g=0;g<4;g=g+1) begin : g_input
            assign x[g] = $signed(features[g*8 +: 8]);
            assign hsum[g] = (nn_sx16(p1[g][0])+nn_sx16(p1[g][1]))
                          + (nn_sx16(p1[g][2])+nn_sx16(p1[g][3])) + nn_b1(g);
        end
        for (g=0;g<3;g=g+1) begin : g_output_sum
            assign osum[g] = (nn_sx24(p2[g][0])+nn_sx24(p2[g][1]))
                          + (nn_sx24(p2[g][2])+nn_sx24(p2[g][3])) + nn_b2(g);
        end
    endgenerate
    integer h,i,o;
    always @(posedge clk) begin
        if (rst) begin
            valid_pipe <= 4'b0; out_valid <= 1'b0;
            class_id <= 2'd0; score0 <= 0; score1 <= 0; score2 <= 0;
            for (h=0;h<4;h=h+1) begin
                hidden[h] <= 0;
                for (i=0;i<4;i=i+1) p1[h][i] <= 0;
            end
            for (o=0;o<3;o=o+1) begin
                scores[o] <= 0;
                for (i=0;i<4;i=i+1) p2[o][i] <= 0;
            end
        end else begin
            valid_pipe <= {valid_pipe[2:0],in_valid};
            out_valid <= valid_pipe[3];
            if (in_valid)
                for (h=0;h<4;h=h+1)
                    for (i=0;i<4;i=i+1) p1[h][i] <= x[i] * nn_w1(h,i);
            if (valid_pipe[0])
                for (h=0;h<4;h=h+1) hidden[h] <= nn_relu(hsum[h]);
            if (valid_pipe[1])
                for (o=0;o<3;o=o+1)
                    for (i=0;i<4;i=i+1) p2[o][i] <= hidden[i] * nn_w2(o,i);
            if (valid_pipe[2])
                for (o=0;o<3;o=o+1) scores[o] <= osum[o];
            if (valid_pipe[3]) begin
                score0 <= scores[0]; score1 <= scores[1]; score2 <= scores[2];
                class_id <= nn_argmax(scores[0],scores[1],scores[2]);
            end
        end
    end
endmodule
