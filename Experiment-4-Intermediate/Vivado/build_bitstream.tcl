# Run after simulation passes, in the open NN_Inference project.
# Compilation continues in Vivado's background run processes.
if {[get_property NAME [current_project]] ne "NN_Inference"} {error "Open NN_Inference first."}
launch_runs impl_1 -to_step write_bitstream -jobs 2
puts "Build launched. Monitor Design Runs. After completion, source collect_reports.tcl."
