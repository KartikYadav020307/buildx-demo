# Simulation evidence

- transcript.txt: genuine fresh Icarus Verilog 12.0 full regression output, 8 October UTC / 9 October IST.
- verified_iverilog_transcript.txt: preserved earlier 6 October original regression.
- nn_simulation_pass.flag: fresh pass marker.
- waveform.vcd / waveform_transcript.txt: actual three-case exact-score/controller trace and 4/36-cycle checks.
- waveform.png / waveform_measurements.csv: rendered actual events and measured timestamps.
- simulation_report.pdf: test setup, scope, outputs and measured trace.
- schematic_transcript.txt / rtl_schematic_netlist.json: real source elaboration for the schematic. Proprietary IP declarations are black boxes only, not functional simulation models.
- radix_reader_transcript.txt: actual Tcl parser output for ten representations, signed restoration and unsupported-radix rejection. Reproduce with `python python/test_vio_radix.py`; this uses mocked VIO properties and is not an FPGA test.

Original Vivado/XSim evidence is preserved separately under Results/. New Icarus outputs are never relabeled as Vivado. Reproduce with `python python/run_open_source_tests.py`.
