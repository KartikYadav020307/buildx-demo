# Original native Vivado source archive

`Project2_Radar_Vivado_Source.zip` contains the original successful laptop project from the uploaded `Project2_Radar_Final (2).zip`. It is a curated source archive, not a Vivado-generated archive command output. All selected original files are byte-identical; nothing was fabricated or changed.

Extract the whole ZIP into a path without spaces, then open:

`Project2_Radar_Final/Build/run_20261008_222502/project2_radar.xpr`

Use Vivado 2025.1.1 with 7-series/Zynq device support. Preserve the archive's relative folder layout: the XPR references `../../RTL`, `../../Testbench`, `../../Vivado/debug_clock.tcl` and its local `project2_radar.srcs/sources_1/ip/vio_radar/vio_radar.xci`. The VIO configuration, generated IP dependencies and IP user files are included. The archive excludes the earlier failed run, implementation/simulation run directories, caches and temporary files. Vivado may need to regenerate IP output products and rerun synthesis/implementation; no new opening/build execution is claimed for this documentation update.

For a clean build, use the experiment root's original `RUN_PROJECT2.cmd` and `Vivado/build_project.tcl`. This creates a fresh native project and VIO IP. `OPEN_PROJECT2.cmd` opens that new build via the generated `Results/project_path.txt`. Reproduce in a separate copy because building replaces result markers and hardware files.

The existing original BIT/LTX can be programmed without rebuilding or opening the XPR. The recovered routed checkpoint is separately available at `../Reports/routed_design.dcp`; report texts and warning review are beside it.
