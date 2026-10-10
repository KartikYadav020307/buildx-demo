# Organizer requirements - Experiment 1

Audit: 10 October 2026. Reference: repository-root `Submission_Guidelines/documents_req.pdf`.

The required technical file categories have been assembled. The evidence is qualified: the final hardware-output image is provisional, the final video link is intentionally blank, and the saved routed implementation fails setup timing.

| Organizer item | File / status |
| --- | --- |
| Objective | Project1_AES_Report.pdf section 1 |
| Block diagram | Report section 2 and Images/block_diagram.png |
| RTL design, code structure and module hierarchy | Report section 3; original RTL and VIO XCI |
| Simulation waveforms and testbench outputs | Report section 4; original waveform photo, transcript and WDB |
| Hardware implementation | Report section 5; genuine board/programming captures; original reports and BIT/LTX |
| Applications | Report section 6 |
| Conclusion and future scope | Report section 7 |
| RTL and constraints | RTL/aes_top.v, aes_core.v, pynq.xdc, IP/vio_0/vio_0.xci |
| Testbench | Testbench/tb_aes_core.v; original module name retained |
| Simulation/waveform.png | Present; original photograph, tightly zoomed historical view |
| Simulation/transcript.txt | Present; unchanged original XSim passing log, one vector |
| Simulation/simulation_report.pdf | Present; configuration, vector, waveform, transcript and limits |
| Images/block_diagram.png | Present; architecture drawn from original source |
| Images/rtl_schematic.png | Present; exact source connectivity diagram, accurately labeled; not a Vivado GUI export |
| Images/board_setup.jpg | Present; genuine board photo recovered from the supplied conversation |
| Images/hardware_output.jpg | Provisional; low-resolution original video preview, replace with readable output evidence |
| FPGA project files | Original native XPR/source/IP ZIP, BIT/LTX and routed checkpoint |
| Optional utilization | Original reports; integrated design 3,222 LUTs / 3,912 registers |
| Final video Drive link | Video_Link.txt is intentionally zero bytes by instruction |

## Remaining inputs and work

1. **Original hardware-result evidence.** Supply the AES recording or a readable screenshot/frame showing plaintext, key and completed ciphertext `3ad77bb40d7a3660a89ecaf32466ef97`. The uploaded Gemini PDF retains only a small poster, not the original video. The other supplied Hardware Manager screenshots show input setup or programming, and cannot replace the completed-result evidence.
2. **Final demo presentation and URL.** The organizer requests introduction/problem, architecture/RTL, physical setup and working demonstration, and conclusion. Keep the link blank now; insert the accessible finished Drive URL when ready. No exact original video filename or laptop location was found in the supplied material.
3. **Timing qualification.** The saved 125 MHz routed build has WNS -0.104 ns, TNS -0.276 ns and four setup-failing endpoints in AES key expansion. Preserve this qualification until a corrected build and corresponding routed report prove closure. Simply relaxing the constraint does not change the board's physical clock.

The hardware preview and final video are incomplete evidence, not missing archive source files. All required original source/project assets found in the supplied ZIP have been recovered. Additional vectors and a cleaner waveform/Vivado schematic capture would strengthen the presentation; they are not additional organizer file categories.

## Locate the remaining original files

- Search the laptop's Desktop, Downloads, Videos, Documents and synced Drive/OneDrive folders for `.mp4`, `.mov`, `.mkv`, `.webm`, `.ipynb`, `.bit` and `.ltx`, sorting by the actual lab-demo date. Search names containing `aes`, `128`, `pynq`, `vivado`, `demo` and `screen`.
- Check the phone/gallery if the demo was filmed with a phone, and the cloud folder where that recording was uploaded. The supplied AES Drive folder contained the project ZIP; it did not supply a video URL.
- If Jupyter was opened at the PYNQ board's IP address, inspect the board's Jupyter file browser and `/home/xilinx/jupyter_notebooks` on its microSD. If Jupyter used `localhost` or `127.0.0.1`, inspect the laptop folder from which Jupyter was started. These are search locations, not verified AES filenames.
- The Windows student path and `/home/student/Documents/25BEC0087/aes128_core` shown in historical captures are lab-PC locations. The recovered source ZIP and BIT/LTX in this repository can be used without accessing that PC.

No other project's notebook, recording or build output is used as AES evidence. No new hardware run was performed during recovery or documentation.
