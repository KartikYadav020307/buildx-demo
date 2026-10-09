`timescale 1ns / 1ps
module radar_top(input wire sysclk, output wire [3:0] led);
    wire clk_in, clk50_raw, clk50, feedback_raw, feedback, locked;
    IBUF u_clk_ibuf(.I(sysclk), .O(clk_in));
    // 125 MHz * 8 / 20 = 50 MHz; VCO = 1000 MHz.
    MMCME2_BASE #(.BANDWIDTH("OPTIMIZED"), .CLKIN1_PERIOD(8.0),
        .CLKFBOUT_MULT_F(8.0), .DIVCLK_DIVIDE(1),
        .CLKOUT0_DIVIDE_F(20.0), .STARTUP_WAIT("FALSE")) u_mmcm (
        .CLKIN1(clk_in), .CLKFBIN(feedback), .CLKFBOUT(feedback_raw),
        .CLKOUT0(clk50_raw), .LOCKED(locked), .PWRDWN(1'b0), .RST(1'b0),
        .CLKFBOUTB(), .CLKOUT0B(), .CLKOUT1(), .CLKOUT1B(),
        .CLKOUT2(), .CLKOUT2B(), .CLKOUT3(), .CLKOUT3B(),
        .CLKOUT4(), .CLKOUT5(), .CLKOUT6()
    );
    BUFG u_fb_buf(.I(feedback_raw), .O(feedback));
    BUFG u_clk_buf(.I(clk50_raw), .O(clk50));
    (* ASYNC_REG = "TRUE" *) reg [7:0] por_pipe = 8'hff;
    always @(posedge clk50 or negedge locked)
        if (!locked) por_pipe <= 8'hff;
        else por_pipe <= {por_pipe[6:0], 1'b0};
    wire reset_cmd, start_cmd, gap_cmd;
    wire [1:0] scenario_cmd, scale_cmd;
    wire reset = por_pipe[7] | reset_cmd;
    wire busy, done, timeout_error;
    wire [7:0] detection_count;
    wire [15:0] result_count, target_pos0, target_pos1, target_pos2;
    wire [127:0] detection_mask;
    wire [15:0] last_threshold, run_cycles, frame_id;
    wire [18:0] last_threshold_full;
    wire [1:0] active_scenario, active_scale;
    wire active_gap;
    (* KEEP = "TRUE" *) wire [31:0] design_id = 32'h52414432; // "RAD2" identifies this design.
    radar_demo u_demo (.clk(clk50), .reset(reset), .start(start_cmd),
        .scenario(scenario_cmd), .scale_shift(scale_cmd), .gap_mode(gap_cmd),
        .busy(busy), .done(done), .timeout_error(timeout_error),
        .detection_count(detection_count), .result_count(result_count),
        .target_pos0(target_pos0), .target_pos1(target_pos1), .target_pos2(target_pos2),
        .detection_mask(detection_mask), .last_threshold(last_threshold),
        .last_threshold_full(last_threshold_full), .run_cycles(run_cycles),
        .frame_id(frame_id), .active_scenario(active_scenario),
        .active_scale(active_scale), .active_gap(active_gap));
    vio_radar u_vio (.clk(clk50),
        .probe_out0(reset_cmd), .probe_out1(start_cmd),
        .probe_out2(scenario_cmd), .probe_out3(scale_cmd), .probe_out4(gap_cmd),
        .probe_in0(busy), .probe_in1(done), .probe_in2(detection_count),
        .probe_in3(result_count), .probe_in4(target_pos0), .probe_in5(target_pos1),
        .probe_in6(target_pos2), .probe_in7(last_threshold),
        .probe_in8(last_threshold_full), .probe_in9(run_cycles),
        .probe_in10(frame_id), .probe_in11(timeout_error),
        .probe_in12(active_scenario), .probe_in13(active_scale),
        .probe_in14(active_gap), .probe_in15(detection_mask), .probe_in16(design_id));
    reg [24:0] heartbeat = 0;
    always @(posedge clk50)
        if (por_pipe[7]) heartbeat <= 0;
        else heartbeat <= heartbeat + 1'b1;
    assign led = {(detection_count != 0), done, busy, heartbeat[24]};
endmodule
