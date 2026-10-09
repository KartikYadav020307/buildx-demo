# Evidence provenance

Published package prepared on 9 October 2026 from supplied Project2_Radar_Final sources, actual laptop build/results, and the user's linked Project 2 Drive folder. No new physical-board execution is claimed by publication.

| Evidence | Origin and identity |
| --- | --- |
| RTL, Testbench, five Vivado Tcl files | Supplied Project2_Radar_Final.zip; all eleven exact byte counts/CRC32 match the original successful build manifest |
| Simulation VCDs/CSV, plots and local transcripts | Original prepared package, Icarus Verilog 12.0 verification on 8 October 2026; plots rendered from those actual data |
| Evidence/vivado_build.log | Full user-pasted successful Vivado 2025.1.1 run, ending 8 October 2026 22:40:16 IST; both XSim suites, synthesis/routing and bitstream generation |
| Results/BUILD_SUCCESS.txt | Original uploaded success marker/source manifest; WNS 12.176 ns, WHS 0.018 ns, WPWS 2.000 ns |
| Hardware/radar_top.bit | Original uploaded bitstream; header date 2026/10/08 22:40:12; SHA-256 `88271fc169ca91f16e16ed15e0bd5f1ef874f0dc97cfdcda7fe1f413f6e44dc6` |
| Hardware/radar_top.ltx | Original uploaded matching probe file; SHA-256 `34adb974e793b880dfe469cd21c3c9b3cd039e650a4a76f72d9fe5dcfd575102` |
| Results/HARDWARE_PASS.txt | Original uploaded board PASS marker, 8 October 2026 23:54:05 IST; 32 combinations plus repeated standard frame |
| Results/hardware_results.csv | Original unchanged upload, 39 PASS rows; 32 unique combinations plus repeats and extra demonstrations; frame IDs reset in later demonstrations |
| Images/board_setup.jpg | Original Drive file `board photo.jpg`, unchanged JPEG bytes |
| Images/hardware_output.jpg | Original Drive file `IMG_20261009_000128.jpg`, unchanged JPEG bytes; board with laptop's PASS console |
| Images/hardware_verification.png | Original Drive `new make/hardware_verification.png`; actual Vivado hardware verification console, not synthesized text |
| Images/rtl_schematic.png/.svg/.dot | Newly generated genuine Yosys 0.33 source elaboration/structural check; rendered with Graphviz. Clock primitives and VIO are library/black-box declarations, not verified proprietary implementations |
| Simulation/rtl_netlist.json | Same Yosys output, reduced only to the seven transitively used modules; cell/net contents unchanged |
| Documentation/Project2_Radar_Report.pdf and Simulation/simulation_report.pdf | Updated reports from the evidence above and recovered routed reports/native archive, with only final-video status pending |

Drive source folder: https://drive.google.com/drive/folders/1r_YPArksUf5RKO_BgOmcaQPOz1ryYOdl?usp=sharing

The hardware CSV stores counts, result/cycle counts and last full threshold; it does **not** store positions/masks in separate columns. Exact positions/masks and configuration were checked by the supplied hardware script before writing each PASS row, and are corroborated by the original PASS marker/console. The archive audit rechecks CSV fields; it does not independently remeasure the board or reconstruct absent probe snapshots.

The newly supplied `Project2_Radar_Final (2).zip` recovered seven original `Reports/*.rpt`, the routed checkpoint and the successful native `.xpr`/VIO IP directory. The eighth report, routed bus skew, was copied from the successful implementation run with only its filename shortened. `FPGA_Project/Project2_Radar_Vivado_Source.zip` retains byte-identical selected files and original relative layout, excluding the failed run/caches. All four bus-skew constraints pass; routed resource totals and remaining DRC/methodology warnings are reported directly from these files. No measured power is claimed. Earlier September radar/AXI files and historical chat/context documents are excluded from this submission package.
