# Experiment 1 - AES-128 hardware encryption accelerator

**Team:** Beyond Boolean. Shanshank Pulipati (25BEC0573); Kartik Yadav (25BEC0087).

**Board:** PYNQ-Z2, `xc7z020clg400-1`. **Recorded tool:** Vivado 2025.1.1.

An iterative AES-128 encryption core is controlled and observed through Vivado VIO/JTAG. `aes_top` instantiates `aes_core` and `vio_0`; the only external top-level input is the board clock. The archived design uses BIT/LTX programming files.

[Project report](Documentation/Project1_AES_Report.pdf) | [Simulation report](Simulation/simulation_report.pdf) | [Organizer checklist](Documentation/SUBMISSION_READINESS.md)

| Folder | Included files |
| --- | --- |
| Documentation | Seven-section report and original implementation reports |
| RTL | Original `aes_top.v`, `aes_core.v`, `pynq.xdc`, VIO XCI |
| Testbench | Original `tb_aes_core.v` |
| Simulation | Original passing transcript/WDB, supplied waveform photograph, simulation PDF |
| Images | Block diagram, source-derived structural schematic, genuine board photo and Hardware Manager captures |
| FPGA_Project_Files | Original native XPR/source/IP archive, matching BIT/LTX and routed checkpoint |
| Video_Link.txt | Intentionally empty, as requested |

## Preserved results and limits

The archived single-vector simulation reports `TEST PASSED`:

| Signal | Hexadecimal value |
| --- | --- |
| Key | `2b7e151628aed2a6abf7158809cf4f3c` |
| Plaintext | `6bc1bee22e409f96e93d7e117393172a` |
| Expected and observed ciphertext | `3ad77bb40d7a3660a89ecaf32466ef97` |

The testbench clock is 100 MHz. The implementation XDC specifies 125 MHz; its original routed report **fails setup timing**: WNS **-0.104 ns**, TNS **-0.276 ns**, four failing endpoints. The integrated AES/VIO/debug design uses 3,222 LUTs and 3,912 registers. These saved results do not establish a timing-closed 125 MHz design. No new simulation, build or board execution is claimed by this upload.

`done` is a one-clock pulse. The ciphertext stays available until reset or the next completed encryption, so a later VIO snapshot can show `done=0` with a retained result.

`Images/hardware_output.jpg` is a genuine **512 x 278 video preview**, preserved from the uploaded conversation; it cannot independently establish every ciphertext digit. A readable completed-output screenshot or original video frame is still needed. `Images/hardware_programmed.png` shows the programmed FPGA/active VIO, rather than a completed encryption. `Images/rtl_schematic.png` documents the actual RTL connections and is labeled as a source-derived structural diagram. `Simulation/waveform.png` is the original historical photograph; the original WDB allows a clearer capture.

## Open and program

1. Extract `FPGA_Project_Files/Native_Project/Project1_AES_Vivado_Source.zip` to a short local path and keep the entire `aes128_core` folder together.
2. Open `aes128_core/aes128_core.xpr` in Vivado 2025.1.1. The original descriptor retains historical run/tool settings; use a fresh extracted copy when regenerating IP or resetting/rebuilding runs.
3. The preserved programming files are `FPGA_Project_Files/Programming/aes_top.bit` and matching `aes_top.ltx`. Use them together in Hardware Manager.
4. Review `Documentation/Implementation_Reports/` before making implementation claims. A subsequent corrected build and routed report are needed for timing closure.

The native source archive preserves 71 original files, including XPR, sources, constraints, testbench, generated VIO dependencies, imported incremental checkpoint and archive summary. Disposable caches and run folders are excluded; the original routed checkpoint, reports and simulation database are supplied separately. All selected original source bytes remain unchanged.

No notebook or HWH was present in the supplied AES archive. A separately saved Jupyter notebook, if used, still needs to be located; it is not a required dependency of this archived VIO design. The historical `C:\Users\student\Documents\25BEC0087\aes128_core` path belongs to the lab PC and is not a location on the laptop.
