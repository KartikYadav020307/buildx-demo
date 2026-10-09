# Source provenance

The supplied Drive staging folder is:
https://drive.google.com/drive/folders/1tRsaYZ1lsZivgdFrFpOCGrDgtyc5_tlw

| Source | Link | Use |
| --- | --- | --- |
| Prepared Experiment 3 package | https://drive.google.com/file/d/1qY729FA_QLthNn3_g7Wm7Gv8LwPKva71/view | Report, sources, RTL, reports and evidence |
| Original board evidence ZIP | https://drive.google.com/file/d/1bPVCx8TyMlDv53zr3qMgOU_b48qghaF2/view | Original 12 board execution/data/result files |
| Complete original Vivado workspace | https://drive.google.com/file/d/1Mvtn25yZU7M-MPRubtzlSsB89b7_-5-9/view | `project_1.zip`; use for original workspace rebuild |
| Complete original Vitis HLS workspace | https://drive.google.com/file/d/1VlZSbDG1DvLOBPAtjinkNktwdafIPPmB/view | `ecg_bandpass_fir.zip` |

The GitHub package preserves the supplied report and executed notebook outputs.
The generated Verilog dependency files and expanded IP were extracted from the
original packaged IP ZIP without modifying the generated logic. The original
top module matches the packaged IP top byte-for-byte. The BIT and HWH match the
user-uploaded hardware files byte-for-byte. The supplied XSA contains that same
BIT and has been included as `PYNQ_Hardware/ecg_filter.xsa`.

Packaging changes: notebook input files moved beside the notebook to satisfy
its relative paths; generated RTL dependencies exposed; matching XSA added;
block diagram also supplied at the organizer's requested filename; README,
audit and recording guide added; video-link file emptied at the user's request.

`Documentation/FILE_MANIFEST.json` records SHA-256 checksums of the published
experiment files, excluding itself. No newly simulated results have been
substituted for saved physical-board evidence.

## Completion update
Independent Icarus RTL evidence was produced on 9 October 2026 against the original generated core, without logic changes. Run metadata hashes all tested sources. An actual earlier Jupyter screenshot was recovered and preserved with a JPEG derivative. The actual physical board photo and Vivado schematic were subsequently supplied by the team and are incorporated; see CAPTURE_PROVENANCE.md.
