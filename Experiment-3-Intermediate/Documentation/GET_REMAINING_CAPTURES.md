# Capture completion and reproduction

The physical board photograph and real Vivado schematic have been supplied and
incorporated. No further board test or capture is required for this file set.

To reproduce the schematic, open a fresh Vivado 2025.1.1 GUI with no project open
and source RTL/Vivado_Block_Design/CAPTURE_RTL_SCHEMATIC.tcl from its Tcl Console,
using the full path to that file. It elaborates the original generated FIR core
and displays the module hierarchy without using hardware manager or a board.
The script exports Images/rtl_schematic.pdf. The accepted original export and
its PNG rendering are already present; preserve these evidence files.

The full diagram is tall because the generated pipeline exposes many state pins.
Use the vector PDF to inspect labels; the report includes a magnified input-side
excerpt. See CAPTURE_PROVENANCE.md for the exact original-file sources.

The final demo URL is recorded in Video_Link.txt; review content and public access
as described in VIDEO_REVIEW.md. Confirmed team: Beyond Boolean; Shanshank Pulipati (25BEC0573)
and Kartik Yadav (25BEC0087).
