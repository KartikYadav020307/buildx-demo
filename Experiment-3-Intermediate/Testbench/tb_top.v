`timescale 1ns/1ps
// Unit simulation of the unchanged HLS-generated FIR core, not a PS/DMA model.
module tb_top;
  reg ap_clk = 0;
  always #5 ap_clk = ~ap_clk;
  reg ap_rst_n = 0;
  reg ap_start = 0;
  wire ap_done, ap_idle, ap_ready;
  reg [15:0] in_stream_TDATA = 0;
  reg in_stream_TVALID = 0;
  wire in_stream_TREADY;
  reg [1:0] in_stream_TKEEP = 3, in_stream_TSTRB = 3;
  reg in_stream_TLAST = 0;
  wire [15:0] out_stream_TDATA;
  wire out_stream_TVALID;
  reg out_stream_TREADY = 0;
  wire [1:0] out_stream_TKEEP, out_stream_TSTRB;
  wire out_stream_TLAST;
  wire [31:0] count = 2048;
  ecg_bandpass_filter dut(
    .ap_clk(ap_clk),.ap_rst_n(ap_rst_n),.ap_start(ap_start),
    .ap_done(ap_done),.ap_idle(ap_idle),.ap_ready(ap_ready),
    .in_stream_TDATA(in_stream_TDATA),.in_stream_TVALID(in_stream_TVALID),
    .in_stream_TREADY(in_stream_TREADY),.in_stream_TKEEP(in_stream_TKEEP),
    .in_stream_TSTRB(in_stream_TSTRB),.in_stream_TLAST(in_stream_TLAST),
    .out_stream_TDATA(out_stream_TDATA),.out_stream_TVALID(out_stream_TVALID),
    .out_stream_TREADY(out_stream_TREADY),.out_stream_TKEEP(out_stream_TKEEP),
    .out_stream_TSTRB(out_stream_TSTRB),.out_stream_TLAST(out_stream_TLAST),.count(count));

  reg [15:0] inputs [0:16383];
  reg [15:0] expected [0:16383];
  integer case_id = 0, total = 0, tx_index = 0, rx_index = 0;
  integer cycle = 0, errors = 0, output_stalls = 0, input_gaps = 0;
  integer frames = 0, done_pulses = 0, all_samples = 0;
  integer csv;
  reg active = 0, stalled_previous = 0;
  reg [20:0] held_output;
  wire [20:0] output_packet = {out_stream_TDATA,out_stream_TKEEP,out_stream_TSTRB,out_stream_TLAST};
  wire signed [15:0] input_q412 = in_stream_TDATA;
  wire signed [15:0] output_q412 = out_stream_TDATA;

  function [1:0] keep_for;
    input integer index;
    begin
      case(index%19)
        0: keep_for=1;
        1: keep_for=2;
        default: keep_for=3;
      endcase
    end
  endfunction
  function [1:0] strb_for;
    input integer index;
    begin
      strb_for = (index%23==0) ? 1 : keep_for(index);
    end
  endfunction

  // Update source signals on falling edges and hold them across stalled beats.
  always @(negedge ap_clk) begin
    if(active && ap_rst_n) begin
      out_stream_TREADY = ((cycle%13)!=4 && (cycle%13)!=5 && (cycle%13)!=6);
      if(!(in_stream_TVALID && !in_stream_TREADY)) begin
        if(tx_index<total && cycle%7!=2) begin
          in_stream_TVALID=1;
          in_stream_TDATA=inputs[tx_index];
          in_stream_TKEEP=keep_for(tx_index);
          in_stream_TSTRB=strb_for(tx_index);
          in_stream_TLAST=(tx_index%2048==2047);
        end else in_stream_TVALID=0;
      end
    end else begin
      in_stream_TVALID=0;
      out_stream_TREADY=0;
    end
  end

  always @(posedge ap_clk) begin
    cycle = cycle+1;
    if(active && ap_rst_n) begin
      if(!in_stream_TVALID && tx_index<total) input_gaps=input_gaps+1;
      if(in_stream_TVALID && in_stream_TREADY) tx_index=tx_index+1;
      if(ap_done) done_pulses=done_pulses+1;
      if(stalled_previous && (out_stream_TVALID!==1'b1 || output_packet!==held_output)) begin
        $display("FAIL: output changed during backpressure, case=%0d cycle=%0d",case_id,cycle);
        errors=errors+1;
      end
      stalled_previous = (out_stream_TVALID===1'b1 && out_stream_TREADY===1'b0);
      held_output=output_packet;
      if(stalled_previous) output_stalls=output_stalls+1;
      if(out_stream_TVALID && out_stream_TREADY) begin
        if(rx_index>=total || rx_index>=tx_index) begin
          $display("FAIL: unexpected output case=%0d index=%0d",case_id,rx_index);
          errors=errors+1;
        end else begin
          if(out_stream_TDATA !== expected[rx_index]) begin
            if(errors<10) $display("FAIL: case=%0d sample=%0d actual=%0d expected=%0d",case_id,rx_index,$signed(out_stream_TDATA),$signed(expected[rx_index]));
            errors=errors+1;
          end
          if(out_stream_TKEEP!==keep_for(rx_index) || out_stream_TSTRB!==strb_for(rx_index)) begin
            $display("FAIL: KEEP/STRB case=%0d sample=%0d",case_id,rx_index);
            errors=errors+1;
          end
          if(out_stream_TLAST !== (rx_index%2048==2047)) begin
            $display("FAIL: TLAST case=%0d sample=%0d",case_id,rx_index);
            errors=errors+1;
          end
          if(out_stream_TLAST) frames=frames+1;
          $fdisplay(csv,"%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",case_id,cycle,rx_index,$signed(inputs[rx_index]),$signed(out_stream_TDATA),$signed(expected[rx_index]),out_stream_TLAST,out_stream_TKEEP);
        end
        rx_index=rx_index+1;
      end
    end else stalled_previous=0;
  end

  task run_case;
    input integer id;
    input integer length;
    input [8*80-1:0] input_file;
    input [8*80-1:0] expected_file;
    integer begin_cycle, begin_errors;
    begin
      @(negedge ap_clk); active=0; ap_start=0; ap_rst_n=0;
      repeat(12) @(negedge ap_clk);
      $readmemh(input_file,inputs,0,length-1);
      $readmemh(expected_file,expected,0,length-1);
      case_id=id;total=length;tx_index=0;rx_index=0;
      frames=0;done_pulses=0;input_gaps=0;output_stalls=0;
      begin_cycle=cycle;begin_errors=errors;
      ap_rst_n=1;ap_start=1;active=1;
      while(rx_index<total && cycle-begin_cycle<200000) @(negedge ap_clk);
      if(rx_index!=total || tx_index!=total) begin
        $display("FAIL: timeout case=%0d tx=%0d rx=%0d",id,tx_index,rx_index);
        errors=errors+1;
      end
      // The last external output precedes the HLS function's ap_done. Wait
      // for the full pipeline drain and state writeback before resetting.
      while(done_pulses<length/2048 && cycle-begin_cycle<200000) @(negedge ap_clk);
      repeat(20) @(negedge ap_clk);
      if(frames!=length/2048 || done_pulses!=length/2048) begin
        $display("FAIL: frame/completion count case=%0d TLAST=%0d DONE=%0d",id,frames,done_pulses);
        errors=errors+1;
      end
      $display("CASE %0d: samples=%0d exact_matches=%0d batches=%0d cycles=%0d output_stall_cycles=%0d input_gap_cycles=%0d errors=%0d",id,length,(errors==begin_errors)?length:0,frames,cycle-begin_cycle,output_stalls,input_gaps,errors-begin_errors);
      all_samples=all_samples+length;
      active=0;ap_start=0;
    end
  endtask

  initial begin
    $dumpfile("Simulation/rtl_waveform.vcd");
    $dumpvars(1,tb_top);
    csv=$fopen("Simulation/rtl_output_samples.csv","w");
    $fdisplay(csv,"case_id,cycle,sample,input_q412,actual_q412,expected_q412,tlast,tkeep");
    $display("DUT: unchanged Vitis HLS generated ecg_bandpass_filter; clock=100 MHz; count=2048");
    $display("Tests: reset, impulse, sine, signed random, ECG, batch history, KEEP/STRB, TLAST, backpressure");
    run_case(1,4096,"Testbench/vectors/impulse_input.hex","Testbench/vectors/impulse_expected.hex");
    run_case(2,4096,"Testbench/vectors/sine_input.hex","Testbench/vectors/sine_expected.hex");
    run_case(3,6144,"Testbench/vectors/random_input.hex","Testbench/vectors/random_expected.hex");
    run_case(4,14336,"Testbench/vectors/ecg_input.hex","Testbench/vectors/ecg_expected.hex");
    $fclose(csv);
    if(errors==0) begin
      $display("RTL TEST PASS: %0d/%0d exact samples, 0 LSB error, 14 batches; all protocol checks passed",all_samples,all_samples);
      $finish;
    end else $fatal(1,"RTL TEST FAIL: %0d errors",errors);
  end
endmodule
