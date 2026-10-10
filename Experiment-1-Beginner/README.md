# Experiment 1 - AES-128 hardware encryption accelerator

**Team:** Beyond Boolean. Shanshank Pulipati (25BEC0573); Kartik Yadav (25BEC0087).

**Board:** PYNQ-Z2, `xc7z020clg400-1`. **Tool:** Vivado 2025.1.1. **Clock constraint:** 125 MHz / 8 ns.

An iterative AES-128 core accepts a key/plaintext through Vivado VIO/JTAG and retains the encrypted block for readout. `aes_top` instantiates `aes_core` and `vio_0`; the only external RTL input is the board clock. It encrypts one block, without a streaming bus, encryption mode or authentication layer.

[Project report](Documentation/Project1_AES_Report.pdf) | [Original simulation report](Simulation/simulation_report.pdf) | [Repair validation](Documentation/FINAL_VALIDATION.md) | [Submission checklist](Documentation/SUBMISSION_READINESS.md)

## Two preserved revisions

| Revision | Files and verified evidence | Limitations |
| --- | --- | --- |
| Original board demonstration | `RTL/`, `Testbench/`, original `Simulation/`, `Documentation/Implementation_Reports/`, original native ZIP, `FPGA_Project_Files/Programming/` BIT/LTX and checkpoint | One archived 100 MHz simulation vector; 125 MHz setup WNS -0.104 ns, TNS -0.276 ns, four failing endpoints |
| Timing repair candidate | `Timing_Repair/RTL/`, paired equivalence testbench and vectors, supplied outputs, independent checkpoint recheck and fresh reproduction records; repaired native ZIP | Functional simulation and static timing verified; physical-board execution of repaired BIT/LTX remains pending |

The repair uses a dedicated 128-bit `previous_key` register instead of selecting the previous key through `round_keys[k_idx-1]`. The port interface, AES transforms, VIO wiring and 8 ns constraint are unchanged. Regression checks 104 independently recomputed AES reference vectors, cycle-by-cycle equivalence, 21 cycles from accepted start to completion, reset/restart, busy input capture, retained ciphertext and held-start retriggering. `done` lasts one clock; retained ciphertext can be visible with `done=0`.

The supplied repaired checkpoint reproduces WNS **1.490 ns**, WHS **0.033 ns**, WPWS **2.750 ns**, zero failing endpoints and zero unconstrained internal endpoints. All four bus-skew constraints are MET; minimum slack **6.642 ns**. Integrated utilization is **2860 LUTs / 4043 FF / 0 BRAM / 0 DSP**, including VIO/debug hub. Five DRC Warning checks and four methodology Warning checks remain disclosed. See the validation record for the separately measured fresh-build results; do not mix files from different builds.

## Physical and diagram evidence

`Images/recorded_hardware_output.png` is the unchanged supplied recording frame: key `2B7E151628AED2A6ABF7158809CF4F3C`, plaintext `6BC1BEE22E409F96E93D7E117393172A`, ciphertext `3AD77BB40D7A3660A89ECAF32466EF97`. It documents the original demonstration, not the repaired build. The original low-resolution `hardware_output.jpg`, board photograph and programmed-VIO screenshot are also preserved. `recorded_board.png` is the supplied powered-board frame.

`Images/block_diagram.png` is a conceptual architecture drawing. `Images/rtl_schematic.png` is a source-derived top connectivity diagram, not a native Vivado schematic capture. Both agree with the unchanged top interface; neither represents detailed repaired key-expansion circuitry. Original waveforms/WDB remain under `Simulation/`; the new repair VCD and its scientific plot are under `Timing_Repair/Validation/`.

## Reproduce or program

For the original project, extract `FPGA_Project_Files/Native_Project/Project1_AES_Vivado_Source.zip` and open `aes128_core/aes128_core.xpr`, keeping the full layout. Its original programming pair remains at `FPGA_Project_Files/Programming/aes_top.bit` and `aes_top.ltx`.

For the repaired native source project, extract `FPGA_Project_Files/Native_Project/Project1_AES_Repaired_Vivado_Source.zip` and open `AESRepair/build_repaired/aes125_repaired.xpr`. Use Vivado 2025.1.1; generated run/cache folders are excluded, so rebuilding creates new results. Selected original source/IP files are byte-identical to the supplied ZIP.

For clean repair reproduction, copy the entire `Timing_Repair/` folder to a short writable path. In a separate Vivado batch process run `vivado -mode batch -source BUILD_REPAIRED.tcl`. This creates `build_repaired/`, refuses to overwrite an existing build, checks regression, synthesizes, routes, optimizes after route, and gates BIT/LTX export on timing/coverage and bus skew. The supplied historical script and its notes are retained in `Supplied/`; use the corrected root runner. See [repair instructions](Timing_Repair/README.md).

## Remaining submission work

The required technical file categories are present. **Project 1 is not fully submission-ready:** `Video_Link.txt` remains empty because no final Project 1 URL was supplied. A compliant final video must cover introduction/problem, architecture/RTL, physical setup/working demonstration and conclusion. Repaired-board testing remains pending; original footage cannot validate the repaired bitstream. Review normal PYNQ boot/PS initialization and disclosed debug-IP warnings for deployment.

The original technical/evidence files and earlier report PDF were preserved. No root files or Projects 3-5 were changed. The source manifest in `Timing_Repair/Supplied/` applies to the original repair-package files; the current manifest and validation record distinguish later review artifacts. AI assistance was used in preparing documentation and validation tooling; no numerical claim about HDL authorship is made.
