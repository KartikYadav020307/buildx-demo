`timescale 1ns / 1ps
module aes_core (
input wire clk,
input wire reset,
input wire start,
input wire [127:0] plaintext,
input wire [127:0] key,
output reg [127:0] ciphertext,
output reg done
);
// FSM States
localparam S_IDLE = 2'b00;
localparam S_KEY_EXP = 2'b01;
localparam S_ROUNDS = 2'b10;
localparam S_FINISHED = 2'b11;
// Internal Registers
reg [1:0] state;
reg [3:0] round_ctr;
reg [127:0] state_data;
reg [127:0] round_keys [0:10];
reg [3:0] k_idx;
// Direct previous-key register avoids the indexed key-bank read in expansion.
reg [127:0] previous_key;
// Rijndael S-Box lookup table function
function [7:0] sbox_lut(input [7:0] in_byte);
case (in_byte)
8'h00: sbox_lut = 8'h63; 8'h01: sbox_lut = 8'h7c; 8'h02: sbox_lut = 8'h77; 8'h03: sbox_lut = 8'h7b;
8'h04: sbox_lut = 8'hf2; 8'h05: sbox_lut = 8'h6b; 8'h06: sbox_lut = 8'h6f; 8'h07: sbox_lut = 8'hc5;
8'h08: sbox_lut = 8'h30; 8'h09: sbox_lut = 8'h01; 8'h0a: sbox_lut = 8'h67; 8'h0b: sbox_lut = 8'h2b;
8'h0c: sbox_lut = 8'hfe; 8'h0d: sbox_lut = 8'hd7; 8'h0e: sbox_lut = 8'hab; 8'h0f: sbox_lut = 8'h76;
8'h10: sbox_lut = 8'hca; 8'h11: sbox_lut = 8'h82; 8'h12: sbox_lut = 8'hc9; 8'h13: sbox_lut = 8'h7d;
8'h14: sbox_lut = 8'hfa; 8'h15: sbox_lut = 8'h59; 8'h16: sbox_lut = 8'h47; 8'h17: sbox_lut = 8'hf0;
8'h18: sbox_lut = 8'had; 8'h19: sbox_lut = 8'hd4; 8'h1a: sbox_lut = 8'ha2; 8'h1b: sbox_lut = 8'haf;
8'h1c: sbox_lut = 8'h9c; 8'h1d: sbox_lut = 8'ha4; 8'h1e: sbox_lut = 8'h72; 8'h1f: sbox_lut = 8'hc0;
8'h20: sbox_lut = 8'hb7; 8'h21: sbox_lut = 8'hfd; 8'h22: sbox_lut = 8'h93; 8'h23: sbox_lut = 8'h26;
8'h24: sbox_lut = 8'h36; 8'h25: sbox_lut = 8'h3f; 8'h26: sbox_lut = 8'hf7; 8'h27: sbox_lut = 8'hcc;
8'h28: sbox_lut = 8'h34; 8'h29: sbox_lut = 8'ha5; 8'h2a: sbox_lut = 8'he5; 8'h2b: sbox_lut = 8'hf1;
8'h2c: sbox_lut = 8'h71; 8'h2d: sbox_lut = 8'hd8; 8'h2e: sbox_lut = 8'h31; 8'h2f: sbox_lut = 8'h15;
8'h30: sbox_lut = 8'h04; 8'h31: sbox_lut = 8'hc7; 8'h32: sbox_lut = 8'h23; 8'h33: sbox_lut = 8'hc3;
8'h34: sbox_lut = 8'h18; 8'h35: sbox_lut = 8'h96; 8'h36: sbox_lut = 8'h05; 8'h37: sbox_lut = 8'h9a;
8'h38: sbox_lut = 8'h07; 8'h39: sbox_lut = 8'h12; 8'h3a: sbox_lut = 8'h80; 8'h3b: sbox_lut = 8'he2;
8'h3c: sbox_lut = 8'heb; 8'h3d: sbox_lut = 8'h27; 8'h3e: sbox_lut = 8'hb2; 8'h3f: sbox_lut = 8'h75;
8'h40: sbox_lut = 8'h09; 8'h41: sbox_lut = 8'h83; 8'h42: sbox_lut = 8'h2c; 8'h43: sbox_lut = 8'h1a;
8'h44: sbox_lut = 8'h1b; 8'h45: sbox_lut = 8'h6e; 8'h46: sbox_lut = 8'h5a; 8'h47: sbox_lut = 8'ha0;
8'h48: sbox_lut = 8'h52; 8'h49: sbox_lut = 8'h3b; 8'h4a: sbox_lut = 8'hd6; 8'h4b: sbox_lut = 8'hb3;
8'h4c: sbox_lut = 8'h29; 8'h4d: sbox_lut = 8'he3; 8'h4e: sbox_lut = 8'h2f; 8'h4f: sbox_lut = 8'h84;
8'h50: sbox_lut = 8'h53; 8'h51: sbox_lut = 8'hd1; 8'h52: sbox_lut = 8'h00; 8'h53: sbox_lut = 8'hed;
8'h54: sbox_lut = 8'h20; 8'h55: sbox_lut = 8'hfc; 8'h56: sbox_lut = 8'hb1; 8'h57: sbox_lut = 8'h5b;
8'h58: sbox_lut = 8'h6a; 8'h59: sbox_lut = 8'hcb; 8'h5a: sbox_lut = 8'hbe; 8'h5b: sbox_lut = 8'h39;
8'h5c: sbox_lut = 8'h4a; 8'h5d: sbox_lut = 8'h4c; 8'h5e: sbox_lut = 8'h58; 8'h5f: sbox_lut = 8'hcf;
8'h60: sbox_lut = 8'hd0; 8'h61: sbox_lut = 8'hef; 8'h62: sbox_lut = 8'haa; 8'h63: sbox_lut = 8'hfb;
8'h64: sbox_lut = 8'h43; 8'h65: sbox_lut = 8'h4d; 8'h66: sbox_lut = 8'h33; 8'h67: sbox_lut = 8'h85;
8'h68: sbox_lut = 8'h45; 8'h69: sbox_lut = 8'hf9; 8'h6a: sbox_lut = 8'h02; 8'h6b: sbox_lut = 8'h7f;
8'h6c: sbox_lut = 8'h50; 8'h6d: sbox_lut = 8'h3c; 8'h6e: sbox_lut = 8'h9f; 8'h6f: sbox_lut = 8'ha8;
8'h70: sbox_lut = 8'h51; 8'h71: sbox_lut = 8'ha3; 8'h72: sbox_lut = 8'h40; 8'h73: sbox_lut = 8'h8f;
8'h74: sbox_lut = 8'h92; 8'h75: sbox_lut = 8'h9d; 8'h76: sbox_lut = 8'h38; 8'h77: sbox_lut = 8'hf5;
8'h78: sbox_lut = 8'hbc; 8'h79: sbox_lut = 8'hb6; 8'h7a: sbox_lut = 8'hda; 8'h7b: sbox_lut = 8'h21;
8'h7c: sbox_lut = 8'h10; 8'h7d: sbox_lut = 8'hff; 8'h7e: sbox_lut = 8'hf3; 8'h7f: sbox_lut = 8'hd2;
8'h80: sbox_lut = 8'hcd; 8'h81: sbox_lut = 8'h0c; 8'h82: sbox_lut = 8'h13; 8'h83: sbox_lut = 8'hec;
8'h84: sbox_lut = 8'h5f; 8'h85: sbox_lut = 8'h97; 8'h86: sbox_lut = 8'h44; 8'h87: sbox_lut = 8'h17;
8'h88: sbox_lut = 8'hc4; 8'h89: sbox_lut = 8'ha7; 8'h8a: sbox_lut = 8'h7e; 8'h8b: sbox_lut = 8'h3d;
8'h8c: sbox_lut = 8'h64; 8'h8d: sbox_lut = 8'h5d; 8'h8e: sbox_lut = 8'h19; 8'h8f: sbox_lut = 8'h73;
8'h90: sbox_lut = 8'h60; 8'h91: sbox_lut = 8'h81; 8'h92: sbox_lut = 8'h4f; 8'h93: sbox_lut = 8'hdc;
8'h94: sbox_lut = 8'h22; 8'h95: sbox_lut = 8'h2a; 8'h96: sbox_lut = 8'h90; 8'h97: sbox_lut = 8'h88;
8'h98: sbox_lut = 8'h46; 8'h99: sbox_lut = 8'hee; 8'h9a: sbox_lut = 8'hb8; 8'h9b: sbox_lut = 8'h14;
8'h9c: sbox_lut = 8'hde; 8'h9d: sbox_lut = 8'h5e; 8'h9e: sbox_lut = 8'h0b; 8'h9f: sbox_lut = 8'hdb;
8'ha0: sbox_lut = 8'he0; 8'ha1: sbox_lut = 8'h32; 8'ha2: sbox_lut = 8'h3a; 8'ha3: sbox_lut = 8'h0a;
8'ha4: sbox_lut = 8'h49; 8'ha5: sbox_lut = 8'h06; 8'ha6: sbox_lut = 8'h24; 8'ha7: sbox_lut = 8'h5c;
8'ha8: sbox_lut = 8'hc2; 8'ha9: sbox_lut = 8'hd3; 8'haa: sbox_lut = 8'hac; 8'hab: sbox_lut = 8'h62;
8'hac: sbox_lut = 8'h91; 8'had: sbox_lut = 8'h95; 8'hae: sbox_lut = 8'he4; 8'haf: sbox_lut = 8'h79;
8'hb0: sbox_lut = 8'he7; 8'hb1: sbox_lut = 8'hc8; 8'hb2: sbox_lut = 8'h37; 8'hb3: sbox_lut = 8'h6d;
8'hb4: sbox_lut = 8'h8d; 8'hb5: sbox_lut = 8'hd5; 8'hb6: sbox_lut = 8'h4e; 8'hb7: sbox_lut = 8'ha9;
8'hb8: sbox_lut = 8'h6c; 8'hb9: sbox_lut = 8'h56; 8'hba: sbox_lut = 8'hf4; 8'hbb: sbox_lut = 8'hea;
8'hbc: sbox_lut = 8'h65; 8'hbd: sbox_lut = 8'h7a; 8'hbe: sbox_lut = 8'hae; 8'hbf: sbox_lut = 8'h08;
8'hc0: sbox_lut = 8'hba; 8'hc1: sbox_lut = 8'h78; 8'hc2: sbox_lut = 8'h25; 8'hc3: sbox_lut = 8'h2e;
8'hc4: sbox_lut = 8'h1c; 8'hc5: sbox_lut = 8'ha6; 8'hc6: sbox_lut = 8'hb4; 8'hc7: sbox_lut = 8'hc6;
8'hc8: sbox_lut = 8'he8; 8'hc9: sbox_lut = 8'hdd; 8'hca: sbox_lut = 8'h74; 8'hcb: sbox_lut = 8'h1f;
8'hcc: sbox_lut = 8'h4b; 8'hcd: sbox_lut = 8'hbd; 8'hce: sbox_lut = 8'h8b; 8'hcf: sbox_lut = 8'h8a;
8'hd0: sbox_lut = 8'h70; 8'hd1: sbox_lut = 8'h3e; 8'hd2: sbox_lut = 8'hb5; 8'hd3: sbox_lut = 8'h66;
8'hd4: sbox_lut = 8'h48; 8'hd5: sbox_lut = 8'h03; 8'hd6: sbox_lut = 8'hf6; 8'hd7: sbox_lut = 8'h0e;
8'hd8: sbox_lut = 8'h61; 8'hd9: sbox_lut = 8'h35; 8'hda: sbox_lut = 8'h57; 8'hdb: sbox_lut = 8'hb9;
8'hdc: sbox_lut = 8'h86; 8'hdd: sbox_lut = 8'hc1; 8'hde: sbox_lut = 8'h1d; 8'hdf: sbox_lut = 8'h9e;
8'he0: sbox_lut = 8'he1; 8'he1: sbox_lut = 8'hf8; 8'he2: sbox_lut = 8'h98; 8'he3: sbox_lut = 8'h11;
8'he4: sbox_lut = 8'h69; 8'he5: sbox_lut = 8'hd9; 8'he6: sbox_lut = 8'h8e; 8'he7: sbox_lut = 8'h94;
8'he8: sbox_lut = 8'h9b; 8'he9: sbox_lut = 8'h1e; 8'hea: sbox_lut = 8'h87; 8'heb: sbox_lut = 8'he9;
8'hec: sbox_lut = 8'hce; 8'hed: sbox_lut = 8'h55; 8'hee: sbox_lut = 8'h28; 8'hef: sbox_lut = 8'hdf;
8'hf0: sbox_lut = 8'h8c; 8'hf1: sbox_lut = 8'ha1; 8'hf2: sbox_lut = 8'h89; 8'hf3: sbox_lut = 8'h0d;
8'hf4: sbox_lut = 8'hbf; 8'hf5: sbox_lut = 8'he6; 8'hf6: sbox_lut = 8'h42; 8'hf7: sbox_lut = 8'h68;
8'hf8: sbox_lut = 8'h41; 8'hf9: sbox_lut = 8'h99; 8'hfa: sbox_lut = 8'h2d; 8'hfb: sbox_lut = 8'h0f;
8'hfc: sbox_lut = 8'hb0; 8'hfd: sbox_lut = 8'h54; 8'hfe: sbox_lut = 8'hbb; 8'hff: sbox_lut = 8'h16;
endcase
endfunction
// Round Constant (Rcon) lookup
function [7:0] rcon(input [3:0] idx);
case (idx)
4'd1: rcon = 8'h01;
4'd2: rcon = 8'h02;
4'd3: rcon = 8'h04;
4'd4: rcon = 8'h08;
4'd5: rcon = 8'h10;
4'd6: rcon = 8'h20;
4'd7: rcon = 8'h40;
4'd8: rcon = 8'h80;
4'd9: rcon = 8'h1b;
4'd10: rcon = 8'h36;
default: rcon = 8'h00;
endcase
endfunction
// Galois Field GF(2^8) multiplication by 2 (used in MixColumns)
function [7:0] xtime(input [7:0] b);
xtime = (b[7]) ? ((b << 1) ^ 8'h1b) : (b << 1);
endfunction
// Key Expansion Combinational Logic
reg [31:0] k_w0, k_w1, k_w2, k_w3;
reg [31:0] rot_sub_w;
reg [31:0] next_w0, next_w1, next_w2, next_w3;
always @(*) begin
k_w0 = previous_key[127:96];
k_w1 = previous_key[95:64];
k_w2 = previous_key[63:32];
k_w3 = previous_key[31:0];
// RotWord + SubWord + Rcon on the last word
rot_sub_w = {sbox_lut(k_w3[23:16]) ^ rcon(k_idx),
sbox_lut(k_w3[15:8]),
sbox_lut(k_w3[7:0]),
sbox_lut(k_w3[31:24])};
next_w0 = k_w0 ^ rot_sub_w;
next_w1 = k_w1 ^ next_w0;
next_w2 = k_w2 ^ next_w1;
next_w3 = k_w3 ^ next_w2;
end
// ---------------------------------------------------------
// AES ROUND TRANSFORMATION BLOCKS (Combinational)
// ---------------------------------------------------------
// 1. SubBytes Transformation
wire [127:0] sub_bytes_out;
genvar gi;
generate
    for (gi = 0; gi < 16; gi = gi + 1) begin : gen_sbox
        assign sub_bytes_out[gi*8 +: 8] = sbox_lut(state_data[gi*8 +: 8]);
    end
endgenerate
// 2. ShiftRows Transformation
// Standard AES byte permutation matrix mapping
wire [127:0] shift_rows_out;
// Row 0 - No shift
assign shift_rows_out[127:120] = sub_bytes_out[127:120];
assign shift_rows_out[95:88]   = sub_bytes_out[95:88];
assign shift_rows_out[63:56]   = sub_bytes_out[63:56];
assign shift_rows_out[31:24]   = sub_bytes_out[31:24];

// Row 1 - Shift left 1
assign shift_rows_out[119:112] = sub_bytes_out[87:80];
assign shift_rows_out[87:80]   = sub_bytes_out[55:48];
assign shift_rows_out[55:48]   = sub_bytes_out[23:16];
assign shift_rows_out[23:16]   = sub_bytes_out[119:112];

// Row 2 - Shift left 2
assign shift_rows_out[111:104] = sub_bytes_out[47:40];
assign shift_rows_out[79:72]   = sub_bytes_out[15:8];
assign shift_rows_out[47:40]   = sub_bytes_out[111:104];
assign shift_rows_out[15:8]    = sub_bytes_out[79:72];

// Row 3 - Shift left 3
assign shift_rows_out[103:96]  = sub_bytes_out[7:0];
assign shift_rows_out[71:64]   = sub_bytes_out[103:96];
assign shift_rows_out[39:32]   = sub_bytes_out[71:64];
assign shift_rows_out[7:0]     = sub_bytes_out[39:32];

// 3. MixColumns Transformation
wire [127:0] mix_cols_out;
genvar c;
generate
for (c = 0; c < 4; c = c + 1) begin : gen_mix
wire [7:0] a0 = shift_rows_out[(3-c)*32 + 24 +: 8];
wire [7:0] a1 = shift_rows_out[(3-c)*32 + 16 +: 8];
wire [7:0] a2 = shift_rows_out[(3-c)*32 + 8 +: 8];
wire [7:0] a3 = shift_rows_out[(3-c)*32 + 0 +: 8];
assign mix_cols_out[(3-c)*32 + 24 +: 8] = xtime(a0) ^ xtime(a1) ^ a1 ^ a2 ^ a3;
assign mix_cols_out[(3-c)*32 + 16 +: 8] = a0 ^ xtime(a1) ^ xtime(a2) ^ a2 ^ a3;
assign mix_cols_out[(3-c)*32 + 8 +: 8] = a0 ^ a1 ^ xtime(a2) ^ xtime(a3) ^ a3;
assign mix_cols_out[(3-c)*32 + 0 +: 8] = xtime(a0) ^ a0 ^ a1 ^ a2 ^ xtime(a3);
end
endgenerate
// ---------------------------------------------------------
// SEQUENTIAL STATE MACHINE (Iterative Control)
// ---------------------------------------------------------
always @(posedge clk or posedge reset) begin
if (reset) begin
state <= S_IDLE;
round_ctr <= 4'd0;
k_idx <= 4'd1;
state_data <= 128'd0;
previous_key <= 128'd0;
ciphertext <= 128'd0;
done <= 1'b0;
end else begin
case (state)
S_IDLE: begin
done <= 1'b0;
if (start) begin
// Initial AddRoundKey (Round 0)
round_keys[0] <= key;
previous_key <= key;
state_data <= plaintext ^ key;
k_idx <= 4'd1;
state <= S_KEY_EXP;
end
end
S_KEY_EXP: begin
// Expand 10 round keys over 10 clock cycles to save area (LUTs)
round_keys[k_idx] <= {next_w0, next_w1, next_w2, next_w3};
previous_key <= {next_w0, next_w1, next_w2, next_w3};
if (k_idx == 4'd10) begin
round_ctr <= 4'd1;
state <= S_ROUNDS;
end else begin
k_idx <= k_idx + 1'b1;
end
end
S_ROUNDS: begin
// Iterate through Rounds 1-9 (Full operations)
if (round_ctr < 4'd10) begin
state_data <= mix_cols_out ^ round_keys[round_ctr];
round_ctr <= round_ctr + 1'b1;
end else begin
// Final Round 10 (Omits MixColumns per AES Standard)
state_data <= shift_rows_out ^ round_keys[10];
state <= S_FINISHED;
end
end
S_FINISHED: begin
// Output the final encrypted data and flag completion
ciphertext <= state_data;
done <= 1'b1;
state <= S_IDLE;
end
default: state <= S_IDLE;
endcase
end
end
endmodule