# Organizer checklist - Experiment 1

Audit: 10 October 2026 (Asia/Kolkata). Reference: `../../Submission_Guidelines/documents_req.pdf`, identical to the supplied six-page organizer PDF. Team: Beyond Boolean; Shanshank Pulipati 25BEC0573; Kartik Yadav 25BEC0087.

**Technical file categories are present. Final video/link and physical verification of the repaired revision remain incomplete.** Existing original hardware evidence is preserved and clearly distinguished from repaired simulation/timing evidence.

| Organizer requirement | Evidence / status |
| --- | --- |
| Experiment-1-Beginner layout, Documentation/RTL/Testbench/Simulation/Images | Present; actual module filenames retained |
| PDF objective | Project1_AES_Report.pdf section 1 |
| PDF block diagram | Section 2; Images/block_diagram.png, conceptual source-based drawing |
| PDF RTL code structure and hierarchy | Section 3; aes_top -> aes_core and vio_0; repair previous_key change documented |
| PDF simulation waveforms and outputs | Section 4; original waveform/transcript/WDB plus repaired real XSim VCD, plotted trace and regression log |
| PDF hardware screenshots | Section 5; genuine board/programming images and readable original-result recording frame |
| PDF applications | Section 6; secure-system integration described as future work |
| PDF conclusion/future scope | Section 7; separate verification states and pending work |
| RTL with constraints | Original RTL/aes_top.v, aes_core.v, pynq.xdc and VIO XCI preserved; candidate files in Timing_Repair/RTL/ |
| Testbench | Original Testbench/tb_aes_core.v preserved; extended equivalence testbench in Timing_Repair/Testbench/ |
| Simulation/waveform.png | Original historical waveform photograph preserved; new actual repair trace supplied separately |
| Simulation/transcript.txt | Original one-vector PASS preserved; new 104-vector regression log supplied separately |
| Simulation/simulation_report.pdf | Original simulation PDF preserved; supplemental repair validation PDF in Timing_Repair/Validation/ |
| Images/block_diagram.png | Present, conceptual architecture grounded in source |
| Images/rtl_schematic.png | Present, source-derived connectivity; not a native Vivado GUI export |
| Images/board_setup.jpg | Original genuine board photo preserved; additional recorded_board.png |
| Images/hardware_output.jpg | Original preview preserved; readable recorded_hardware_output.png now supplied and used in report |
| FPGA project files | Original native source ZIP/BIT/LTX/checkpoint preserved; repaired native source ZIP and separate repaired output sets supplied |
| Optional utilization | Original 3222 LUT / 3912 FF; supplied repair 2860 LUT / 4043 FF, each whole top including VIO/debug |
| Final Drive video link and presentation | Missing Project 1 final URL; Video_Link.txt stays empty |

The final video must include introduction/problem, architecture and RTL in software, physical setup/connections and working demonstration, and conclusion (organizer page 6). Do not represent original footage as a repaired-board test. At 125 MHz the original archived build still fails setup (-0.104 ns); the separate supplied repaired checkpoint passes (+1.490 ns). Original metrics and evidence were not replaced.

Five DRC Warning checks and four methodology Warning checks remain disclosed for the repaired design, including missing PS7 initialization and debug-hub asynchronous-reset hazards. Passing static timing does not resolve those warnings or substitute for board testing.

Repository-wide recommendations: refresh only the Project 1-2 content in the combined team PDF and root status summaries after this review; those files are out of the authorized edit scope. The organizer PDF lists 23 September 2026 as its deadline and gives differing leader/team naming examples on pages 1-2; confirm current deadline and naming with organizers without renaming this repository automatically.
