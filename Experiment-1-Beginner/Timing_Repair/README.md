# AES timing repair - reproduction and evidence

Team: Beyond Boolean. Shanshank Pulipati (25BEC0573); Kartik Yadav (25BEC0087).

The supplied repair changes only the AES core key-expansion data selection. `RTL/` is the candidate; `Original_RTL/` is the supplied original; `Testbench/` compares them throughout a 104-vector regression. The original submission's RTL and board-tested programming files remain outside this folder and are unchanged.

`Supplied_Outputs/` preserves the supplied 10 October post-route reports, checkpoint and BIT/LTX pair. `Validation/` contains the archived regression logs, independently rerun XSim log/VCD/waveform and checkpoint recheck. `Reproduced_Outputs/`, when present, contains the separate fresh source-build results. Use each build's BIT and LTX together. Hardware execution of either repaired pair remains pending.

Copy this complete folder to a short writable path. Start a separate Vivado 2025.1.1 batch process with `vivado -mode batch -source BUILD_REPAIRED.tcl`. The script refuses an existing `build_repaired/`; use a new copy for later runs. It creates the VIO IP, runs equivalence regression, synthesizes, routes and invokes post-route `phys_opt_design -directive Explore`. Timing, clock coverage and bus-skew checks precede bitstream/probe export. DRC severity is never downgraded.

The supplied runner used an invalid `post_route_phys_opt_design` run-step name. The corrected runner stops at `route_design` and applies post-route optimization explicitly. The completed routed checkpoint is opened directly because stopping before post-route optimization leaves the project run status incomplete. A bus-skew report and export gate were added; the original valid `check_timing -file` form is retained. The supplied script is preserved in `Supplied/BUILD_REPAIRED.tcl`. Its `START_HERE.md` describes the earlier preparation state and is historical, not current status.

For board verification, use the normal PYNQ boot/power setup and USB/JTAG. Program a single matched repaired pair. Set start=0, pulse reset high then low, load the known key/plaintext, set start=1 then back to 0 and inspect the retained full ciphertext. Holding start high retriggers encryption; the 8 ns done pulse is not reliably visible in a slow VIO refresh. Reset between cases. The second reference case is key `000102030405060708090A0B0C0D0E0F`, plaintext `00112233445566778899AABBCCDDEEFF`, ciphertext `69C4E0D86A7B0430D8CDB78070B4C55A`. Save the result and identify the exact programming-file hashes. No such repaired-board run is claimed here.

[Current validation](../Documentation/FINAL_VALIDATION.md) | [Project report](../Documentation/Project1_AES_Report.pdf)
