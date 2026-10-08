// =============================================================================
// ecg_bandpass_filter_tb.cpp
// Vitis Unified IDE 2025.1.1 - C Simulation testbench
// =============================================================================

#include "ecg_bandpass_filter.h"
#include "ap_int.h"

#include <cstdio>
#include <cmath>

// -----------------------------------------------------------------------------
// Mathematical constant
// -----------------------------------------------------------------------------
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// =============================================================================
// Q4.12 conversion helpers
// =============================================================================
//
// The 16-bit AXI DATA field carries signed Q4.12 values.
//
// Real value = signed_raw / 4096.0
//
// Examples:
//   +1.0 -> +4096
//   +0.5 -> +2048
//   -1.0 -> -4096
// =============================================================================

static inline ap_uint<16> double_to_q412(double v)
{
    if (v >= 8.0)
        v = 7.999755859375;

    if (v < -8.0)
        v = -8.0;

    data_t fx(v);

    return fx.range(15, 0);
}

static inline double q412_to_double(ap_uint<16> raw)
{
    data_t fx;

    // Interpret raw 16-bit bits as signed Q4.12
    fx.range(15, 0) = raw;

    return fx.to_double();
}

// =============================================================================
// Test parameters
// =============================================================================

static const int FS = 360;

// Use 128 samples for the FIR startup transient.
// Then analyze 9 seconds of steady-state data.
//
// 9 seconds gives integer numbers of cycles for:
//   5 Hz   -> 45 cycles
//   50 Hz  -> 450 cycles
//   200 Hz -> 1800 cycles
//
// NOTE: 200 Hz is above Nyquist (180 Hz) and therefore aliases to 160 Hz.
// =============================================================================

static const int N_SKIP = 128;
static const int N_ANALYSIS = 9 * FS;
static const int N_TOTAL = N_SKIP + N_ANALYSIS;

// =============================================================================
// Main
// =============================================================================

int main()
{
    hls::stream<axis_t> in_stream("in_stream");
    hls::stream<axis_t> out_stream("out_stream");

    // =========================================================================
    // Build composite test signal
    // =========================================================================
    //
    // Components:
    //
    //   5 Hz    amplitude = 1.0   -> IN BAND
    //   50 Hz   amplitude = 0.5   -> OUT OF BAND
    //   200 Hz  amplitude = 0.3   -> OUT OF BAND
    //
    // IMPORTANT:
    // At Fs = 360 Hz, 200 Hz aliases to 160 Hz.
    //
    // Scale factor = 4.0
    //
    // Maximum theoretical composite magnitude is:
    //
    //   (1.0 + 0.5 + 0.3) * 4 = 7.2
    //
    // which fits inside the Q4.12 range [-8, +7.999755...].
    // =========================================================================

    const double SCALE = 4.0;

    for (int i = 0; i < N_TOTAL; i++)
    {
        double t = static_cast<double>(i) / FS;

        double val =
              1.0 * std::sin(2.0 * M_PI * 5.0 * t)
            + 0.5 * std::sin(2.0 * M_PI * 50.0 * t)
            + 0.3 * std::sin(2.0 * M_PI * 200.0 * t);

        double scaled = val * SCALE;

        axis_t pkt;

        pkt.data = double_to_q412(scaled);

        // 16-bit DATA = 2 valid bytes
        pkt.keep = 0x3;
        pkt.strb = 0x3;

        pkt.last = (i == N_TOTAL - 1);

        in_stream.write(pkt);
    }

    // =========================================================================
    // Run filter
    // =========================================================================

    ecg_bandpass_filter(in_stream, out_stream, N_TOTAL);

    // =========================================================================
    // Collect output
    // =========================================================================

    double output[N_TOTAL];

    for (int i = 0; i < N_TOTAL; i++)
    {
        axis_t pkt = out_stream.read();

        output[i] = q412_to_double(pkt.data);
    }

    // =========================================================================
    // Frequency correlation
    // =========================================================================
    //
    // We project the steady-state output onto sine waves at the three
    // test frequencies.
    //
    // 200 Hz is above Nyquist and aliases to 160 Hz in the sampled sequence.
    // Using 200 Hz here still corresponds to the same sampled sinusoid as the
    // 160 Hz alias, apart from the expected phase/sign relationship.
    // =========================================================================

    double corr_5 = 0.0;
    double corr_50 = 0.0;
    double corr_200 = 0.0;

    const int n_valid = N_ANALYSIS;

    for (int i = N_SKIP; i < N_TOTAL; i++)
    {
        double t = static_cast<double>(i) / FS;

        corr_5 +=
            output[i] * std::sin(2.0 * M_PI * 5.0 * t);

        corr_50 +=
            output[i] * std::sin(2.0 * M_PI * 50.0 * t);

        corr_200 +=
            output[i] * std::sin(2.0 * M_PI * 200.0 * t);
    }

    // One-sided amplitude estimate
    double amp_5 =
        2.0 * std::fabs(corr_5) / n_valid;

    double amp_50 =
        2.0 * std::fabs(corr_50) / n_valid;

    double amp_200 =
        2.0 * std::fabs(corr_200) / n_valid;

    // =========================================================================
    // Relative attenuation
    // =========================================================================

    double ratio_50 =
        (amp_5 > 1e-9) ? (amp_50 / amp_5) : 999.0;

    double ratio_200 =
        (amp_5 > 1e-9) ? (amp_200 / amp_5) : 999.0;

    // =========================================================================
    // Acceptance thresholds for this C-simulation test
    // =========================================================================

    const double THR_50 = 0.045;
    const double THR_200 = 0.020;

    // Input 5 Hz component amplitude = SCALE = 4.0.
    // Require at least 70% of that amplitude.
    const double THR_5_MIN = 2.8;

    bool pass_5hz =
        (amp_5 >= THR_5_MIN);

    bool pass_50hz =
        (ratio_50 <= THR_50);

    bool pass_200hz =
        (ratio_200 <= THR_200);

    // =========================================================================
    // Print report
    // =========================================================================

    std::printf("\n");
    std::printf("========================================================\n");
    std::printf(" ECG Bandpass Filter - C Simulation Verification\n");
    std::printf("========================================================\n");

    std::printf(
        "Signal: 5 Hz (x1.0) + 50 Hz (x0.5) + 200 Hz (x0.3)\n");

    std::printf(
        "Sampling rate: %d Hz\n", FS);

    std::printf(
        "200 Hz aliases to 160 Hz at this sampling rate.\n");

    std::printf(
        "Scale factor: %.1f\n", SCALE);

    std::printf(
        "Samples: %d total, %d startup, %d evaluated\n\n",
        N_TOTAL,
        N_SKIP,
        N_ANALYSIS);

    std::printf(
        "FREQUENCY  OUTPUT AMP   STATUS\n");

    std::printf(
        "---------  -----------  --------\n");

    std::printf(
        "   5 Hz    %8.5f    %s\n",
        amp_5,
        pass_5hz ? "PASS" : "FAIL");

    std::printf(
        "  50 Hz    %8.5f    %s   ratio=%f\n",
        amp_50,
        pass_50hz ? "PASS" : "FAIL",
        ratio_50);

    std::printf(
        " 200 Hz    %8.5f    %s   ratio=%f\n",
        amp_200,
        pass_200hz ? "PASS" : "FAIL",
        ratio_200);

    // =========================================================================
    // Startup samples
    // =========================================================================

    std::printf("\nFirst 5 startup output samples:\n");

    for (int i = 0; i < 5; i++)
    {
        std::printf(
            "  out[%3d] = %+.6f\n",
            i,
            output[i]);
    }

    // =========================================================================
    // Steady-state samples
    // =========================================================================

    std::printf(
        "\nSteady-state samples [%d .. %d]:\n",
        N_SKIP,
        N_SKIP + 4);

    for (int i = N_SKIP; i < N_SKIP + 5; i++)
    {
        double t =
            static_cast<double>(i) / FS;

        double expected_5 =
            SCALE *
            std::sin(2.0 * M_PI * 5.0 * t);

        std::printf(
            "  out[%4d] = %+.6f  "
            "(5 Hz reference: %+.6f)\n",
            i,
            output[i],
            expected_5);
    }

    // =========================================================================
    // Overall result
    // =========================================================================

    bool all_pass =
        pass_5hz &&
        pass_50hz &&
        pass_200hz;

    std::printf("\n");

    if (all_pass)
    {
        std::printf("*** C SIMULATION PASSED ***\n");
    }
    else
    {
        std::printf("*** C SIMULATION FAILED ***\n");
    }

    std::printf(
        "========================================================\n\n");

    return all_pass ? 0 : 1;
}

