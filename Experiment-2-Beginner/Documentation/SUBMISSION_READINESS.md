# Organizer checklist audit - Experiment 2

Audit: 10 October 2026 (Asia/Kolkata). Reference: repository-root `Submission_Guidelines/documents_req.pdf`.

**Required technical file categories and the supplied final video URL are present. Video playback/content and anonymous judge access remain unverified.** The saved physical evidence, native archive and routed reports remain unchanged. Independent XSim/checkpoint checks are recorded in FINAL_VALIDATION.md; no new board execution is claimed.

| Organizer item | Status | Evidence / remaining work |
| --- | --- | --- |
| Experiment-2-Beginner folder | Present | Required folder name |
| Documentation PDF | Present | `Project2_Radar_Report.pdf`, all seven sections |
| 1. Objective | Documented | Runtime-sensitive streaming CA-CFAR on synthetic unsigned magnitudes |
| 2. Block diagram | Present | `Images/block_diagram.png`; actual architecture, source-derived |
| 3. RTL design/hierarchy | Documented | Original three modules/XDC, genuine Yosys top schematic and hierarchy table |
| 4. Simulation results | Present | Independent scoreboard, actual VCD/waveform/CSV, Icarus transcripts and original XSim output |
| 5. Hardware implementation | Complete with disclosed warnings | Actual photos/PASS screenshot, matching BIT/LTX, 39 passing board CSV rows and successful full build log |
| 6. Applications | Documented | Reusable magnitude-stream threshold stage; real radar integration remains future work |
| 7. Conclusion/future scope | Documented | Verified exact detections/timing/latency; honest scope and completed routed-report review |
| RTL and constraints | Present | `cfar_core.v`, `radar_demo.v`, `radar_top.v`, `pynq_z2.xdc` |
| Testbench | Present | Real names retained: `tb_cfar_core.sv`, `tb_radar_demo.sv` |
| Simulation/waveform.png | Present | Plot of the supplied real Icarus VCD, not a recreated mock waveform |
| Simulation/transcript.txt | Present | Exact supplied local simulator output, with provenance; original XSim log also present |
| Simulation/simulation_report.pdf | Present | Tests, waveform, transcript, expected values and reproduction |
| Images/rtl_schematic.png | Present, source-elaborated | Genuine Yosys output; proprietary VIO and clock primitives not implemented by this offline check; SVG/DOT/netlist/transcript included |
| Images/board_setup.jpg | Present | Original user-supplied PYNQ-Z2 photo |
| Images/hardware_output.jpg | Present | Original user photo of the board and Vivado passing hardware console |
| FPGA project files | Complete | Original successful `.xpr`/IP source archive, RTL/Tcl/build dependencies and matching BIT/LTX included |
| Optional resource utilization | Complete | Original routed report: 2010 LUTs, 3329 FF, 0 BRAM, 0 DSP including VIO/debug hub; no measured power claimed |
| Routed warning review | Complete with warnings disclosed | Eight original reports; four bus-skew constraints MET, 0 unconstrained internal endpoints; DRC five Warning checks and methodology four, reviewed in `Reports/README.md` |
| Final demo/video Drive link | Supplied; content/access review incomplete | `Video_Link.txt` contains the supplied final Drive URL; preview title 2nd final.mp4, blank player during review |
| Team identity | Complete | Beyond Boolean; Shanshank Pulipati 25BEC0573; Kartik Yadav 25BEC0087 |

## Remaining verification

Watch the final edited video and check introduction/problem, architecture/RTL in software, physical setup and working demonstration, and conclusion. Verify its technical claims against the saved results and test access while signed out. The exact final URL is recorded and checked by Tools/validate_evidence.py. The browser reached the correct Drive file title but showed a blank preview; web retrieval failed. Historical sampled raw-footage observations do not establish final-video content.

No missing native files or hardware results are fabricated. All original evidence files remain. Current project and simulation PDFs retain the original equations, values and genuine figures, with final-link status and the separate XSim rerun updated; previous versions are preserved in Archive subfolders.

Repository-wide recommendations: refresh the Project 1-2 sections and status in the combined report and root README after this audit. Those root files are preserved under the user's scope restriction. The supplied organizer PDF is identical to the repository copy; its printed deadline is 23 September 2026, and its naming examples differ between leader and team name. Confirm current organizer instructions without inferring an extension or renaming the repository.
