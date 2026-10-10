`timescale 1ns / 1ps
module tb_aes_core;
// Inputs to the module
reg clk;
reg reset;
reg start;
reg [127:0] plaintext;
reg [127:0] key;
// Outputs from the module
wire [127:0] ciphertext;
wire done;
// Instantiate the Unit Under Test (UUT)
aes_core uut (
.clk(clk),
.reset(reset),
.start(start),
.plaintext(plaintext),
.key(key),
.ciphertext(ciphertext),
.done(done)
);
// Clock Generation: 100 MHz (10ns period)
initial begin
clk = 0;
forever #5 clk = ~clk;
end
// Test Sequence
initial begin
// 1. Initialize Inputs
reset = 1;
start = 0;
plaintext = 128'h0;
key = 128'h0;
// Wait 100 ns for global reset to propagate
#100;
// Release reset
reset = 0;
#20;
// 2. Load NIST Test Vectors
key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
plaintext = 128'h6bc1bee22e409f96e93d7e117393172a;
// 3. Pulse the start signal for one clock cycle
start = 1;
#10;
start = 0;
// 4. Wait for the 'done' signal to go high
@(posedge done);
// Add a tiny delay to ensure the output register has settled in simulation
#2;
// 5. Verify the Results
$display("\n==================================================");
$display(" AES-128 ENCRYPTION TEST ");
$display("");
$display("KEY : %h", key);
$display("PLAINTEXT : %h", plaintext);
$display("CIPHERTEXT : %h", ciphertext);
$display("EXPECTED : 3ad77bb40d7a3660a89ecaf32466ef97");
$display("");
if (ciphertext === 128'h3ad77bb40d7a3660a89ecaf32466ef97) begin
$display("STATUS : >> TEST PASSED <<");
end else begin
$display("STATUS : >> TEST FAILED <<");
end
$display("==================================================\n");
// End simulation
#50;
$finish;
end
endmodule