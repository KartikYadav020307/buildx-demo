# Organizer checklist audit - Experiment 2

Audit: 9 October 2026. Reference: repository-root `Submission_Guidelines/documents_req.pdf`.

**The build and physical verification are complete. All required Project 2 technical-document categories are present. The final submission is not 100% complete.** Only the final video and its accessible Drive link remain pending for Project 2. Original routed reports, checkpoint and native project files have now been recovered and verified. No arbitrary percentage is assigned.

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
| Final demo/video Drive link | Pending by user request | `Video_Link.txt` is intentionally zero bytes; raw recording provenance and narration guide retained |
| Team identity | Complete | Beyond Boolean; Shanshank Pulipati 25BEC0573; Kartik Yadav 25BEC0087 |

## Inputs still needed from the user

1. Finish the recorded video's narration/edit to cover introduction, problem statement, architecture/RTL, hardware setup/demo and conclusion; check judge access, then provide its final Drive URL. `Video_Link.txt` remains deliberately blank now.

No further original Project 2 reports or native project files are requested. The full ZIP supplied both earlier missing inputs.

The raw 53.21-second recording was visually sampled throughout. It shows the real board, successful hardware checks, noise rejection, standard targets and sensitivity changes. It contains no visual introduction, architecture/RTL walkthrough or concluding presentation segment. Narration/edit remains pending; anonymous judge access has not been verified. The original September AXI radar artifacts and standalone core screenshots were excluded because they do not identify this October build.

## Existing Projects 3, 4 and 5

The latest existing Projects 3, 4 and 5 were read and preserved. Project 3 now contains the required technical-document categories, with its final video link blank. Project 4 contains the required technical categories and a native source archive, with its final narrated video/link pending. Project 5 includes hardware exports and its linked demo, with the recorded presentation-content limitations documented in its checklist. Their existing references to missing team identity are stale: the root README confirms Beyond Boolean and both members. No Project 2 evidence is substituted for another experiment.

The whole entry additionally needs Experiment 1, the all-five-project combined `Final_Report/Beyond_Boolean_Final_Report.pdf`, and review of the requested repository-name format. These are separate from completion of Project 2's hardware.
