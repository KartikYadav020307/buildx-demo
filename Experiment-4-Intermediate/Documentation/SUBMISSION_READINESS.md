# Organizer checklist audit - Experiment 4

Audit: 9 October 2026 (IST). Reference: repository-root `Submission_Guidelines/documents_req.pdf`.

**Required technical files, team identity and final demo link are present.**
Final video content and public reviewer access still need review; see VIDEO_REVIEW.md.

| Organizer item | Status | Evidence / remaining work |
| --- | --- | --- |
| Experiment-4-Intermediate folder | Present | Correct required folder name |
| Documentation PDF / Objective | Present | Project4_NN_Report.pdf, seven sections; fair frozen-model architecture comparison |
| Block diagram | Present | Images/block_diagram.png |
| RTL structure and hierarchy | Present | Original four .sv modules, shared headers, XDC; report section 3 |
| Simulation waveforms and testbench outputs | Present | Actual VCD/PNG, measured timestamps, original XSim and fresh Icarus transcripts |
| Hardware screenshots and results | Present | Board photo, VIO/PASS/three-case screenshots, original hardware CSV |
| Applications / Conclusion | Documented | Report sections 6 and 7 |
| RTL/constraints folder | Present | SystemVerilog source and corrected pynq_z2.xdc |
| Testbench folder | Present | Original tb_nn.sv and supplemental tb_nn_waveform.sv; real module names retained |
| Simulation/waveform.png | Present | Rendered from actual included VCD |
| Simulation/transcript.txt | Present | Fresh 4,502-vector-per-core regression output |
| Simulation/simulation_report.pdf | Present | Simulator, coverage, output, waveform and reproduction |
| Images/block_diagram.png | Present | Original source-derived diagram |
| Images/rtl_schematic.png | Present, source-derived | Genuine Yosys schematic, proprietary clock/VIO black boxes; not a Vivado GUI capture. SVG/netlist/tool transcript/recipe included |
| Images/board_setup.jpg | Present | Team real PYNQ-Z2/USB/Ethernet photo |
| Images/hardware_output.jpg | Present | Final actual VIO decimal/signed screenshot |
| Original FPGA programming files | Present | Matching original 6 October 21:08 .bit/.ltx, exact bytes retained |
| Original routed reports/logs | Present | Success marker, batch log/journal, timing/clock/utilization/DRC/methodology/bus-skew |
| FPGA project files | Present with relocation caveat | FPGA_Project/ contains original laptop .xpr and clock/VIO IP source archive; original paths/run settings retained, generated caches/runs excluded; Tcl/launcher recreate a clean project |
| Physical numeric validation | Present | Original 45-row CSV and independent audit: 45/45 exact reference matches |
| Permanent radix fix | Present | Reader honors INPUT_VALUE_RADIX; current script retains live-tested correction |
| Final video / Drive URL | Link present | Video_Link.txt; content/access review pending |
| Verified team identity | Complete | Beyond Boolean; Shanshank Pulipati (25BEC0573), Kartik Yadav (25BEC0087) |
| Current local simulation | Passed | Full regression and three-case waveform test rerun successfully with Vivado XSim 2025.1.1 on 9 October 2026 (IST); current_xsim files preserved |
| Team-wide final report / all five packages | Present, outside this audit | All five folders and Final_Report/Beyond_Boolean_Final_Report.pdf exist; projects 1/2 retain their existing content; combined PDF sections 3–5 refreshed |
| Repository name convention | Needs review | Selected buildx-demo remains; organizer requests FPGA-Build-Challenge-TeamLeader name |

## Final review items

1. Review the final demo content and anonymous reviewer access (VIDEO_REVIEW.md).
2. Organizer naming convention: the repository is currently buildx-demo; confirm the required name before submission.
3. Confirm the organizer deadline or extension; the printed PDF lists 23 September 2026.

The native source project is archived. The RTL image is a genuine Yosys/Graphviz elaboration with vendor IP black boxes; the organizer requests an RTL schematic image and does not explicitly require a Vivado GUI export. Historical notes describe their original review date; raw logs and physical CSV/screenshots are preserved.
