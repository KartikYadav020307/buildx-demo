# Capture provenance - 9 October 2026

## Board setup
The team supplied the WhatsApp JPEG named "WhatsApp Image 2026-10-09 at 5.01.46 PM.jpeg"
and confirmed it as the Project 3 board photograph. Images/board_setup.jpg is a
byte-for-byte copy. Visible evidence includes the PYNQ-Z2 marking, USB/Ethernet
connections and illuminated LEDs. The saved executed notebooks and result files
provide the separate numerical verification.

## Vivado schematic
The team executed RTL elaboration in Vivado 2025.1.1 against the original
HLS-generated ecg_bandpass_filter core for xc7z020clg400-1. The selected hierarchy
view shows 9 cells / 28 nets: the generated pipeline plus 8 stream register slices.
The original rtl_schematic.pdf is preserved unchanged as Images/rtl_schematic.pdf.
Images/rtl_schematic.png is a full-page 600 dpi rendering of that original PDF.
rtl_schematic_input_detail.png is a 600 dpi PDF-rendered excerpt of the same page
at PDF rectangle (178, 228, 278, 253) points, used for readable labels in the report.
No wiring or labels were redrawn. The view selects module instances; the source
files include the top-level primitive logic outside that selection.

## Team details
The team explicitly confirmed Beyond Boolean, Shanshank Pulipati - 25BEC0573,
and Kartik Yadav - 25BEC0087. The report and README use those exact supplied names.
The final demo link is recorded in Video_Link.txt; see VIDEO_REVIEW.md.
