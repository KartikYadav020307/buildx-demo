# Repair missing Project 4 source files

Vivado launched but could not read Vivado/run_all.tcl. The review patch contains
only two replacement files; it is not a complete project. Replacing an entire
source folder with the patch folder can remove the other required files.

This archive restores the complete source pack and includes the corrected clock
constraints and extra reports. It contains no build or Results folders.

1. Close Vivado. Extract this ZIP to:
   C:/Users/yamle/OneDrive/Desktop/Project4_NN_Complete_Pack
2. Merge the included Project4_NN folder into the existing Project4_NN folder.
   Accept replacement of matching source files. Keep existing build and Results.
3. Confirm Project4_NN/Vivado/run_all.tcl and RTL/nn_parallel.sv exist.
   The launcher must be next to RTL, Vivado, Data, and Testbench.
4. Double-click the existing Project4_NN/RUN_PROJECT4.cmd.
5. Upload new Results/vivado_batch.log, timing_summary.rpt, clocks.rpt,
   bus_skew.rpt, and methodology.rpt after the build completes.

Do not create a nested Project4_NN/Project4_NN directory. Copy the contents
of the extracted Project4_NN folder into the existing one if extracting
to a separate temporary folder is easier. No model retraining is required.

This repair is source restoration. Its patched Vivado build still needs to run
on the Windows laptop. Keep the physical-board test as the next validation step.
