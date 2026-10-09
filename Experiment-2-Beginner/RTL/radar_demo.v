`timescale 1ns / 1ps
// Standalone controller: generate 100 samples, drain ALL 80 full windows,
// capture stable results. No software sample timing or AXI transaction needed.
module radar_demo (
    input wire clk, input wire reset, input wire start,
    input wire [1:0] scenario, input wire [1:0] scale_shift,
    input wire gap_mode,
    output wire busy, output reg done, output reg timeout_error,
    output reg [7:0] detection_count,
    output reg [15:0] result_count,
    output reg [15:0] target_pos0, target_pos1, target_pos2,
    output reg [127:0] detection_mask,
    output reg [15:0] last_threshold,
    output reg [18:0] last_threshold_full,
    output reg [15:0] run_cycles, output reg [15:0] frame_id,
    output reg [1:0] active_scenario, active_scale,
    output reg active_gap
);
    localparam IDLE = 2'd0, CLEAR = 2'd1, FEED = 2'd2, DRAIN = 2'd3;
    reg [1:0] state;
    reg start_d;
    reg [6:0] sample_index;
    reg [1:0] gap_count;
    wire send_sample = (state == FEED) && (gap_count == 0);
    wire core_reset = reset || (state == CLEAR);
    wire result_valid, detected;
    wire [15:0] threshold, cut_value, cut_index;
    wire [18:0] full_threshold;
    reg [15:0] sample_value;
    assign busy = (state != IDLE);

    always @* begin
        sample_value = (active_scenario == 3) ? 16'd20000 : 16'd100;
        case (active_scenario)
            1: case (sample_index)
                30: sample_value = 16'd1000;
                60: sample_value = 16'd1200;
                85: sample_value = 16'd900;
                default: ;
            endcase
            2: if (sample_index == 30) sample_value = 16'd300;
            3: if (sample_index == 30) sample_value = 16'd60000;
            default: ;
        endcase
    end

    cfar_core u_core (
        .clk(clk), .reset(core_reset), .data_in(sample_value),
        .data_valid(send_sample), .scale_shift(active_scale),
        .result_valid(result_valid), .target_detected(detected),
        .threshold_value(threshold), .threshold_full(full_threshold),
        .cut_value(cut_value), .cut_index(cut_index)
    );

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE; start_d <= 0; sample_index <= 0; gap_count <= 0;
            done <= 0; timeout_error <= 0; detection_count <= 0;
            result_count <= 0; target_pos0 <= 16'hffff;
            target_pos1 <= 16'hffff; target_pos2 <= 16'hffff;
            detection_mask <= 0; last_threshold <= 0; last_threshold_full <= 0;
            run_cycles <= 0; frame_id <= 0;
            active_scenario <= 0; active_scale <= 2; active_gap <= 0;
        end else begin
            start_d <= start;
            if (busy) run_cycles <= run_cycles + 1'b1;
            case (state)
                IDLE: if (start && !start_d) begin
                    active_scenario <= scenario;
                    active_scale <= scale_shift; active_gap <= gap_mode;
                    frame_id <= frame_id + 1'b1;
                    done <= 0; timeout_error <= 0; detection_count <= 0;
                    result_count <= 0; detection_mask <= 0;
                    target_pos0 <= 16'hffff; target_pos1 <= 16'hffff;
                    target_pos2 <= 16'hffff;
                    last_threshold <= 0; last_threshold_full <= 0;
                    sample_index <= 0; gap_count <= 0; run_cycles <= 0;
                    state <= CLEAR;
                end
                CLEAR: state <= FEED;
                FEED: begin
                    if (send_sample) begin
                        if (sample_index == 99) state <= DRAIN;
                        else sample_index <= sample_index + 1'b1;
                        gap_count <= active_gap ? 2'd2 : 2'd0;
                    end else gap_count <= gap_count - 1'b1;
                end
                DRAIN: if (result_valid && result_count == 79) begin
                    state <= IDLE; done <= 1'b1;
                end
                default: state <= IDLE;
            endcase
            if (busy && result_valid) begin
                result_count <= result_count + 1'b1;
                last_threshold <= threshold;
                last_threshold_full <= full_threshold;
                if (detected) begin
                    if (cut_index < 128) detection_mask[cut_index] <= 1'b1;
                    case (detection_count)
                        0: target_pos0 <= cut_index;
                        1: target_pos1 <= cut_index;
                        2: target_pos2 <= cut_index;
                        default: ;
                    endcase
                    detection_count <= detection_count + 1'b1;
                end
            end
            if (busy && run_cycles >= 1023) begin
                timeout_error <= 1'b1; state <= IDLE; done <= 1'b1;
            end
        end
    end
endmodule
