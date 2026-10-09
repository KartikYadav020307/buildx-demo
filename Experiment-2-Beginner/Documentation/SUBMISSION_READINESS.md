# Organizer checklist audit - Experiment 2

Audit: 9 October 2026. Reference: repository-root `Submission_Guidelines/documents_req.pdf`.

**The build and physical verification are complete. All required Project 2 technical-document categories are present. The final submission is not 100% complete.** Final video remains pending; original full routed reports/native project files have not been recovered. No arbitrary percentage is assigned.

| Organizer item | Status | Evidence / remaining work |
| --- | --- | --- |
| Experiment-2-Beginner folder | Present | Required folder name |
| Documentation PDF | Present | `Project2_Radar_Report.pdf`, all seven sections |
| 1. Objective | Documented | Runtime-sensitive streaming CA-CFAR on synthetic unsigned magnitudes |
| 2. Block diagram | Present | `Images/block_diagram.png`; actual architecture, source-derived |
| 3. RTL design/hierarchy | Documented | Original three modules/XDC, genuine Yosys top schematic and hierarchy table |
| 4. Simulation results | Present | Independent scoreboard, actual VCD/waveform/CSV, Icarus transcripts and original XSim output |
| 5. Hardware implementation | Present with report-retrieval caveat | Actual photos/PASS screenshot, matching BIT/LTX, 39 passing board CSV rows and successful full build log |
| 6. Applications | Documented | Reusable magnitude-stream threshold stage; real radar integration remains future work |
| 7. Conclusion/future scope | Documented | Verified exact detections/timing/latency; honest scope and missing report review |
| RTL and constraints | Present | `cfar_core.v`, `radar_demo.v`, `radar_top.v`, `pynq_z2.xdc` |
| Testbench | Present | Real names retained: `tb_cfar_core.sv`, `tb_radar_demo.sv` |
| Simulation/waveform.png | Present | Plot of the supplied real Icarus VCD, not a recreated mock waveform |
| Simulation/transcript.txt | Present | Exact supplied local simulator output, with provenance; original XSim log also present |
| Simulation/simulation_report.pdf | Present | Tests, waveform, transcript, expected values and reproduction |
| Images/rtl_schematic.png | Present, source-elaborated | Genuine Yosys output; proprietary VIO and clock primitives not implemented by this offline check; SVG/DOT/netlist/transcript included |
| Images/board_setup.jpg | Present | Original user-supplied PYNQ-Z2 photo |
| Images/hardware_output.jpg | Present | Original user photo of the board and Vivado passing hardware console |
| FPGA project files | Present for reproducible creation; native archive incomplete | Original RTL/Tcl/build dependencies and matching BIT/LTX included; generated `.xpr`/IP source directory not supplied |
| Optional resource utilization | Not supplied | No invented LUT/FF/BRAM/DSP or power measurements; retrieve original `Reports/` |
| Routed warning review | Partial | Full successful log retained; methodology, unconstrained-path and bus-skew report text not supplied |
| Final demo/video Drive link | Pending by user request | `Video_Link.txt` is intentionally zero bytes; raw recording provenance and narration guide retained |
| Team identity | Complete | Beyond Boolean; Shanshank Pulipati 25BEC0573; Kartik Yadav 25BEC0087 |

## Inputs still needed from the user

1. Upload the successful Project 2 **`Reports` folder as a ZIP**, plus `Build/run_20261008_222502/project2_radar.runs/impl_1/radar_top_bus_skew_routed.rpt` if it is outside that folder. Reports include timing, utilization, DRC, methodology, clock/pulse-width/check-timing and routed checkpoint. They were produced on the laptop but are not among the supplied uploads/Drive files.
2. If available, upload the **generated `project2_radar.xpr` with its IP/project source directory**, preferably a Vivado source archive that excludes generated run caches. The build Tcl recreates the project, but a substitute `.xpr` has not been fabricated.
3. Finish the recorded video's narration/edit, check judge access, then provide its final URL. This URL is deliberately left blank now.

The raw 53.21-second recording was visually sampled throughout. It shows the real board, successful hardware checks, noise rejection, standard targets and sensitivity changes. It contains no visual introduction, architecture/RTL walkthrough or concluding presentation segment. Narration/edit remains pending; anonymous judge access has not been verified. The original September AXI radar artifacts and standalone core screenshots were excluded because they do not identify this October build.

## Existing Projects 3, 4 and 5

The latest existing Projects 3, 4 and 5 were read and preserved. Project 3 now contains the required technical-document categories, with its final video link blank. Project 4 contains the required technical categories and a native source archive, with its final narrated video/link pending. Project 5 includes hardware exports and its linked demo, with the recorded presentation-content limitations documented in its checklist. Their existing references to missing team identity are stale: the root README confirms Beyond Boolean and both members. No Project 2 evidence is substituted for another experiment.

The whole entry additionally needs Experiment 1, the all-five-project combined `Final_Report/Beyond_Boolean_Final_Report.pdf`, and review of the requested repository-name format. These are separate from completion of Project 2's hardware.
