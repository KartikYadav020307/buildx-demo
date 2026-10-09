// Generated trained constants. Include INSIDE each core module.
// No include guard: both core modules need their own functions.

function automatic signed [7:0] nn_w1(input integer node, input integer term);
  case (node * 4 + term)
    0: nn_w1 = 8'shf9;
    1: nn_w1 = 8'shd0;
    2: nn_w1 = 8'sh7a;
    3: nn_w1 = 8'sh5e;
    4: nn_w1 = 8'shd5;
    5: nn_w1 = 8'sh26;
    6: nn_w1 = 8'shc6;
    7: nn_w1 = 8'shd9;
    8: nn_w1 = 8'she2;
    9: nn_w1 = 8'sh2b;
    10: nn_w1 = 8'shca;
    11: nn_w1 = 8'shca;
    12: nn_w1 = 8'shfa;
    13: nn_w1 = 8'she1;
    14: nn_w1 = 8'sh68;
    15: nn_w1 = 8'sh36;
    default: nn_w1 = 8'sd0;
  endcase
endfunction

function automatic signed [31:0] nn_b1(input integer node);
  case (node)
    0: nn_b1 = 32'shfffff654;
    1: nn_b1 = 32'sh00000cd7;
    2: nn_b1 = 32'sh0000066d;
    3: nn_b1 = 32'sh00001774;
    default: nn_b1 = 32'sd0;
  endcase
endfunction

function automatic signed [7:0] nn_w2(input integer node, input integer term);
  case (node * 4 + term)
    0: nn_w2 = 8'shfe;
    1: nn_w2 = 8'sh43;
    2: nn_w2 = 8'sh42;
    3: nn_w2 = 8'shbf;
    4: nn_w2 = 8'sh86;
    5: nn_w2 = 8'shf9;
    6: nn_w2 = 8'shbf;
    7: nn_w2 = 8'shde;
    8: nn_w2 = 8'sh7a;
    9: nn_w2 = 8'shc5;
    10: nn_w2 = 8'shfe;
    11: nn_w2 = 8'sh62;
    default: nn_w2 = 8'sd0;
  endcase
endfunction

function automatic signed [31:0] nn_b2(input integer node);
  case (node)
    0: nn_b2 = 32'shfffffc79;
    1: nn_b2 = 32'sh000032db;
    2: nn_b2 = 32'shffffc57c;
    default: nn_b2 = 32'sd0;
  endcase
endfunction

