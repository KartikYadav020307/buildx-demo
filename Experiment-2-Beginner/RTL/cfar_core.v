`timescale 1ns / 1ps
// Streaming CA-CFAR on unsigned linear-domain magnitudes or powers.
// 8 training, 2 guard, CUT, 2 guard, 8 training (21 accepted samples).
// scale_shift = 0/1/2/3 means alpha = 1/2/4/8.
// threshold = floor(sum(training)/16) * alpha; strict CUT > threshold.
// After accepting sample n >= 20, result for CUT n-10 appears TWO
// clock periods later. Stalls do not advance the sample window.
module cfar_core (
    input wire clk, input wire reset,
    input wire [15:0] data_in, input wire data_valid,
    input wire [1:0] scale_shift,
    output reg result_valid, output reg target_detected,
    output reg [15:0] threshold_value,
    output reg [18:0] threshold_full,
    output reg [15:0] cut_value, output reg [15:0] cut_index
);
    reg [15:0] window_data [0:20];
    reg [4:0] fill_count;
    reg [15:0] input_index;
    reg [17:0] p0, p1, p2, p3;
    reg [15:0] cut_s1, index_s1, cut_s2, index_s2;
    reg [1:0] scale_s1, scale_s2;
    reg valid_s1, valid_s2;
    reg [19:0] sum_s2;
    wire [18:0] threshold_comb = {3'b000, sum_s2[19:4]} << scale_s2;
    integer i;

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 21; i = i + 1) window_data[i] <= 16'd0;
            fill_count <= 0; input_index <= 0;
            p0 <= 0; p1 <= 0; p2 <= 0; p3 <= 0;
            cut_s1 <= 0; index_s1 <= 0; scale_s1 <= 0;
            cut_s2 <= 0; index_s2 <= 0; scale_s2 <= 0; sum_s2 <= 0;
            valid_s1 <= 0; valid_s2 <= 0; result_valid <= 0;
            target_detected <= 0; threshold_value <= 0;
            threshold_full <= 0; cut_value <= 0; cut_index <= 0;
        end else begin
            // Stage 1: partial sums of the NEW window, including this input.
            valid_s1 <= data_valid && (fill_count >= 20);
            if (data_valid) begin
                window_data[0] <= data_in;
                for (i = 1; i < 21; i = i + 1)
                    window_data[i] <= window_data[i-1];
                if (fill_count < 21) fill_count <= fill_count + 1'b1;
                input_index <= input_index + 1'b1;
                if (fill_count >= 20) begin
                    p0 <= {2'b00, data_in} + {2'b00, window_data[0]}
                        + {2'b00, window_data[1]} + {2'b00, window_data[2]};
                    p1 <= {2'b00, window_data[3]} + {2'b00, window_data[4]}
                        + {2'b00, window_data[5]} + {2'b00, window_data[6]};
                    p2 <= {2'b00, window_data[12]} + {2'b00, window_data[13]}
                        + {2'b00, window_data[14]} + {2'b00, window_data[15]};
                    p3 <= {2'b00, window_data[16]} + {2'b00, window_data[17]}
                        + {2'b00, window_data[18]} + {2'b00, window_data[19]};
                    cut_s1 <= window_data[9];
                    index_s1 <= input_index - 16'd10;
                    scale_s1 <= scale_shift;
                end
            end
            // Stage 2: full-width total and matching metadata.
            valid_s2 <= valid_s1;
            if (valid_s1) begin
                sum_s2 <= ({2'b00, p0} + {2'b00, p1})
                        + ({2'b00, p2} + {2'b00, p3});
                cut_s2 <= cut_s1; index_s2 <= index_s1; scale_s2 <= scale_s1;
            end
            // Stage 3: full-width comparison; only the display is saturated.
            result_valid <= valid_s2;
            target_detected <= 1'b0;
            if (valid_s2) begin
                threshold_full <= threshold_comb;
                threshold_value <= (threshold_comb > 19'd65535)
                                 ? 16'hffff : threshold_comb[15:0];
                target_detected <= ({3'b000, cut_s2} > threshold_comb);
                cut_value <= cut_s2; cut_index <= index_s2;
            end
        end
    end
endmodule
