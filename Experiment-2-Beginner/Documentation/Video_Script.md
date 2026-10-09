# Narration and final edit guide

Use the already recorded real hardware footage. The supplied raw hardware clip lacks a visual introduction, architecture/RTL walkthrough and conclusion. Add those segments and the voiceover. Do not say that the waveform is RF data or that an ML classifier is running.

1. **Introduction/problem:** "We are Beyond Boolean: Shanshank Pulipati and Kartik Yadav. Our Project 2 demonstrates a reconfigurable FPGA radar target-detection stage on the PYNQ-Z2. A fixed threshold can reject weak targets or respond incorrectly to changing backgrounds. We demonstrate a local-background threshold on synthetic magnitude samples."
2. **Architecture/RTL:** Show the block diagram and the real `radar_top`, `radar_demo` and `cfar_core` files. "The FPGA generates 100 samples per frame. A 21-cell window contains sixteen training cells, four guards and the cell under test. The detector compares against the full threshold. VIO selects the scenario and factor, then reads retained results over JTAG."
3. **Connections:** Show the board/USB cable and normal power/boot setup. "The PYNQ-Z2 processes and retains results at 50 MHz. The laptop programs and observes the logic through Vivado Hardware Manager."
4. **Noise and standard targets:** Match the corresponding recorded commands. "Noise-only produces zero detections. The three-target frame returns exactly three detections at indices 30, 60 and 85, with all 80 complete windows processed."
5. **Reconfiguration:** "The same weak target is rejected at factor four and detected at factor two. We change the factor between frames without another bitstream."
6. **Gaps/overflow, if shown:** "Valid-sample gaps preserve the exact target positions. The 19-bit comparison prevents a saturated display value from causing an overflow-related detection."
7. **Conclusion:** "All 32 scenario, factor and gap combinations passed on the board. Continuous frames take 104 FPGA cycles, or 2.08 microseconds, excluding host/JTAG overhead. This is a verified detection stage; acquisition, FFT and calibrated real-radar evaluation are future work."

If citing timing, use the actual WNS 12.176 ns, WHS 0.018 ns and WPWS 2.000 ns. Resource/power figures are not supplied. Finalize narration/edit, check that judges can open the Drive URL, then fill `Video_Link.txt`. It is deliberately blank in this upload.
