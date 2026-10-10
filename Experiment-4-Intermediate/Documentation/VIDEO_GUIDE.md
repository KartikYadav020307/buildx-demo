# Final Project 4 demo

Rotate the screen footage upright and add voiceover. The organizer also requests introduction, problem, architecture/RTL explanation in software, working board/setup demonstration and conclusion. Add a brief module/architecture view if it is absent from the final edit.

Suggested narration:
> This is our FPGA-based accelerator for low-latency neural-network inference, running on the PYNQ-Z2. It classifies Iris flowers using four measurements. We compare a parallel accelerator with a sequential implementation of the same network. The first input returns class zero, Setosa; the second returns class one, Versicolor; and the third returns class two, Virginica. Both implementations agree, with zero mismatch. The parallel core takes four clock cycles versus thirty-six, giving nine times lower core latency. Hardware outputs matched the software reference for all forty-five test cases. Classification accuracy was ninety-five point five six percent.

Run nn_hw_reset before recording, then nn_run_case d6d528e0, nn_run_case 09110b2a, nn_run_case 37281210 individually. Reset FPGA/Tcl together; the current persistent script contains the decimal/signed reader correction. The final Drive URL is recorded in Video_Link.txt; see VIDEO_REVIEW.md.
