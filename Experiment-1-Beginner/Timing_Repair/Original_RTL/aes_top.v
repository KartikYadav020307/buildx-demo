`timescale 1ns / 1ps
module aes_top(
input wire clk
);
// Internal wires to connect the VIO to the AES Core
wire [127:0] plaintext_wire;
wire [127:0] key_wire;
wire start_wire;
wire reset_wire;
wire [127:0] ciphertext_wire;
wire done_wire;
// 1. Instantiate the Virtual Input/Output (VIO) core
vio_0 virtual_interface (
.clk(clk), // System clock
.probe_in0(ciphertext_wire), // Receives 128-bit ciphertext FROM AES core
.probe_in1(done_wire), // Receives 1-bit done signal FROM AES core
.probe_out0(plaintext_wire), // Sends 128-bit plaintext TO AES core
.probe_out1(key_wire), // Sends 128-bit key TO AES core
.probe_out2(start_wire), // Sends 1-bit start signal TO AES core
.probe_out3(reset_wire) // Sends 1-bit reset signal TO AES core
);
// 2. Instantiate your AES-128 Hardware Core
aes_core encryption_hardware (
.clk(clk),
.reset(reset_wire),
.start(start_wire),
.plaintext(plaintext_wire),
.key(key_wire),
.ciphertext(ciphertext_wire),
.done(done_wire)
);
endmodule