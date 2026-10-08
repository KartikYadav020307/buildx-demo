# Hardware execution - use the current successful build

## 1. Before programming

Require the current run's `BUILD_SUCCESS.txt`. Read `timing_summary.rpt`, `clocks.rpt`, `drc.rpt`, `bus_skew.rpt`, `cdc.rpt`, `methodology.rpt`, and `utilization_hierarchical.rpt`. The automated gate requires zero failing setup/hold/pulse-width endpoints, zero DRC errors, no inferred latches and zero DSP cells in the BNN/system. CDC/methodology warnings still need their actual paths reviewed. Save the reports as competition evidence.

Use the same power/SD/boot/Ethernet-clock setup that gave Project 4 its working heartbeat/VIO. The external PL reference is the board's 125 MHz clock on H16. The design requires that reference to be running; board boot/PHY conditions can affect it. Do not change boot jumpers during a running demonstration. No PYNQ network or notebook operation is required by this design.

Keep **SW0=0, SW1=0**, release all buttons, connect USB-JTAG, power the board, and open `build\BNN_Safety.xpr`.

## 2. Program the matching pair

From Vivado's Tcl Console:

```tcl
source {C:/FPGA/Project5_BNN_Safety/Vivado/program_board.tcl}
```

This connects one JTAG target, selects the xc7z020 and programs the latest successful `.bit` with its matching `.ltx`. Alternatively use Hardware Manager -> Open Target -> Auto Connect -> Program Device and select `bnn_board_top.bit` / `bnn_board_top.ltx` from the path in `Results/LATEST_SUCCESS_PATH.txt`.

LED0 must blink after reset is released. LED1 is armed status. LEDs3:2 encode action: `00` CONTINUE, `01` CAUTION, `10` BRAKE, `11` STOP. STOP is expected before loading/arming.

## 3. Automated core verification

```tcl
source {C:/FPGA/Project5_BNN_Safety/Vivado/hardware_test.tcl}
```

It checks clock/reset/VIO, loads/readbacks/seals both models, verifies **32 cases per profile**, checks 5/21 cycles, rejects a corrupt CRC, rejects an active-bank write and performs switching/rollback. It finishes with normal model ID 1 active and the system disarmed.

Expected final line:

```text
HARDWARE CORE PASS: 64/64
```

The matching Results run receives `hardware_test_results.csv` and `HARDWARE_CORE_PASS.txt`. These are created only by this on-board script after successful checks. This does not by itself prove the physical emergency button or the whole live safety sequence.

For full-domain board verification, optionally run `bnn_verify 625` after the default test. JTAG makes this much slower; use the default 64-case run first.

If any error appears, stop the sequence and save the Tcl error plus the CSV. Don't change probe widths, score signedness or model data to hide a mismatch.

## 4. Automated live tests

```tcl
source {C:/FPGA/Project5_BNN_Safety/Vivado/hardware_safety_test.tcl}
```

This repeats a clean initialization and checks live A/B policy switching, neural STOP, critical guard, invalid level, invalid sensor flag, 10 ms timeout and explicit safe clear. It writes `HARDWARE_LIVE_PASS.txt` only on success and finishes disarmed. Keep both switches down and release BTN0 so physical controls do not interfere.

## 5. Physical demonstration

After either script has loaded both profiles:

```tcl
bnn_live 0000
bnn_arm
```

LED1 should turn on and action should be CONTINUE. Then:

```tcl
bnn_live 0222
bnn_commit 1
after 20
bnn_snapshot
```

The same `(d,v,a,u)=(2,2,2,0)` changes from normal CAUTION to cautious BRAKE without another programming operation. Commit temporarily floors the action to BRAKE; results carry their own `result_model` tag. `model_id` is the currently active model, so they can differ briefly while the pipeline is changing policies.

Now press **BTN0**. Action becomes STOP and remains STOP when you release it. `history` bit 0 is the emergency reason. Calling `bnn_arm` while BTN0 is pressed or while the scenario is unsafe must refuse.

Return to a safe scenario and press **BTN1**:

```tcl
bnn_live 0000
```

BTN1 is an explicit clear/arm request. It succeeds only with released emergency, legal/fresh CONTINUE, adequate margin and an empty pipeline. A refused request cannot clear a fault. If needed use `bnn_arm` after confirming the safe scenario; it retries occasional pipeline races without weakening the conditions.

Flip **SW1 up**: frame generation pauses, and within 10 ms since the last valid decision the output latches STOP (`history` bit 3). Flip it down: STOP remains latched. Explicitly clear with BTN1 after a fresh safe decision. **BTN2** cycles through six FPGA-generated scenarios; each remains selected until the next change. **BTN3** resets the design, clears the models and disarms it; after BTN3 you must initialize/load again.

## 6. Useful commands

| Command | Function |
|---|---|
| `bnn_snapshot` | Read current neural/guard/action/timing telemetry |
| `bnn_disarm` | Stop live operation and enable manual comparison |
| `bnn_run_case 0111` | Single raw frame with both cores, disarmed |
| `bnn_load cautious 1 1` | Reload inactive bank, demonstrate bad CRC then correct seal |
| `bnn_commit 0` | Roll back to sealed normal bank, without clearing STOP |
| `bnn_live 0024` | Critical guard; normal BNN proposes CAUTION, final action STOP |
| `bnn_live 0005` | Invalid level: immediate fault |
| `bnn_live 0000 0` | Invalid sensor flag: immediate fault |
| `bnn_pause 1` / `bnn_pause 0` | Pause/resume autonomous frames |

Before a manual `bnn_run_case`, call `bnn_disarm`. Before loading a bank, verify it is inactive using `bnn_snapshot`. Reconnecting VIO or releasing a button does not clear STOP.

## 7. Evidence to save

Save the current Results run, actual VIO screenshots, a board photo and the physical-button video. Add `Images/board_setup.jpg`, `Images/hardware_output.jpg`, `Images/rtl_schematic.png`, and the actual waveform screenshot under `Simulation/waveform.png`. Keep score displays signed where helpful; the helper already decodes signed nine-bit scores. Record routed resource values rather than estimating them.

100 ns is accepted feature frame to registered action at a confirmed 50 MHz clock. It excludes sampling, sensing, preprocessing, JTAG and actuator motion. The physical asynchronous emergency path uses synchronization; do not present it as a deterministic 100 ns pin-to-actuator guarantee.
