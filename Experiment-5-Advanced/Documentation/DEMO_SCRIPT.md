# A short, deterministic demonstration (about 2 minutes)

Complete and save the hardware core/live tests before filming. Program once; start with both profiles sealed, normal bank 0 active, SW0/SW1 down. Release BTN0. Put the VIO/Tcl result and the board in view. The board LEDs display the action; the Tcl output shows neural scores/model/timing.

| Time | Action / commands | Suggested words |
|---|---|---|
| 0-15 s | Show board + title; `bnn_disarm`; `bnn_run_case 0111` | "This is our FPGA BNN safety-response demonstrator. The binary network uses XNOR and population counts rather than multipliers. Both implementations produce identical scores." |
| 15-30 s | Show `fast=5`, `folded=21`, mismatch zero | "The measured inference latencies are five and 21 clock periods. At the implemented 50 MHz clock, that is 100 and 420 nanoseconds from an accepted feature frame. Sensor and JTAG delays are outside this measurement." |
| 30-50 s | `bnn_live 0000`; `bnn_arm`; `bnn_live 0222` | "The on-chip source generates repeated feature frames. With the normal policy, this scenario produces CAUTION. LEDs are the actuator surrogate." |
| 50-70 s | `bnn_commit 1`; `after 20`; `bnn_snapshot` | "The same bitstream now uses the cautious model. The same input produces BRAKE. Each image is checked for completeness, legal values and CRC before an atomic switch." |
| 70-95 s | Press BTN0, release; attempt BTN1 while unsafe; `bnn_live 0000`; press BTN1 | "Emergency-stop overrides the classifier and latches STOP. Releasing it does not restart the system. An explicit clear succeeds only with a fresh safe decision." |
| 95-110 s | Flip SW1 up then down; show history bit 3 | "Pausing feature frames causes the independent decision-age watchdog to latch STOP after ten milliseconds. Resuming frames also requires an explicit safe clear." |
| 110-120 s | Show actual hardware pass CSV and utilization report | "We verified the two cores against independent integer predictions and tested model switching and fault responses. The policies use a small synthetic dataset; this demonstrates the FPGA architecture and control behavior." |

If you want a 60-90 second video, show the inference comparison, model change and BTN0 latch/clear; retain timeout and CRC evidence in screenshots. Don't type untested setup commands during filming.

For CRC rejection evidence while normal bank 0 is active: `bnn_load cautious 1 1`. It deliberately requests a wrong CRC, shows rejection, then seals the corrected image. This is optional video footage; the automated core test already checks it.
