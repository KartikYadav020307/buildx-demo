// =============================================================================
// ecg_bandpass_filter.cpp
// Target : PYNQ-Z2 (xc7z020clg400-1)
// Tool   : Vitis Unified IDE 2025.1.1
// Clock  : 10 ns (100 MHz)
// =============================================================================
#include "ecg_bandpass_filter.h"

void ecg_bandpass_filter(
    hls::stream<axis_t>& in_stream,
    hls::stream<axis_t>& out_stream,
    int                   count
)
{
    // -------------------------------------------------------------------------
    // Interface pragmas — mode= syntax is preferred in Vitis 2025.1.1.
    // The bare-keyword form (e.g. "#pragma HLS INTERFACE ap_ctrl_hs …") still
    // compiles but may generate a deprecation notice in the HLS log.
    // -------------------------------------------------------------------------
#pragma HLS INTERFACE mode=ap_ctrl_hs port=return
#pragma HLS INTERFACE mode=axis       port=in_stream
#pragma HLS INTERFACE mode=axis       port=out_stream
#pragma HLS INTERFACE mode=ap_none    port=count

    // =========================================================================
    //  FIR coefficient ROM  —  128 taps, Hamming window, 0.5–40 Hz @ 360 Hz
    // =========================================================================
    //
    //  ┌──────────────────────────────────────────────────────────────────────┐
    //  │  COEFFICIENT PLACEHOLDER                                             │
    //  │                                                                      │
    //  │  All 128 entries are currently zero.  The filter will produce zero   │
    //  │  output until you replace this initialiser block with real values.   │
    //  │                                                                      │
    //  │  HOW TO GENERATE REAL COEFFICIENTS:                                  │
    //  │  Run the Python script at the bottom of this audit document.         │
    //  │  It prints a drop-in replacement for the entire h[128] block below.  │
    //  │  Copy-paste that block over this one, then re-run C Simulation.      │
    //  └──────────────────────────────────────────────────────────────────────┘
    static const data_t h[128] = {
    0.00000, -0.00024, -0.00049, -0.00073, -0.00049, -0.00024, 0.00000, 0.00024,
    0.00024, 0.00000, -0.00073, -0.00122, -0.00146, -0.00122, -0.00049, 0.00024,
    0.00073, 0.00073, 0.00000, -0.00146, -0.00269, -0.00317, -0.00244, -0.00098,
    0.00098, 0.00220, 0.00195, 0.00000, -0.00269, -0.00513, -0.00610, -0.00464,
    -0.00146, 0.00220, 0.00464, 0.00415, 0.00073, -0.00439, -0.00928, -0.01099,
    -0.00830, -0.00195, 0.00513, 0.00977, 0.00903, 0.00244, -0.00757, -0.01660,
    -0.02002, -0.01489, -0.00244, 0.01245, 0.02271, 0.02197, 0.00830, -0.01489,
    -0.03833, -0.04980, -0.03931, -0.00269, 0.05518, 0.12207, 0.18042, 0.21460,
    0.21460, 0.18042, 0.12207, 0.05518, -0.00269, -0.03931, -0.04980, -0.03833,
    -0.01489, 0.00830, 0.02197, 0.02271, 0.01245, -0.00244, -0.01489, -0.02002,
    -0.01660, -0.00757, 0.00244, 0.00903, 0.00977, 0.00513, -0.00195, -0.00830,
    -0.01099, -0.00928, -0.00439, 0.00073, 0.00415, 0.00464, 0.00220, -0.00146,
    -0.00464, -0.00610, -0.00513, -0.00269, 0.00000, 0.00195, 0.00220, 0.00098,
    -0.00098, -0.00244, -0.00317, -0.00269, -0.00146, 0.00000, 0.00073, 0.00073,
    0.00024, -0.00049, -0.00122, -0.00146, -0.00122, -0.00073, 0.00000, 0.00024,
    0.00024, 0.00000, -0.00024, -0.00049, -0.00073, -0.00049, -0.00024, 0.00000
};


    // Partition the coefficient ROM fully so all 128 values are accessible
    // in a single clock cycle (required for the unrolled MAC at II=1).
    // For a 'static const' array the tool often inlines the constants directly
    // into the DSP multipliers; the partition pragma makes that explicit.
#pragma HLS ARRAY_PARTITION variable=h complete dim=1

    // -------------------------------------------------------------------------
    // Shift register — FIR delay line
    // 'static': persists across calls in C-sim (correct stream behaviour) and
    // maps to a register array in RTL. With ap_ctrl_hs the array is reset to
    // zero on ap_rst assertion. The explicit '= {}' guarantees zero-init in
    // C-simulation on the first call.
    // -------------------------------------------------------------------------
    static data_t shift_reg[128] = {};
#pragma HLS ARRAY_PARTITION variable=shift_reg complete dim=1

    // =========================================================================
    //  Sample-processing loop  —  one output per clock cycle at II=1
    // =========================================================================
    for (int i = 0; i < count; i++) {
#pragma HLS PIPELINE II=1

        // ── Read one AXI-Stream sample ───────────────────────────────────────
        axis_t in_val = in_stream.read();

        // ── Raw-bit import from AXI to Q4.12 (no arithmetic conversion) ──────
        //
        //  in_val.data is ap_uint<16> — the 16-bit Q4.12 bit pattern sent by
        //  the host.  We copy the bits directly into data_t WITHOUT any integer
        //  arithmetic conversion.  This avoids the overflow that would occur if
        //  the host sends, e.g., a scaled integer like 1800 and we tried to
        //  interpret that as the numeric value 1800.0 in Q4.12 (max ≈ 8).
        //
        //  The host is responsible for sending correct Q4.12 patterns; see the
        //  scaling requirement in the header file.
        data_t x;
        x.range(15, 0) = in_val.data;   // bit-level copy, no value conversion

        // ── Shift the delay line ─────────────────────────────────────────────
        for (int j = 127; j > 0; j--) {
#pragma HLS UNROLL
            shift_reg[j] = shift_reg[j - 1];
        }
        shift_reg[0] = x;

        // ── 128-tap multiply-and-accumulate ───────────────────────────────────
        //
        //  With full unroll, HLS synthesises 128 parallel multipliers and a
        //  binary adder tree.  At 100 MHz this should meet timing; see the
        //  synthesis concerns section if II > 1 is reported.
        acc_t acc = 0;
        for (int j = 0; j < 128; j++) {
#pragma HLS UNROLL
            acc += shift_reg[j] * h[j];
        }

        // ── Write output sample ───────────────────────────────────────────────
        //
        //  Truncate acc_t (Q4.20, 24 bits) to data_t (Q4.12, 16 bits), then
        //  copy the raw 16-bit Q4.12 pattern to the AXI data field.
        //
        //  This preserves the fractional information that "(short)acc" would
        //  have discarded.  The Python receiver interprets the output as:
        //    float_val = numpy.frombuffer(buf, dtype=numpy.int16) / 4096.0
        axis_t out_val;
        out_val.data = data_t(acc).range(15, 0); // truncate, then raw-bit export
        out_val.keep = in_val.keep;
        out_val.strb = in_val.strb;
        out_val.last = (i == count - 1);          // bool → ap_uint<1>
        out_stream.write(out_val);
    }
}

