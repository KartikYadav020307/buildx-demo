# Whole-entry organizer audit

Updated: 10 October 2026. Source: `../Submission_Guidelines/documents_req.pdf`.
Team: Beyond Boolean; Shanshank Pulipati (25BEC0573); Kartik Yadav (25BEC0087).
Board: PYNQ-Z2 / xc7z020clg400-1.

All five experiment folders and the required technical file categories are present. The home README records team/registration details, FPGA platform and all five project summaries. `Beyond_Boolean_Final_Report.pdf` now contains a refreshed overview and the current individual reports in experiment order.

| Experiment | Recorded technical evidence | Remaining verification |
| --- | --- | --- |
| 1 - AES-128 | Current seven-section report, original RTL/native/programming files and readable genuine original-result frames; separate repaired source, 104-vector regression and full reproduced build. Original 125 MHz WNS -0.104 ns; repaired WNS +1.490 ns. Final URL recorded. | Physical-board verification of repaired BIT/LTX; final video sections/content and anonymous access. Original footage does not verify the repaired revision. |
| 2 - Radar CA-CFAR | Current eight-page report, native source/IP archive, matching BIT/LTX/checkpoint, routed reports, saved 39 PASS rows covering 32 combinations; final URL recorded. | Final video sections/content and anonymous access. No new board run is claimed. |
| 3 - ECG FIR | Current report, generated RTL/HLS/IP and block design, actual Vivado hierarchy, saved simulation/board outputs, matching BIT/HWH/XSA; final URL recorded. | Final video sections/content/access. Full original workspace archives are externally linked; the committed descriptor retains original paths. |
| 4 - NN inference | Current report, frozen model/RTL, saved simulation, 45 hardware rows matching integer reference (43 correct labels), original native/programming files; final URL recorded. Inventory/status metadata refreshed; old snapshots preserved. | Final video sections/content/access. Original native paths may require relocation; Tcl rebuild is supplied. |
| 5 - BNN response | Current report, RTL/model/test suites, original routed/programming evidence and saved core/live PASS exports; replacement final URL recorded. | Replacement video content/access, eligible watchdog recovery and physical-button evidence. Automated VIO PASS is distinct from operator button checks. |

## Final videos

All five final Drive URLs are recorded in each experiment's `Video_Link.txt`; none is blank. URL presence is not a completed video review. Organizer page 6 requires introduction/problem, architecture and RTL in software, physical setup/connections/working demonstration, and conclusion. Verify each final edit and signed-out reviewer access. Project 5's earlier edit ended with watchdog STOP latched; the replacement has not been reviewed here.

## Project 4 inventory correction

The former `Documentation/FILE_MANIFEST.json` and `Evidence/current_package_validation.json` are preserved byte-for-byte under `Experiment-4-Intermediate/Evidence/Historical/`. The current inventory records current package bytes and the validation summary records the final URL and confirmed team name. Earlier simulation/board claims retain their original dates and provenance. This metadata refresh does not claim new hardware or HDL execution.

## Shared remaining checks

- Repaired AES board test: use one matching repaired BIT/LTX set, retain its build identity and genuine results, and review disclosed boot/debug-reset warnings.
- Verify final videos and anonymous judge access for all five projects; no sharing permissions were changed.
- Confirm the active deadline/extension and accepted repository name with organizers. The supplied PDF prints 23 September 2026 and differing leader/team naming examples; the repository remains `buildx-demo`.

Raw timing/DRC/methodology reports, source-derived diagram labels, AI-assistance disclosures and original technical evidence are preserved. No new board execution, HDL simulation, synthesis or routing is claimed by this documentation update. Technical file presence does not imply all application or submission checks have passed.
