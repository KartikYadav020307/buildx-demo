// Include inside each module. All arithmetic is explicitly signed.
function automatic signed [31:0] nn_sx16(input signed [15:0] v);
    nn_sx16 = {{16{v[15]}},v};
endfunction
function automatic signed [31:0] nn_sx24(input signed [23:0] v);
    nn_sx24 = {{8{v[23]}},v};
endfunction
function automatic signed [15:0] nn_relu(input signed [31:0] acc);
    reg signed [31:0] shifted;
    begin
        shifted = acc >>> 6;
        if (shifted < 0) nn_relu = 16'sd0;
        else if (shifted > 32767) nn_relu = 16'sh7fff;
        else nn_relu = shifted[15:0];
    end
endfunction
function automatic [1:0] nn_argmax(
    input signed [31:0] a, input signed [31:0] b, input signed [31:0] c);
    reg signed [31:0] best;
    begin
        best = a; nn_argmax = 2'd0;
        if (b > best) begin best = b; nn_argmax = 2'd1; end
        if (c > best) nn_argmax = 2'd2;
    end
endfunction
