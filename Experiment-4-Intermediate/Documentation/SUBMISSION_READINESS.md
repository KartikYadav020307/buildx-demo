# Organizer checklist audit - Experiment 4

Audit: 9 October 2026 (IST). Reference: repository-root `Submission_Guidelines/documents_req.pdf`.

**Required technical documentation and saved implementation/test evidence are present. Submission is not 100% complete.** The final demo link is intentionally blank, the final video must cover the requested content, and the team name remains pending. The user confirmed both members and registration numbers. No arbitrary percentage is assigned.

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
| Images/board_setup.jpg | Present | User-supplied real PYNQ-Z2/USB/Ethernet photo |
| Images/hardware_output.jpg | Present | Final actual VIO decimal/signed screenshot |
| Original FPGA programming files | Present | Matching original 6 October 21:08 .bit/.ltx, exact bytes retained |
| Original routed reports/logs | Present | Success marker, batch log/journal, timing/clock/utilization/DRC/methodology/bus-skew |
| FPGA project files | Present with relocation caveat | FPGA_Project/ contains original laptop .xpr and clock/VIO IP source archive; original paths/run settings retained, generated caches/runs excluded; Tcl/launcher recreate a clean project |
| Physical numeric validation | Present | Original 45-row CSV and independent audit: 45/45 exact reference matches |
| Permanent radix fix | Present | Reader honors INPUT_VALUE_RADIX; current script retains live-tested correction |
| Final video / Drive URL | Pending by request | Video_Link.txt is zero bytes; final narration/content/upload remain |
| Verified team identity | Partly complete | Shanshank Pulipati (25BEC0573), Kartik Yadav (25BEC0087) confirmed; team name pending |
| Current local simulation | Passed | Full regression and three-case waveform test rerun successfully with Vivado XSim 2025.1.1 on 9 October 2026 (IST); current_xsim files preserved |
| Team-wide final report / all five packages | Repository-wide pending | 3/4/5 linked; other completed packages and combined final PDF needed |
| Repository name convention | Needs review | Selected buildx-demo remains; organizer requests FPGA-Build-Challenge-TeamLeader name |

## Remaining inputs

1. Final narrated Project 4 video Drive URL when ready; intentionally leave it blank now.
2. Team name for README/report identity; both member names and registration numbers are now filled.
3. If your evaluator specifically requires a **Vivado GUI schematic**, supply that capture. The organizer requests an RTL schematic image; the included actual Yosys schematic meets that file category and is labeled accurately. The native source project is now archived; a full generated workspace is not claimed.

The earlier work history describes a short hardware clip demonstrating the board and three cases. The user has now supplied a Drive recording titled Video Demo(script to be voice-over).mp4; its metadata is verified and its URL is preserved in Evidence/RAW_VIDEO.md. This task has not reviewed that linked recording's contents or verified public judge access. Check the final edit for introduction, problem, architecture/RTL in software, working setup/demonstration and conclusion. Video_Link.txt stays empty as requested.

The latest successful artifacts were separated from old/failed/mocked runs. Historical review notes retain their old pending-board wording as historical evidence; later CSV/screenshots establish current physical completion.
