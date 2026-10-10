# V-SPACE FPGA Build Challenge 2026

This is the selected team repository for the FPGA challenge. It contains
**Experiment 1: AES-128 Hardware Encryption Accelerator**,
**Experiment 2: Reconfigurable FPGA Radar Target Detection**,
**Experiment 3: FPGA ECG FIR Filtering and Peak Analysis**, **Experiment 4:
FPGA Neural Network Inference Accelerator**, and **Experiment 5:
Reconfigurable FPGA BNN Safety Response**.

## Team information

| Field | Value |
| --- | --- |
| Team name | Beyond Boolean |
| Team members | Shanshank Pulipati; Kartik Yadav |
| Registration numbers | Shanshank Pulipati: 25BEC0573; Kartik Yadav: 25BEC0087 |
| Selected FPGA board for all five experiments | PYNQ-Z2 |
| FPGA device | Xilinx Zynq-7000 XC7Z020 (`xc7z020clg400-1`) |

## Five-experiment summary

| Experiment | Difficulty | Summary / current package status |
| --- | --- | --- |
| [1](Experiment-1-Beginner/) | Beginner | Iterative AES-128 with VIO/JTAG; original RTL/testbench, saved passing vector, native project/IP, BIT/LTX, reports and required documentation included; result image provisional, final video blank, archived setup timing fails |
| [2](Experiment-2-Beginner/) | Beginner | Streaming 21-cell CA-CFAR radar detector; runtime sensitivity, exact 32-combination physical sweep, original BIT/LTX and required technical documentation included; final narrated video pending |
| [3](Experiment-3-Intermediate/) | Intermediate | 128-tap FPGA FIR filtering through AXI DMA; Python peak/heart-rate analysis on recorded ECG |
| [4](Experiment-4-Intermediate/) | Intermediate | Trained 4-to-4-to-3 Iris classifier; parallel/sequential RTL, 4/36-cycle inference, verified board results, original BIT/LTX, routed reports and native Vivado source archive |
| [5](Experiment-5-Advanced/) | Advanced | Two live-switchable BNN policy banks, latched emergency/watchdog controller; source, reports, routed build and physical evidence included |

Experiment 3 includes its completed seven-section report, original HLS source,
generated RTL/dependencies, Verilog testbench, actual passing 28,672-sample RTL
waveform/transcript/report, real Vivado schematic, board/Jupyter photographs,
build reports, matching BIT/HWH/XSA, executed board notebooks and saved results.
Its final demo URL is recorded in Video_Link.txt. See
[the Project 3 checklist](Experiment-3-Intermediate/Documentation/SUBMISSION_READINESS.md).

The organizer's original checklist is in
[`Submission_Guidelines/documents_req.pdf`](Submission_Guidelines/documents_req.pdf).
It requests one repository containing all five experiments and a combined team
report. The [combined team report](Final_Report/Beyond_Boolean_Final_Report.pdf)
contains all five project reports; the Project 3–5 sections and corresponding
status overview were refreshed on 10 October. Projects 1 and 2 retain their
existing content and limitations.
See [the whole-entry checklist](Final_Report/SUBMISSION_STATUS.md) for remaining items.

The requested naming convention is `FPGA-Build-Challenge-TeamLeader name`.
This upload uses the repository explicitly selected by the user, `buildx-demo`;
its current name does not follow that convention. All five technical packages
are present; the linked checklist distinguishes file coverage from remaining
video, evidence-quality and implementation issues.

## Experiment 1

[Project report](Experiment-1-Beginner/Documentation/Project1_AES_Report.pdf) | [Simulation report](Experiment-1-Beginner/Simulation/simulation_report.pdf) | [Submission checklist](Experiment-1-Beginner/Documentation/SUBMISSION_READINESS.md)

The original AES/VIO RTL, XDC, testbench, passing single-vector transcript/WDB,
source/IP project archive, matching BIT/LTX, routed checkpoint and original
reports are included. Architecture and structural wiring diagrams were drawn
from the preserved source. Genuine board and Hardware Manager captures are
included. The original result-video poster is provisional and needs a readable
completed-ciphertext replacement. The final video link is intentionally blank.
The saved 125 MHz routed design has WNS -0.104 ns and four setup-failing endpoints;
the passing 100 MHz behavioral test does not establish implementation timing
closure. No new board or Vivado execution is claimed by this packaging update.

## Experiment 4

[Project report](Experiment-4-Intermediate/Documentation/Project4_NN_Report.pdf) | [Simulation report](Experiment-4-Intermediate/Simulation/simulation_report.pdf) | [Submission checklist](Experiment-4-Intermediate/Documentation/SUBMISSION_READINESS.md)

The seven-section report, RTL/constraints, testbenches, real waveforms,
source-elaborated schematic, board/VIO screenshots, physical 45-case CSV and
original routed FPGA files are included. The unchanged RTL passed both test
suites again in Vivado XSim 2025.1.1 on 9 October 2026 (IST). The native project
descriptor/IP files are archived alongside reproducible build scripts.
The raw video is referenced in the evidence notes; the final edit is linked in
`Video_Link.txt`. See Documentation/VIDEO_REVIEW.md for content/access review status.

## Experiment 5

[Project report](Experiment-5-Advanced/Documentation/Project5_Report.pdf) | [Simulation report](Experiment-5-Advanced/Simulation/simulation_report.pdf) | [Submission checklist](Experiment-5-Advanced/Documentation/SUBMISSION_CHECKLIST.md)

[Final Project 5 demo](https://drive.google.com/file/d/11JItdx7IdNwuDhve5nBIV5tBiZsHoPV7/view?usp=sharing).

The report covers all seven organizer sections and preserves measured timing/resource and test evidence. The earlier hardware edit lacked presentation sections and ended with watchdog STOP still latched. A replacement final edit is linked; see the project video-review note for its content/access review status. Original core CSV/PASS exports are now included and verified. See the checklist for project-specific and whole-entry gaps.


## Experiment 2

[Project report](Experiment-2-Beginner/Documentation/Project2_Radar_Report.pdf) | [Simulation report](Experiment-2-Beginner/Simulation/simulation_report.pdf) | [Submission checklist](Experiment-2-Beginner/Documentation/SUBMISSION_READINESS.md)

The seven-section report, original RTL/constraints and testbenches, real VCD waveforms/transcript, source-elaborated RTL schematic, board photos, hardware PASS screenshot, 39 saved passing hardware rows and matching BIT/LTX are included. All eleven original build-source checksums match. The original successful native XPR/IP source archive, routed checkpoint and all eight routed reports are included. Four bus-skew constraints pass; resource counts and remaining DRC/methodology warnings are documented. The reproducible Vivado source flow remains included. Final Video_Link.txt remains blank; the raw recording is linked in the evidence notes.
