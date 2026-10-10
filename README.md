# V-SPACE FPGA Build Challenge 2026

## Team Information

**Team Name:** Beyond Boolean

### Team Members

| Name | Registration Number |
| --- | --- |
| Shanshank Pulipati | 25BEC0573 |
| Kartik Yadav | 25BEC0087 |

## Selected FPGA Board

**Board:** PYNQ-Z2

**FPGA:** Xilinx Zynq-7000 XC7Z020CLG400-1 (`xc7z020clg400-1`)

## Project Summary

This repository contains five FPGA projects: two beginner, two intermediate and one advanced experiment. The implementations cover AES encryption, streaming target detection, ECG filtering, fixed-point neural-network inference and a binarized neural policy engine with an independent fault controller.

Each project includes its source and constraints, testbenches, simulation evidence, architecture and RTL diagrams, hardware evidence, technical report and FPGA programming or project-recreation files. The summaries below describe the implemented scope and distinguish saved hardware results from checks that remain pending.

### Experiment 1: Design and Implementation of an FPGA-Based Hardware Accelerator for Real-Time Cryptographic Algorithms

**Difficulty:** Beginner

**Implementation:** AES-128 Hardware Encryption Accelerator

An iterative AES-128 datapath encrypts a 128-bit plaintext using a 128-bit key. It implements key expansion, SubBytes, ShiftRows, MixColumns and AddRoundKey. Vivado Virtual Input/Output (VIO) supplies the inputs and controls over JTAG and exposes the ciphertext and status signals.

The original hardware demonstration and programming files are preserved. A separate [timing-repair candidate](Experiment-1-Beginner/Timing_Repair/) uses a dedicated previous-key register and passes 104 independently checked reference vectors, cycle-by-cycle equivalence and handshake/reset tests. Its fresh Vivado build meets the 125 MHz constraint with **+1.490 ns setup slack**; completion takes **21 clock cycles** in simulation. The original routed build's **−0.104 ns setup slack** remains documented separately. The final video URL is recorded below. Physical-board verification of the repaired revision remains pending; final video content and public access still require review.

[Final demonstration](https://drive.google.com/file/d/1HdQFdZ9_jw4ydN3tetVhZn5XoXck3o-m/view?usp=sharing) | [Project report](Experiment-1-Beginner/Documentation/Project1_AES_Report.pdf) | [Simulation report](Experiment-1-Beginner/Simulation/simulation_report.pdf) | [Repair validation](Experiment-1-Beginner/Documentation/FINAL_VALIDATION.md) | [Submission checklist](Experiment-1-Beginner/Documentation/SUBMISSION_READINESS.md)

### Experiment 2: Design and Implementation of a Reconfigurable FPGA-Based Architecture for Real-Time Radar Signal Processing and Intelligent Target Detection

**Difficulty:** Beginner

**Implementation:** Streaming CA-CFAR Target Detector

A streaming cell-averaging constant false-alarm-rate (CA-CFAR) detector processes synthetic unsigned magnitude samples at 50 MHz. Its 21-cell window contains 16 training cells, four guard cells and one cell under test. Runtime threshold multipliers of 1, 2, 4 and 8 adjust sensitivity. This demonstrates the detection stage; RF acquisition, FFT processing and a learned target classifier are future extensions.

A 100-sample frame produces **80 valid detection windows**. The saved board CSV contains **39 passing rows covering all 32 tested parameter combinations**. Independent XSim checks pass 10,721 core results and 33 controller frames. Routed setup slack is **+12.176 ns**. Native Vivado source/IP, matching BIT/LTX, checkpoint and routed reports are included. The final video URL is recorded; content and public access still require review.

[Project report](Experiment-2-Beginner/Documentation/Project2_Radar_Report.pdf) | [Simulation report](Experiment-2-Beginner/Simulation/simulation_report.pdf) | [Final demonstration](https://drive.google.com/file/d/1GVxgJAPUFZR8cL2akO7Jz29AENO5zwNO/view?usp=sharing) | [Submission checklist](Experiment-2-Beginner/Documentation/SUBMISSION_READINESS.md)

### Experiment 3: A Hardware-Accelerated FPGA Framework for Real-Time Bio-Signal Acquisition and Intelligent Pattern Analysis

**Difficulty:** Intermediate

**Implementation:** FPGA ECG FIR Filtering and ARM Peak Analysis

A Vitis HLS-generated **128-tap, signed Q4.12 FIR filter** runs in programmable logic at 100 MHz. AXI DMA transfers 16-bit samples between DDR memory and the filter. Python on the Zynq ARM processor performs candidate peak detection and heart-rate estimation. Demonstrated inputs are synthetic signals and prerecorded MIT-BIH ECG; live sensor acquisition and clinical diagnosis are outside the tested scope.

Saved board results contain **2,048 exact sine-test samples and 12,288 exact ECG samples**, with zero fixed-point reference error. The recorded sine test shows **53.74 dB reduction at 50 Hz**, and the ECG example yields 42 candidate peaks and approximately 73.9 bpm. Independent generated-core RTL simulation passes **28,672 samples across 14 batches**, including stream stalls and frame checks. The saved **7.55 ms** measurement is Python-plus-DMA wall time. Matching BIT/HWH/XSA, executed notebooks, generated RTL/IP, block design and actual Vivado schematic are included; original complete workspace archives are linked in the source-provenance note.

[Project report](Experiment-3-Intermediate/Documentation/Project3_ECG_Report.pdf) | [Simulation report](Experiment-3-Intermediate/Simulation/simulation_report.pdf) | [Final demonstration](https://drive.google.com/file/d/1kbGfaqtLmN6DjE9lcy6zrnL1sUyOW8ED/view?usp=sharing) | [Submission checklist](Experiment-3-Intermediate/Documentation/SUBMISSION_READINESS.md)

### Experiment 4: Design of an FPGA-Based Hardware Accelerator for Low-Latency Neural Network Inference

**Difficulty:** Intermediate

**Implementation:** Parallel and Sequential Iris Classifiers

A trained **4-input → 4-ReLU-hidden → 3-output** fixed-point network classifies Iris measurements. Parallel and sequential shared-MAC RTL implementations use the same frozen weights, arithmetic and 50 MHz clock. VIO/JTAG launches comparisons and exposes integer scores and classes.

Measured core latencies are **4 cycles / 80 ns** for the parallel implementation and **36 cycles / 720 ns** for the sequential implementation: a **9× core-latency reduction**, excluding host/JTAG transfer time. All **45 saved held-out hardware cases** match the integer reference, while classification accuracy is **43/45 (95.56%)**. The saved regression passes 4,502 vectors per core. Routed setup slack is **+5.813 ns**. Original BIT/LTX, reports, physical CSV, native source/IP archive and clean-build scripts are supplied. Original native paths may require relocation; the Tcl generation flow provides a portable rebuild.

[Project report](Experiment-4-Intermediate/Documentation/Project4_NN_Report.pdf) | [Simulation report](Experiment-4-Intermediate/Simulation/simulation_report.pdf) | [Final demonstration](https://drive.google.com/file/d/1iKShZ_66BI91TXDw6vPuZwFjw929anQ-/view?usp=sharing) | [Submission checklist](Experiment-4-Intermediate/Documentation/SUBMISSION_READINESS.md)

### Experiment 5: A Reconfigurable FPGA-Based Binarized Neural Network Architecture for Ultra-Low-Latency Autonomous Safety Response

**Difficulty:** Advanced

**Implementation:** Parameter-Reconfigurable BNN and Latched Fault Controller

A **16–16–4 binarized neural network** uses XNOR/popcount arithmetic. Two CRC-checked parameter banks support live normal/cautious policy changes and rollback while retaining a fixed hardware topology. An independent controller enforces emergency, invalid-input and stale-input STOP, with explicit eligible clear and a **10 ms watchdog**. Inputs are synthetic feature levels; no vehicle, external sensor or actuator is demonstrated.

Parallel and folded cores complete in **5/21 cycles (100/420 ns at 50 MHz)**. Saved exhaustive tests cover 65,536 binary inputs per profile per core, and all **64 saved physical core cases** match the reference. Whole-design resources are **5,772 LUTs, 6,501 FFs, zero BRAM and zero DSP**; routed setup slack is **+4.534 ns**. The folded core uses fewer FFs but more LUTs in this implementation. Original BIT.gz/LTX and reports are preserved; Tcl scripts recreate the native project. The replacement final video needs review, including watchdog recovery; the earlier edit ended with STOP latched.

[Project report](Experiment-5-Advanced/Documentation/Project5_Report.pdf) | [Simulation report](Experiment-5-Advanced/Simulation/simulation_report.pdf) | [Final demonstration](https://drive.google.com/file/d/11JItdx7IdNwuDhve5nBIV5tBiZsHoPV7/view?usp=sharing) | [Submission checklist](Experiment-5-Advanced/Documentation/SUBMISSION_CHECKLIST.md)

## Technologies Used

- Verilog and SystemVerilog for RTL and testbenches
- AMD/Xilinx Vivado 2025.1.1 for simulation, synthesis, implementation and hardware debugging
- Vitis HLS for the ECG filtering core
- AXI4-Stream, AXI DMA and PYNQ Python/Jupyter for the ECG workflow
- Fixed-point arithmetic, pipelining, resource sharing and binary neural arithmetic
- Vivado VIO and USB/JTAG for hardware control and observation
- Python reference models, saved result audits and supplementary Icarus Verilog simulation

## Documentation and Submission Status

The [official organizer requirements](Submission_Guidelines/documents_req.pdf) specify team/registration information, the selected FPGA board and summaries of all five experiments on the repository home page. Each project report contains the seven required sections: objective, block diagram, RTL design, simulation results, hardware implementation, applications and conclusion.

The [combined team report](Final_Report/Beyond_Boolean_Final_Report.pdf) is present. Its opening overview and Project 1–2 sections have been refreshed to reflect the AES timing repair and recorded final video links. It incorporates the current individual reports in experiment order. [Final_Report/SUBMISSION_STATUS.md](Final_Report/SUBMISSION_STATUS.md) records remaining verification tasks.

| Item | Status at 10 October 2026 |
| --- | --- |
| Five required experiment folders and technical file categories | Present |
| Team details and FPGA platform | Recorded above |
| Project 1 final Drive URL | Recorded; final content and signed-out reviewer access unverified |
| Project 1 repaired-board demonstration | Pending; original footage is separate evidence |
| Projects 2–5 final Drive URLs | Recorded; final content and signed-out reviewer access unverified |
| Root combined report and status synchronization | Updated with current individual reports and video-link status |
| Project 4 JSON inventory/status summary | Refreshed; original snapshots retained under Evidence/Historical/; current checksums validated |

Raw timing, DRC and methodology reports retain their warnings and qualifications. Source-derived schematic illustrations are identified as such in project documentation. Core timing and saved numerical agreement do not establish complete system performance or application validation. AI-assisted documentation and tooling provenance is recorded in the project evidence notes.

The repository remains `buildx-demo`. Confirm the organizer's naming requirement: the supplied PDF uses both leader-name and team-name examples. Its printed deadline is **23 September 2026**; an active deadline or extension must be confirmed separately.
