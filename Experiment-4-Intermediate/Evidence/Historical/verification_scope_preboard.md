# Verification scope

Preparation date: 2026-10-03.
Local build automation added: 2026-10-06.

Executed:

- NumPy model training with fixed split and weight seeds; frozen model export.
- 90/15/45 train/validation/test separation; training-only standardization.
- Fixed-point reference scoring and held-out accuracy calculation.
- Icarus Verilog 12.0 SystemVerilog compilation of the inference cores,
  demo controller, and testbench.
- 4,502 independent vector comparisons for each core, checking all scores
  and class labels. Parallel full-rate bursts and validity bubbles are tested.
- Accepted-input latching; reset cancellation/recovery; busy-command rejection;
  no repeated inference from a held command; sticky result and cycle counters.
- Argmax tie behaviour and saturating ReLU helper edge cases.
- Testbench writes its simulation pass marker only after all checks complete.
  Updated testbench rerun with Icarus; all 4,502 cases per core still pass.
- Build orchestration checked with mocked Tcl commands, including simulation
  failure, stale-marker removal, timing failure, and successful artifact collection.
  These checks exercise host control logic; they are not Vivado execution.
- Board-top syntax/port connectivity compilation with temporary IP stubs
  (not a simulation of AMD vendor IP).
- Tcl syntax completeness and a mocked 45-case check of the hardware-test
  script's probe lookup, signed values, CSV parsing, and host control logic
  (not a physical-board test).

Results:

- All HDL tests pass; see `Simulation/verified_iverilog_transcript.txt`.
- Core latency: parallel 4 clock periods; sequential 36 clock periods.
- Frozen model: 43/45 held-out labels correct; integer and float predictions
  agree on all 45 held-out records. No Iris inputs clip at the chosen scaling.

Not executed during preparation:

- Vivado IP generation, XSim, synthesis, placement, routing, or bitstream generation.
- Execution of the Windows `.cmd` launcher on Windows.
- AMD vendor implementation of the Clocking Wizard and VIO IP.
- PYNQ-Z2 programming, live USB/JTAG interaction, or hardware data collection.
- Physical timing/resource/power measurements or sustained application throughput.

The Vivado Tcl flow targets 2025.1.1 and uses documented AMD interfaces.
It must still be run on the installed Vivado and checked as described
in START_HERE.md. There is no prebuilt `.bit`, `.ltx`, or `.xpr` in this pack.

The on-board counters report core edge-to-edge latency, compensating for
the controller's one-cycle observation delay. They do not measure JTAG or
host-to-board response time. The calculated 80 ns/720 ns values depend on
successful implementation and verification of a 50 MHz generated clock.
