# Run in a NEW Vivado 2025.1.1 GUI instance, from its Tcl Console:
# source {C:/path/Experiment-3-Intermediate/RTL/Vivado_Block_Design/CAPTURE_RTL_SCHEMATIC.tcl}
# Opens a separate in-memory RTL elaboration; no board or hardware manager used.
# RTL elaboration and hierarchy capture were executed by the team in Vivado 2025.1.1.
if {[llength [get_projects -quiet]] != 0} {
    error "Open a fresh Vivado GUI instance with no project, then source this script."
}
set script_dir [file dirname [file normalize [info script]]]
set experiment_dir [file dirname [file dirname $script_dir]]
set rtl_dir [file join $experiment_dir RTL Generated_Verilog]
set image_dir [file join $experiment_dir Images]
create_project -in_memory -part xc7z020clg400-1
set_property include_dirs [list $rtl_dir] [get_filesets sources_1]
foreach source_file [lsort [glob -directory $rtl_dir ecg_bandpass_filter*.v]] {
    read_verilog $source_file
}
synth_design -rtl -top ecg_bandpass_filter -part xc7z020clg400-1
current_instance
show_schematic -name Project3_FIR_Hierarchy [get_cells -filter {IS_PRIMITIVE == 0}]
write_schematic -force -format pdf -orientation portrait -scope all -name Project3_FIR_Hierarchy [file join $image_dir rtl_schematic.pdf]
puts "Selected module hierarchy open. The vector PDF preserves labels for zooming."
puts "Vector PDF exported to Images/rtl_schematic.pdf; check that it exists and is readable."
