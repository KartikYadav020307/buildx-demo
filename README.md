# V-SPACE FPGA Build Challenge 2026

This is the selected team repository for the FPGA challenge. The repository tracks **Experiment 3 (Intermediate): FPGA ECG FIR Filtering and Peak Analysis**
and now includes **Experiment 5 (Advanced): Reconfigurable FPGA BNN Safety Response**.

## Team information

| Field | Value |
| --- | --- |
| Team name | Pending verified team details |
| Team members | Pending verified team details |
| Registration numbers | Pending verified team details |
| Selected FPGA board for Experiment 3 | PYNQ-Z2 |
| FPGA device | Xilinx Zynq-7000 XC7Z020 (`xc7z020clg400-1`) |

## Five-experiment summary

| Experiment | Difficulty | Summary / current package status |
| --- | --- | --- |
| 1 | Beginner | Details and completed package not supplied for this upload |
| 2 | Beginner | Details and completed package not supplied for this upload |
| [3](Experiment-3-Intermediate/) | Intermediate | 128-tap FPGA FIR filtering through AXI DMA; Python peak/heart-rate analysis on recorded ECG |
| 4 | Intermediate | Details and completed package not supplied for this upload |
| [5](Experiment-5-Advanced/) | Advanced | Two live-switchable BNN policy banks, latched emergency/watchdog controller; source, reports, routed build and physical evidence included |

Experiment 3 includes its report, original HLS source and testbench, generated
RTL/dependencies, build reports, matching BIT/HWH/XSA, executed board notebooks,
input data and saved board results. Its final video link is intentionally blank.
Read [the Project 3 checklist audit](Experiment-3-Intermediate/Documentation/SUBMISSION_READINESS.md)
for missing simulation and photographic evidence.

The organizer's original checklist is in
[`Submission_Guidelines/documents_req.pdf`](Submission_Guidelines/documents_req.pdf).
It requests one repository containing all five experiments and a combined team
report. The team-wide final report remains pending in `Final_Report/`.

The requested naming convention is `FPGA-Build-Challenge-TeamLeader name`.
This upload uses the repository explicitly selected by the user, `buildx-demo`;
its current name does not follow that convention. Team identity, the remaining
experiment packages and the final combined report still need completion.

## Experiment 5

[Project report](Experiment-5-Advanced/Documentation/Project5_Report.pdf) | [Simulation report](Experiment-5-Advanced/Simulation/simulation_report.pdf) | [Submission checklist](Experiment-5-Advanced/Documentation/SUBMISSION_CHECKLIST.md)

[Final supplied Project 5 demo](https://drive.google.com/file/d/1cCgPG9Q1963mofc-caVfxCnzxhqogs_V/view?usp=sharing).

The report covers all seven organizer sections and preserves measured timing/resource and test evidence. The accepted hardware edit lacks the full introductory/RTL presentation segment and ends with watchdog STOP still latched; these limitations are recorded accurately. Original core CSV/PASS exports are now included and verified. See the checklist for project-specific and whole-entry gaps.
