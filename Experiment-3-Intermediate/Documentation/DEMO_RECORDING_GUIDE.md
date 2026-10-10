# Final demo recording guide

The final video URL is in Video_Link.txt. Record the actual board and a real notebook
run; use saved outputs only if clearly introduced as a previous saved run.

| Approximate time | Show | Explain |
| --- | --- | --- |
| 0–8 s | PYNQ-Z2 and actual power, microSD, Ethernet and PROG-UART connections | Project name, board and ECG noise-filtering problem |
| 8–20 s | Actual Vivado block design and HLS/Verilog code | ARM/DDR → AXI DMA → 128-tap FPGA FIR → DMA/DDR; Python peak analysis on ARM |
| 20–30 s | Jupyter overlay load and DMA detection | Matching BIT/HWH are loaded; `axi_dma_0` moves 16-bit Q4.12 samples |
| 30–43 s | Sine check output and plot | Exact reference comparison; 5 Hz gain and measured 50 Hz suppression |
| 43–55 s | Recorded ECG check and candidate peak plot | 12,288 prerecorded samples, six batches; peak count and estimated heart rate |
| 55–65 s | Final checks and board together | Conclusion, recorded replay scope and future live sensor/QRS work |

Show the values from the run being recorded; do not promise the earlier timing
will repeat exactly. Identify the signal as prerecorded MIT-BIH ECG, the FIR as
FPGA logic and the peak detector as Python on ARM. Save the executed notebook,
capture the required board/output photos and upload the narrated video to Drive
with reviewer access. Put its final URL alone in `../Video_Link.txt` when ready.
