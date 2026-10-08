// =============================================================================
// ecg_bandpass_filter.h
// 128-tap FIR ECG bandpass filter, 0.5 Hz to 40 Hz @ 360 Hz
// Target : PYNQ-Z2 (xc7z020clg400-1)
// Tool   : Vitis Unified IDE 2025.1.1
// =============================================================================

#ifndef ECG_BANDPASS_FILTER_H
#define ECG_BANDPASS_FILTER_H

#include "ap_fixed.h"
#include "hls_stream.h"
#include "ap_axi_sdata.h"

// =============================================================================
// AXI4-Stream packet type
// =============================================================================
//
// ap_axis<DataWidth, UserWidth, IdWidth, DestWidth>
//
// ap_axis<16, 0, 0, 0> provides:
//   data : 16 bits
//   keep : 2 bits
//   strb : 2 bits
//   last : 1 bit
//
// The 16-bit DATA payload is interpreted by this design as signed Q4.12.
//

typedef ap_axis<16, 0, 0, 0> axis_t;


// =============================================================================
// Fixed-point data types
// =============================================================================
//
// data_t = ap_fixed<16,4>
//
// Total width      : 16 bits
// Integer bits     : 4 bits, including sign bit
// Fractional bits  : 12 bits
// Resolution       : 2^-12 = 0.000244140625
// Approx. range    : -8.0 to +7.999755859375
//
// The host/software side must provide samples encoded as signed Q4.12
// values on the 16-bit AXI DATA field.
//
// Examples:
//   Real value  1.0  -> raw Q4.12 value  4096
//   Real value  0.5  -> raw Q4.12 value  2048
//   Real value -1.0  -> raw Q4.12 value -4096
//
// The accumulator is intentionally kept as ap_fixed<24,4> to match the
// current project specification. Actual accumulator headroom should be
// verified during C simulation and synthesis for the chosen signal scaling
// and filter coefficients.
//

typedef ap_fixed<16, 4> data_t;   // Q4.12
typedef ap_fixed<24, 4> acc_t;    // Q4.20


// =============================================================================
// Top-level HLS function
// =============================================================================

void ecg_bandpass_filter(
    hls::stream<axis_t>& in_stream,
    hls::stream<axis_t>& out_stream,
    int count
);

#endif // ECG_BANDPASS_FILTER_H

