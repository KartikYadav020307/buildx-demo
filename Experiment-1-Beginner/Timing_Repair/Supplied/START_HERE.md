# Project 1 AES: timing repair and verification plan

## What was confirmed

Reviewed staging repository main at `888f0afc391ff836c06e9453166c5c1d75b07357` on 10 October 2026, including its Project 1 RTL, XDC, testbench and routed timing report. Reviewed the supplied 15.18-second screen recording and 5.8-second board clip.

The screen recording visibly shows:

- Key: `2B7E151628AED2A6ABF7158809CF4F3C`
- Plaintext: `6BC1BEE22E409F96E93D7E117393172A`
- Correct retained ciphertext: `3AD77BB40D7A3660A89ECAF32466EF97`
- `done=0` in the later output view, as expected after a one-clock completion pulse.

The board clip shows the powered PYNQ-Z2. These clips demonstrate a successful encryption with the original implementation. They do not measure static timing margin.

The original routed report explicitly says **Timing constraints are not met**:

| Quantity | Original result |
| --- | ---: |
| Clock constraint | 125 MHz / 8 ns |
| Setup WNS | -0.104 ns |
| Setup TNS | -0.276 ns |
| Setup failing endpoints | 4 |
| Hold WNS | +0.028 ns |
| Hold failing endpoints | 0 |

The worst reported path starts at `encryption_hardware/k_idx_reg[2]` and ends at `encryption_hardware/round_keys_reg[8][2]`. It has seven logic levels; the report attributes 5.516 ns of its 7.732 ns data-path delay to routing. The violation is 104 picoseconds. This confirms a small timing failure in the archived build, not an observed wrong ciphertext in your videos.

## What the repair changes

Original expansion reads the previous key through `round_keys[k_idx-1]`. That expression introduces indexed selection across the key bank on the expansion path. The repaired RTL keeps a dedicated 128-bit `previous_key` register: load it with the input key on start, then update it with each expanded key. The same computed keys are also stored in the existing key bank for the AES rounds.

This removes the indexed previous-key read from expansion. The key index still controls Rcon and bank writes; timing closure still needs measurement. The AES transforms, port interface, 125 MHz constraint, 21 cycles from accepted start to completion, VIO layout, one-clock `done`, retained ciphertext and held-start retriggering behavior are preserved.

The build also uses Vivado's `Performance_ExplorePostRoutePhysOpt` strategy. This performs timing-oriented implementation with physical optimization after routing. No clock relaxation, false paths, multicycle exceptions or DRC severity changes are introduced.

**Status: the repaired RTL passes functional simulation. New Vivado synthesis, routed timing and physical-board verification have not been performed here. There is no new verified BIT/LTX in this package.**

## Do this on your laptop

1. Extract this ZIP to a short writable folder, such as `C:/BuildX/Project1_AES_Timing_Repair`. Keep its subfolders together. Use Vivado 2025.1.1 where possible, matching the original build.
2. Open Vivado. In the **Tcl Console**, enter the following using your actual extraction path:

   ```tcl
   set argv {}
   source {C:/BuildX/Project1_AES_Timing_Repair/BUILD_REPAIRED.tcl}
   ```

   The script closes the currently open project, creates a separate new project, recreates VIO, runs regression, synthesizes, routes and checks timing. Save any unsaved work in the current project beforehand. No board is needed. Alternatively run `RUN_REPAIR.cmd` when Vivado is available on PATH.
3. After completion, inspect `build_repaired/verified_outputs/timing_summary_routed.rpt`. Expect WNS/WHS/WPWS at least zero and no failing endpoints. The script requires Vivado's complete timing-pass statement and zero no-clock/unconstrained internal endpoint checks before exporting programming files. Review `drc_routed.rpt`, `methodology_routed.rpt` and `check_timing.rpt` as well; any remaining warnings must be assessed rather than hidden.
4. If timing passes, the matching new `aes_top.bit`, `aes_top.ltx`, routed checkpoint and reports appear in `build_repaired/verified_outputs/`. `BUILD_STATUS.txt` records timing passed and board verification still pending. Simulation logs are under `build_repaired/aes125_repaired.sim/sim_1/behav/xsim/`.
5. If the script fails, inspect its log and reports. Do not treat the repaired source as proof of timing closure. Send the new routed report and log for the next targeted fix. To rerun, rename `build_repaired` first; previous results are deliberately preserved.

Optional: to try physical optimization on the original RTL first, with no logic change, use `set argv {original}` before sourcing the same script. Outputs go to `build_original`. If that run closes timing, it may be sufficient; otherwise run repaired mode as above. Do not mix outputs from these two builds.

## If you can access the board

Program the **new matched BIT/LTX pair** together through Hardware Manager. Set `start=0`; assert reset to 1 then return it to 0; load the same NIST key/plaintext; set start to 1 then return it to 0. Verify the full retained ciphertext is `3AD77BB40D7A3660A89ECAF32466EF97`.

A manual VIO operation is not a one-clock start pulse. With the preserved RTL, holding start high causes repeated encryptions. Do not expect to see `done=1` in the slowly refreshed VIO GUI; it lasts only one FPGA clock (8 ns). Reset between hardware test cases. If time allows, test a second case: key `000102030405060708090A0B0C0D0E0F`, plaintext `00112233445566778899AABBCCDDEEFF`, expected ciphertext `69C4E0D86A7B0430D8CDB78070B4C55A`.

Save the new result screenshot/video and identify which build produced it.

## If the board is unavailable today

You can still run regression and obtain new routed timing on the laptop. Keep the original videos as evidence of the **original board-tested build**. Describe the repaired build separately as simulation-tested and timing-verified only if the new reports pass; its hardware verification remains pending. Do not replace the original programming files with a new build while describing the old video as proof of that new bitstream.

If a passing rebuild cannot be obtained before submission, retain the honest original timing limitation. The existing demo remains evidence of correct encryption for the shown vector.

## Updating the staging submission after verification

Keep the original package until verification is complete. Then synchronize all items from the same accepted build:

- RTL, native Vivado project/source archive and reproduction script.
- Matched BIT/LTX, routed checkpoint, routed timing, utilization and other relevant reports.
- Simulation transcript/waveform/report, including the tested scope and 125 MHz regression clock.
- Project report, readiness checklist, README, affected diagrams, combined report and affected inventories/checksums.
- Hardware result evidence and video link, with the build identity and any pending board verification stated accurately.

The readable image recovered from the supplied original recording is included as `Evidence/recorded_hardware_output.png`; it can replace the old low-resolution preview while continuing to document the original build. `Evidence/recorded_board.png` is a genuine extracted board frame. The original failing report is preserved as `Evidence/ORIGINAL_failing_timing.rpt`.

This repair package does not alter or push the staging repository. Existing Project 1 report PDFs still describe the original implementation; they must be refreshed based on the actual new results, rather than predicted timing numbers.

## Verification performed here

Icarus Verilog 12.0 simulation passed:

- 104 AES known/reference vectors: the existing demo vector, the standard incremental-key example, zero and all-one cases, and 100 deterministic random key/plaintext pairs. Reference ciphertexts were generated using PyCryptodome AES-ECB on individual 16-byte blocks.
- Cycle-by-cycle original/repaired output equivalence over the entire regression.
- 21-cycle completion, one-clock done and ciphertext retention.
- Input capture while busy, reset midway through encryption, restart and held-start repeated encryption.

The clock in this regression is 125 MHz. RTL simulation checks functionality; it does not model routed propagation delay. Original source and XDC bytes are preserved in `Original_RTL/`. `RTL_CHANGE.diff` shows the source change. Tcl parsing/control-flow and the timing failure gate were checked using command stubs; that is not a Vivado build or Vivado API compatibility certification.

## References

Original timing report: https://github.com/KartikYadav020307/buildx-demo/blob/main/Experiment-1-Beginner/Documentation/Implementation_Reports/aes_top_timing_summary_routed.rpt

Original RTL: https://github.com/KartikYadav020307/buildx-demo/blob/main/Experiment-1-Beginner/RTL/aes_core.v

AMD implementation strategy documentation: https://docs.amd.com/r/2025.2-English/ug904-vivado-implementation/Directives-Used-by-phys_opt_design-and-route_design-in-Implementation-Strategies
