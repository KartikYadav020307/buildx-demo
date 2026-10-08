# Organizer checklist audit — Experiment 3

Audit date: 8 October 2026. Reference: `Submission_Guidelines/documents_req.pdf`.
**Project 3 is not 100% submission-complete.** A folder layout or a report heading
does not substitute for the required evidence. No unsupported percentage is assigned.

| Organizer item | Status | Evidence / remaining work |
| --- | --- | --- |
| Documentation PDF | Present, evidence incomplete | `Project3_ECG_Report.pdf` has all seven requested sections; team identity and missing captures still need completion |
| 1. Objective | Documented | Custom FPGA FIR preprocessing; ARM peak analysis; recorded replay scope |
| 2. Block diagram | Documented | `Images/block_diagram.png`, reconstructed from recovered `system.bd`, explicitly labeled |
| 3. RTL design and hierarchy | Documented | Original HLS source, generated top/dependencies, wrapper, packaged IP and BD |
| 4. Simulation results | Partial | Actual HLS C-simulation passed; separate RTL testbench/waveforms/transcript/report not supplied |
| 5. Hardware implementation | Partial | Executed board notebook, original plots/JSON/CSV, matching BIT/HWH/XSA and resource/timing/DRC reports; physical setup photo and GUI captures still missing |
| 6. Applications | Documented | Report section 6 |
| 7. Conclusion and future scope | Documented | Report section 7 with stated limitations |
| RTL and constraints | Present | Generated top and all packaged Verilog dependencies; genuine generated OOC/IP XDC; no claimed custom pin XDC |
| `Testbench/tb_top.v` | Missing | Only original HLS C++ testbench exists in supplied evidence |
| `Simulation/waveform.png` | Missing | Requires running and capturing an actual RTL simulation |
| `Simulation/transcript.txt` | Missing | Existing HLS C logs are preserved under their actual names; they are not an RTL transcript |
| `Simulation/simulation_report.pdf` | Missing | Requires a report from the genuine RTL simulation and its testbench outputs |
| `Images/block_diagram.png` | Present | Source-derived drawing; not a Vivado screenshot |
| `Images/rtl_schematic.png` | Missing | Export/capture the real elaborated or synthesized schematic in Vivado |
| `Images/board_setup.jpg` | Missing | Photograph the actual PYNQ-Z2, microSD, power, Ethernet and USB connections |
| `Images/hardware_output.jpg` | Missing | Capture the actual Jupyter execution/checks and graph on the board; original output plots are already preserved as PNGs |
| Final narrated video and Drive URL | Intentionally pending | `Video_Link.txt` is zero bytes as requested; recording guide is provided |
| FPGA project files | Present with rebuild caveat | BIT/HWH/XSA, HLS source/IP, RTL, BD and project descriptor; complete original workspaces remain in linked Drive backups |
| GitHub experiment folder | Present | Published under the selected `buildx-demo` repository as `Experiment-3-Intermediate` |
| Team name, members, registration numbers | Pending | Verified team list was not supplied; complete root README and report identity |
| All-five project summaries and combined final PDF | Outside this Project 3 upload | Other four completed project packages/reports and verified team details were not supplied for this audit |
| Repository naming convention | Needs review | Organizer requests `FPGA-Build-Challenge-TeamLeader name`; selected repo remains `buildx-demo` |

## Is the fifth report section complete?

Section 5, **Hardware Implementation**, already documents the saved working-board
results and measured resource utilization. It is not 100% complete against the
organizer's evidence requirements: physical setup and actual software/hardware
screenshots still need capture. No new board test is claimed by this upload.

## Why the remaining evidence is absent

The original HLS logs demonstrate C simulation, not an independently run Verilog
RTL simulation. Renaming those files would misrepresent their provenance. The
provided archives contain plots and executed notebooks, but no real board photo
or exported Vivado schematic capture. Those require access to the board/Vivado
session. The final video was explicitly requested to remain pending. Team data
and the other four project reports are needed for the team-wide final report.

## Completion steps

1. Run a genuine Verilog RTL testbench against the included HLS-generated core
   and dependencies; verify outputs and AXI-stream handshakes. Save `tb_top.v`,
   `waveform.png`, `transcript.txt` and `simulation_report.pdf` in the requested
   folders, with the simulator version and actual pass/fail results.
2. Capture `rtl_schematic.png` from Vivado, `board_setup.jpg` from the physical
   board, and `hardware_output.jpg` from the real board notebook session.
3. Add those captures and simulation evidence to sections 4 and 5 of the PDF.
4. Fill verified team details. Record/upload the narrated demo and add its URL
   when ready. Assemble the all-five-project final report after the remaining
   experiment reports are available.

The repository contains Project 3 evidence. This audit does not certify a
separate Experiment 5 / Advanced project.
