# Physical evidence provenance

- hardware_live_console.log: original Tcl console log, including HARDWARE LIVE PASS; not a reconstructed output.
- hardware_core_pass.png: original operator screenshot of the 64/64 core result.
- Images/hardware_output.jpg: actual screen-recording frame after normal-to-cautious bank switch.
- Final Drive demo: accepted edited recording of the physical board and Vivado console.
- Documentation/DEMO_EVIDENCE.md: interpretation of the final recording and earlier copied operator snapshots.

The original hardware_test_results.csv, HARDWARE_CORE_PASS.txt and HARDWARE_LIVE_PASS.txt are now supplied in Results/run_20261008_121952_125/. The CSV has 64 rows (32/profile), all matching the frozen reference hidden bits, signed scores, class, margin, model identity and 5/21-cycle latencies. Results/BUILD_SUCCESS.txt is an original pre-hardware build artifact, so its hardware-pending note describes that earlier build stage.
