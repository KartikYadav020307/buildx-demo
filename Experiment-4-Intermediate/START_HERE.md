> **Current submission package:** The board build and physical verification are complete.
> Start with [README.md](README.md) and [the current checklist](Documentation/SUBMISSION_READINESS.md).
> The original preparation guide below is preserved; its pending-hardware/no-prebuilt-file statements describe the earlier source pack, before the successful user build.

# Project 4: complete implementation plan and execution guide

**Title confirmed from page 4 of your uploaded original BuildX conversation:**
**Design of an FPGA-Based Hardware Accelerator for Low-Latency Neural Network Inference.**

We are placing this in `Experiment-4-Intermediate`, following your five-project
plan. The submission guidelines require two intermediate experiments within
the five-experiment submission. The title is kept exactly as provided.

## Fastest execution: run the local build first

The implementation is already supplied. Keep the frozen weights and current
4 → 4 → 3 architecture to save time.

1. Extract the complete pack so `C:/FPGA/Project4_NN/RUN_PROJECT4.cmd` exists.
   Use a short folder path without spaces. Keep all subfolders together.
2. Close an already-open `NN_Inference` project in Vivado, then double-click
   `RUN_PROJECT4.cmd`. It finds common Vivado 2025.1.1/2025.1 installation paths.
   If detection fails, open Command Prompt here and supply the actual path:
   `RUN_PROJECT4.cmd "D:\AMDDesignTools\2025.1.1\Vivado\bin\vivado.bat"`.
3. Leave the console open. The script creates/opens the project, runs all HDL
   checks using XSim, and stops on any failure. A pass starts synthesis and
   implementation using two worker jobs, then creates the bitstream and reports.
   Build duration depends on the laptop; no fixed completion time is promised.
4. Require a fresh `Results/BUILD_SUCCESS.txt`. Inspect `Results/timing_summary.rpt`
   for clock constraints, unconstrained paths, and timing checks, and
   `Results/drc.rpt` for unresolved issues. The script checks the worst setup and
   hold slack but does not replace the complete report review.
5. Open `build/NN_Inference.xpr` in Vivado and continue with the Hardware Manager
   steps below. Programming files are `Results/nn_board_top.bit` and
   `Results/nn_board_top.ltx`. Board validation still needs the physical PYNQ-Z2.

The launcher only performs the local tool build; it does not program a board.
On another run it resets generated synthesis/implementation runs and rebuilds
them, leaving source files intact. Do not run two copies at once. If it fails,
keep `Results/vivado_batch.log` and `Results/BUILD_FAILED.txt` when present.
Existing reports or programming files from older runs are not success evidence.

This cloud session cannot operate your Windows desktop. Icarus simulation has
been executed here; actual Vivado/XSim/Windows-launcher execution must happen
on the laptop. The manual sections below remain available for diagnosis.

## 1. What we are building

Build a small **trained neural-network classifier running in the programmable
logic of the PYNQ-Z2**. Supply four measurements of an Iris flower. The FPGA
returns one of three species and three numeric class scores. A second FPGA
implementation performs the same computation sequentially. Both run from
the same clock and use exactly the same trained weights and arithmetic.

The useful engineering result is the comparison: demonstrate how parallel
arithmetic and pipelining reduce inference latency while preserving every
integer output. This is the central contribution to explain to the judges.

| Decision | Exact choice and reason |
|---|---|
| Dataset | Corrected Iris data: 150 records, four measurements, three classes; bundled locally |
| Neural network | 4 inputs → 4 hidden ReLU neurons → 3 linear output neurons |
| Training | Offline NumPy training; already completed and exported |
| Split | 90 training, 15 validation, 45 held-out test records; stratified by class |
| Model selection | Validation classification count, then training loss; test data excluded |
| FPGA input | Four signed 8-bit standardized measurements, packed into 32 bits |
| Weights | Signed 8-bit trained constants with six fractional bits |
| Hidden activations | Signed 16-bit values with five fractional bits, ReLU and saturation |
| Sums / logits | Signed 32-bit arithmetic |
| Accelerator | Fully parallel layer products and five register stages |
| Comparison | One shared multiplier/MAC datapath with a small finite-state machine |
| Target clock | 50 MHz, generated from the board's external 125 MHz PL clock |
| Board interface | Vivado VIO through USB/JTAG, with sticky results and cycle counters |
| Physical indicators | One heartbeat LED, one result-ready LED, two class-code LEDs |

The board is officially specified as **XC7Z020-1CLG400C**. The Vivado part
identifier is **`xc7z020clg400-1`**. Selecting the chip directly avoids needing
PYNQ board-definition files.

For this project, the supplied pack needs **Vivado only**. Vitis HLS, Jupyter,
DMA, an AXI block design, and additional sensors are unnecessary for this
implementation. Python/NumPy are optional for retraining or converting your
own measurements. Existing weights and test data are already supplied.

## 2. Why this is a good competition scope

Your uploaded rubric gives technical correctness 40%, FPGA implementation
15%, documentation 15%, video 15%, and innovation 15%. Concentrate on a
working circuit with reproducible evidence and a clear hardware comparison.

The demonstration should establish all of the following:

1. The weights came from an actual trained network and are supplied in full.
2. Signed fixed-point FPGA outputs match an independent Python reference.
3. The pipeline accepts new inputs on consecutive clock edges in simulation.
4. The two FPGA architectures produce identical scores and classes.
5. On-board counters show their different core latencies.
6. Routed timing and hierarchical utilization establish what the FPGA build achieved.
7. The held-out dataset accuracy is reported separately from arithmetic correctness.

This is a defensible intermediate project. A working portfolio of all five
experiments, with strong evidence, helps your competition position. This
project alone cannot guarantee a prize or establish research novelty.

## 3. Schedule within your limited time

The code, model, and golden vectors are already prepared. Budget **two
90-minute active sessions plus up to 30 minutes of troubleshooting**, with
Vivado compilation running unattended between sessions. Build time depends
on your laptop; do not count it as a guaranteed short task.

| Session | Minutes | Work | Required outcome |
|---|---:|---|---|
| A | 0–10 | Extract files, open Vivado, check part support | Clean folder and correct Vivado launch |
| A | 10–25 | Run project-generation Tcl; inspect source hierarchy | Both IP cores and all source files present |
| A | 25–45 | Run behavioral simulation; inspect messages | ALL TESTS PASSED |
| A | 45–60 | Capture a short waveform and RTL schematic | Simulation evidence saved |
| A | 60–70 | Launch bitstream generation | Compilation started |
| A | 70–90 | Read arithmetic/pipeline explanation; prepare report | You can explain the design |
| Unattended | Variable | Synthesis, implementation, bitstream generation | Build completes without errors |
| B | 0–15 | Collect and inspect timing/utilization/DRC reports | Correct 50 MHz clock; timing passes |
| B | 15–30 | Connect and program the PYNQ-Z2 | Matching bitstream and probes loaded |
| B | 30–45 | Run automated held-out hardware test | All 45 cases match Python scores |
| B | 45–60 | Demonstrate three species and counters | Screenshots and board photo |
| B | 60–90 | Record a short video and complete report evidence | Submission-ready project material |

If the board is in the lab, perform session A on your laptop and bring the
entire folder, generated `.bit` and `.ltx`, and Vivado reports to the lab.
Use the same Vivado release there. Preserve relative folders when copying.

## 4. The exact neural-network calculation

The feature order is always:

1. Sepal length in cm.
2. Sepal width in cm.
3. Petal length in cm.
4. Petal width in cm.

Training-data mean and standard deviation are stored in `Data/model.json`.
The input conversion is performed offline:

```text
z[i] = (measurement[i] − training_mean[i]) / training_std[i]
xq[i] = clip(round_to_nearest_even(z[i] × 32), −128, 127)
```

The FPGA accepts `xq`, not raw centimetres. Byte zero is feature zero:

```text
features[7:0]   = xq[0]
features[15:8]  = xq[1]
features[23:16] = xq[2]
features[31:24] = xq[3]
```

Negative bytes use two's complement. For example, −32 is `e0`.

For each hidden neuron `j`, the FPGA computes:

```text
hidden_acc[j] = b1q[j] + sum_i(xq[i] × w1q[i,j])
hidden_q[j]   = clip(arithmetic_shift_right(hidden_acc[j], 6), 0, 32767)
```

For each output neuron `k`:

```text
score[k] = b2q[k] + sum_j(hidden_q[j] × w2q[j,k])
class_id = index_of_largest(score[0], score[1], score[2])
```

All biases use scale 2048. Hidden and input values use scale 32; weights
use scale 64. Consequently the products and raw scores use scale 2048.
Dividing a raw output score by 2048 gives its approximate real-valued logit.
The class decision uses the raw scores directly. Softmax is unnecessary for
argmax classification; we do not display a made-up confidence percentage.

Class codes are **0=setosa, 1=versicolor, 2=virginica**. Ties choose the
lowest index. Multiplications, sign extensions, comparisons, and arithmetic
right shifts are explicitly signed in the RTL.

There are **28 multiply-accumulate terms** per inference: 16 in the hidden
layer and 12 in the output layer. The parallel RTL has 28 product operations;
the sequential RTL shares one multiply datapath. Vivado decides the actual
DSP/LUT mapping, including optimizations of constant weights, so report its
measured utilization instead of assuming exactly 28 DSPs.

## 5. Pipeline and honest latency measurement

The timing convention is exact: **E0 is the rising edge that accepts an
input; latency is the number of clock periods from E0 to output-valid.**

| Edge | Parallel accelerator | Valid-data state |
|---|---|---|
| E0 | Register all 16 input × hidden-weight products | Input accepted |
| E1 | Sum products and bias, shift, apply ReLU, register four hidden values | Hidden layer complete |
| E2 | Register all 12 hidden × output-weight products | Output products ready |
| E3 | Sum output products and biases; register three logits | Scores ready internally |
| E4 | Register class, scores, and output-valid | Result available |

This is **five register stages and four elapsed clock periods**. Another
input may be accepted every clock. Do not confuse stage count with the
edge-to-edge latency definition.

The sequential design uses four MAC clocks and one store clock per neuron,
then an output decision clock: `4×5 + 3×5 + 1 = 36` elapsed periods. It can
accept its next input on the following edge, giving a minimum input interval
of 37 periods. Both architectures have been simulated against all 4,502
golden vectors.

| Metric | Parallel core | Sequential core |
|---|---:|---:|
| Simulated edge-to-edge core latency | 4 periods | 36 periods |
| Calculated latency at 50 MHz | 80 ns | 720 ns |
| Core input interval | 1 period | 37 periods |
| Calculated maximum core input rate at 50 MHz | 50 million/s | About 1.35 million/s |
| Numeric result | Same three integer scores | Same three integer scores |

The **9× latency reduction** compares the two FPGA architectures at the
same frequency. It is not a measured CPU/GPU speedup. The input-rate numbers
are arithmetic limits for the cores after timing closure, not measured
end-to-end application throughput.

The VIO demonstration sends one case at a time and waits for the slower
baseline. JTAG interaction is much slower than the computation. Our FPGA
controller captures the cycle counts and holds them, along with the result,
so the host can read them reliably. The controller sees output-valid on the
following edge and compensates for that observation edge in the counters;
the counters report the core's four and 36 periods. Controller and JTAG
overhead are excluded from those numbers.

Only report **80 ns as implemented FPGA core latency** once the generated
clock is 50 MHz, routed setup/hold timing passes, and the board test passes.

## 6. Files you will put into Vivado

| File | Role |
|---|---|
| `RTL/nn_parallel.sv` | Main pipelined accelerator |
| `RTL/nn_serial.sv` | Identical-model sequential baseline |
| `RTL/nn_demo_controller.sv` | Atomic requests, cycle measurement, comparison, sticky results |
| `RTL/nn_board_top.sv` | Clock Wizard, VIO, controller, physical LED outputs |
| `RTL/nn_weights.vh` | Actual trained integer weights and biases |
| `RTL/nn_math.vh` | Signed extensions, saturating ReLU, deterministic argmax |
| `RTL/pynq_z2.xdc` | Clock and LED pin constraints |
| `Testbench/tb_nn.sv` | Automated testbench |
| `Testbench/vector_count.vh` | Exact number of golden cases |
| `Data/golden_vectors.mem` | Independent Python integer reference outputs |

Keep the `.sv` extension. The two `.vh` files contain functions included
inside each core. Do not paste them as stand-alone modules. The supplied
Tcl registers their include paths automatically.

## 7. Execute: extract and create the Vivado project

1. Download `Project4_NN_Complete_Pack.zip`.
2. In Windows File Explorer, right-click → **Extract All**.
3. Place the included `Project4_NN` folder under `C:\FPGA`.
4. Check that this file exists: `C:\FPGA\Project4_NN\RTL\nn_parallel.sv`.
   Avoid an extra nested `Project4_NN\Project4_NN` directory.
5. Use a local folder rather than OneDrive for Vivado's generated build files.
6. Open the regular **Vivado 2025.1.1** desktop shortcut.
7. At the bottom, open **Tcl Console**. If hidden, use **Window → Tcl Console**.
8. Paste this one command and press Enter:

```tcl
source C:/FPGA/Project4_NN/Vivado/create_project.tcl
```

The script creates `build/NN_Inference.xpr`, selects the correct device,
adds all sources and test data, creates the 125→50 MHz Clocking Wizard and
VIO cores, and generates their output products. It does not run a build.

In **Sources**, verify:

- Design top is `nn_board_top`.
- Simulation top is `tb_nn`.
- IP cores are named `nn_clk` and `nn_vio`.
- Constraints include `pynq_z2.xdc`.

If you extracted elsewhere, use that actual path in the `source` command.
Use forward slashes in Tcl. Paths with spaces must be braced, for example:
`source {D:/My FPGA Work/Project4_NN/Vivado/create_project.tcl}`.

The script deliberately refuses to overwrite an existing project. For later
sessions, **Open Project → `build/NN_Inference.xpr`**. After editing RTL,
save the source and reset/relaunch the affected simulation/build runs.

## 8. Execute: simulate before building

1. In **Flow Navigator → Simulation**, click **Run Simulation → Run Behavioral Simulation**.
2. Let compilation and elaboration finish. The simulation can run for 4 ms
   of simulated time. That covers the full tests; it is not a four-minute wait.
3. If it stops early because of a GUI runtime setting, type `run all` in
   the simulation Tcl Console.
4. Require the final message **`ALL TESTS PASSED`**.
5. Any `$fatal`, missing memory-file message, or compilation error means
   stop and resolve that error before synthesis.

The expected pass lines identify:

```text
PASS reset abort/recovery, argmax ties, ReLU saturation
PASS parallel: 4502 vectors, full-rate bursts + bubbles, latency=4 periods
PASS wrapper: 150 Iris samples, held toggle, busy rejection, reset abort, counters
PASS serial: 4502 vectors, input latching, latency=36 periods
ALL TESTS PASSED
```

The ordering of the first pass lines can vary by simulator. The final pass
is reached only after all independent test processes complete.

The 4,502 golden vectors contain all 150 Iris records, all 256 combinations
of the chosen byte extremes `−128, −1, 0, 127`, and 4,096 seeded random
signed-input vectors. Every class and every score is checked. Random/extreme
vectors test arithmetic correctness; they are not Iris accuracy test samples.

For a clear waveform screenshot:

1. Restart the simulation.
2. In Scopes, select `tb_nn`. Add `clk`, `rst`, `pin`, `px`, `pv`, `pc`,
   `sin`, `sv`, `sc` to the waveform.
3. Expand instance `p`; add `valid_pipe` if you want to show stage movement.
4. Use unsigned/hexadecimal radix for `px`; class codes are unsigned.
5. Run `run 1 us`, then zoom to the first accepted input.
6. Place cursors at the acceptance edge and matching parallel output edge:
   the difference is 80 ns with the testbench's 20 ns clock.
7. Save a screenshot under `Simulation/waveform.png`, and save the console
   transcript as `Simulation/transcript.txt`.

The bundled Icarus transcript is already-verified evidence. The screenshot
from your Vivado session establishes that your local project runs correctly.

## 9. Execute: synthesize, implement, and inspect the build

1. Close the simulation when the tests pass.
2. In the main project Tcl Console, run:

```tcl
source C:/FPGA/Project4_NN/Vivado/build_bitstream.tcl
```

3. Monitor the **Design Runs** tab. Synthesis and implementation must
   finish, followed by bitstream generation. Two jobs limit laptop memory load.
4. When complete, run:

```tcl
source C:/FPGA/Project4_NN/Vivado/collect_reports.tcl
```

This writes `Results/nn_board_top.bit`, matching `nn_board_top.ltx`, and
timing, hierarchical utilization, clock, and DRC reports. The `.ltx` tells
Hardware Manager how to identify and display the debug probes.

Inspect the results rather than relying on “bitstream generated” alone:

- Clock report: the input period is 8 ns and accelerator clock is 20 ns.
- Timing: setup WNS ≥ 0, hold WHS ≥ 0, and no unresolved failing paths.
- Timing summary/check_timing: no missing internal clock or unconstrained
  datapath between the accelerator registers.
- DRC: no unresolved errors or critical clock/pin constraint problems.
- Hierarchical utilization: inspect `u_demo/u_parallel`, `u_demo/u_serial`,
  `u_vio`, and the clocking/debug overhead separately.

The status LEDs are intentionally false-pathed as asynchronous human-visible
indicators. That does not waive timing on the inference cores.

To obtain the RTL schematic, **RTL Analysis → Open Elaborated Design →
Schematic**. Expand `u_demo` and the two core instances. Capture a readable
view as `Images/rtl_schematic.png`.

## 10. Execute: program your PYNQ-Z2 in the lab

1. Use the board's existing working power arrangement from your AES demo.
2. Connect a data-capable Micro-USB cable to the board's **USB/JTAG-UART
   programming connection**, and to the computer running Vivado.
3. Keep the board's known-working boot arrangement. If a PYNQ SD image is
   normally used, let it boot before programming the PL. This design uses
   the external 125 MHz clock on H16, rather than a software-enabled PS
   fabric clock. The external clock comes from the Ethernet PHY; board
   initialization/PHY reset can affect its availability.
4. No sensor, breadboard, or external GPIO wiring is required.
5. In Vivado, **Open Hardware Manager → Open Target → Auto Connect**.
6. Select the **xc7z020** FPGA device; the ARM debug/DAP entry is not the
   FPGA bitstream-programming target.
7. Right-click the FPGA → **Program Device**.
8. Set Bitstream file to `Results/nn_board_top.bit`.
9. Set Debug probes file to `Results/nn_board_top.ltx` from the same build.
10. Click **Program** and wait for completion. Refresh the device if needed.
11. The heartbeat LED should blink whenever the 50 MHz clock is running,
    including while the accelerator is held in reset.

If no heartbeat or VIO appears, check the board clock/boot, cable, and matching
programming files before changing the neural-network RTL.

Do not load a PYNQ overlay in Jupyter during this demonstration; it would
replace the currently programmed PL design.

## 11. Execute: automated hardware validation

Once the board is programmed and the VIO is visible, paste:

```tcl
source C:/FPGA/Project4_NN/Vivado/hardware_test.tcl
```

The script resolves the named probes, resets the accelerator, sends all
45 held-out Iris cases, and checks all three FPGA logits against the Python
reference. It checks that the parallel and sequential cores agree and that
their counters are four and 36. It polls `completed_count`, so an old sticky
`done` cannot be mistaken for a new result.

Expected completion for the supplied frozen model:

```text
HARDWARE PASS: 45/45 cases match every Python integer score.
Model classification accuracy: 43/45 = 95.56%
Core cycles: parallel=4, sequential=36; latency reduction=9x at the same clock.
```

**45/45 arithmetic matches and 43/45 correct labels are different results.**
The two classification mistakes are model errors, not hardware mismatches.
Keep both numbers in your report. The test script saves the measured case
results to `Results/hardware_test_results.csv`.

For all 150 data records, after the script has been sourced:

```tcl
nn_run_test all
```

This creates a second results CSV. Report 45-case held-out accuracy as the
generalization result; don't replace it with training-data accuracy.

## 12. Manual live demo and the exact VIO mapping

| VIO port | Signal | Width | What to do / read |
|---|---|---:|---|
| probe_out0 | control_reset | 1 | 1 holds core reset; 0 releases it |
| probe_out1 | cmd_toggle | 1 | Toggle 0→1 or 1→0 to request exactly one inference |
| probe_out2 | features | 32 | Packed signed input bytes; set hexadecimal radix |
| probe_in0 | busy | 1 | Wait for 0 before the next command |
| probe_in1 | done | 1 | Sticky completion indicator |
| probe_in2 | mismatch | 1 | Must stay 0 for the two cores to agree |
| probe_in3 | parallel_class | 2 | 0, 1, or 2 |
| probe_in4 | serial_class | 2 | Must equal parallel_class |
| probe_in5 | parallel_cycles | 8 | Expected 4 |
| probe_in6 | serial_cycles | 8 | Expected 36 |
| probe_in7 | score0 | 32 | Signed raw setosa logit |
| probe_in8 | score1 | 32 | Signed raw versicolor logit |
| probe_in9 | score2 | 32 | Signed raw virginica logit |
| probe_in10 | completed_count | 32 | Increments once per finished request |

VIO output probes drive the design; input probes observe it. Use signed
decimal radix for logits, unsigned decimal for classes/counters, and hex for
packed features. A negative 32-bit score displayed in hex will begin with
`ffff`; that is normal two's-complement representation.

For a GUI-only demo, reset with `control_reset=1`, set `cmd_toggle=0`, then
release reset. Commit input `features` before changing `cmd_toggle`. If the
GUI uses an explicit **Commit** button, commit each operation. Change input
and toggle in separate commits. Wait for `completed_count` to increment.
Do not send another toggle while busy. Leaving the toggle high is safe: only
a change generates a request.

| Test record | Measurements (SL, SW, PL, PW), cm | Feature hex | Expected class | Raw scores (0, 1, 2) |
|---|---|---|---|---|
| 4 | 5.0, 3.6, 1.4, 0.2 | `d6d528e0` | 0: setosa | 19058, 2857, −24757 |
| 50 | 7.0, 3.2, 4.7, 1.4 | `09110b2a` | 1: versicolor | −8102, 8917, −3790 |
| 100 | 6.3, 3.3, 6.0, 2.5 | `37281210` | 2: virginica | −13784, −6177, 16696 |

All three are held-out records for the supplied split. After sourcing the
hardware script, you can also run them directly in Tcl:

```tcl
nn_run_case d6d528e0
nn_run_case 09110b2a
nn_run_case 37281210
```

Use either the GUI or the supplied Tcl helpers for a run. If you switch from
manual GUI toggles back to Tcl, call `nn_hw_reset` first so the script's
toggle/counter state is synchronized with hardware.

LED meaning: LD0 heartbeat, LD1 done, LD2 class bit 0, LD3 class bit 1.
Setosa has both class LEDs off; versicolor has LD2 on; virginica has LD3 on.
Read class LEDs only after done is on.

## 13. Optional Python work

You can finish the FPGA build with the supplied frozen weights without
installing any Python packages. If you want reproducible training or custom
input conversion, install NumPy from Windows Command Prompt:

```bat
py -m pip install -r C:\FPGA\Project4_NN\python\requirements.txt
```

Regenerate constants, vectors, and metrics from the supplied frozen model:

```bat
py C:\FPGA\Project4_NN\python\train_export.py --check
```

Train again from the bundled data, selecting a checkpoint using validation
data, and regenerate hardware exports:

```bat
py C:\FPGA\Project4_NN\python\train_export.py
```

Convert a fresh measurement set:

```bat
py C:\FPGA\Project4_NN\python\predict.py 5.0 3.6 1.4 0.2
```

The script prints the hex feature word and the expected integer outputs.
Rebuilding is necessary after changing exported weights. Keep the original
frozen-model pack for comparison; report the metrics from the exact model
used to generate your bitstream.

## 14. Report, evidence, and the demo video

Use `Documentation/report_outline.md` for the seven sections required by
the supplied rules. Complete its hardware sections after the board test,
then export the report to PDF. Keep the project inside the team's one GitHub
repository under `Experiment-4-Intermediate` and include its video link.

Capture these items during execution:

- One architecture figure (included in `Images`).
- One readable elaborated RTL schematic.
- Behavioral simulation waveform and pass transcript.
- Routed timing, generated-clock, DRC, and hierarchical utilization reports.
- A photo showing the board, cable, and computer.
- A VIO screenshot showing class, scores, mismatch=0, and counters 4/36.
- The automated 45-case hardware-test console output and CSV.
- `.bit` and matching `.ltx`, source files, constraints, test data, and project scripts.

The short presentation sequence is:

1. **0–20 s:** State the title, PYNQ-Z2, and the 4→4→3 trained model.
2. **20–50 s:** Explain offline training versus actual FPGA inference.
3. **50–90 s:** Show the two architectures and the five pipeline stages.
4. **90–120 s:** Show the passing testbench and held-out model accuracy.
5. **120–180 s:** Demonstrate all three species on the physical board; show
   equal FPGA scores and the four-versus-36 counters.
6. **180–210 s:** Show the timing/utilization evidence; state the scope of
   latency measurement and explain the two held-out model errors honestly.

For the judge's “why FPGA?” question, explain concurrent arithmetic,
deterministic clocked latency, fixed-point storage/computation, and the
resource-versus-speed tradeoff. For “does this handle any neural network?”,
explain that this build targets one trained MLP topology with compile-time
weights. Other trained weights can be exported and rebuilt. Run-time model
loading is future work.

## 15. Troubleshooting in the right order

| Symptom | Check / next action |
|---|---|
| `xc7z020clg400-1` unavailable | Modify AMD installation to add Zynq-7000 device support |
| `.vh` not found | Confirm include_dirs and intact `RTL` folder; create via supplied Tcl |
| SystemVerilog syntax errors | Keep `.sv` extensions; do not use a Verilog-only file type |
| Golden vectors missing | Check `Data/golden_vectors.mem`; absolute GOLDEN_FILE generic is set by script; inspect Simulation Settings → Elaboration generics |
| IP `nn_clk` or `nn_vio` missing | Check Sources → IP and Generate Output Products; inspect first Tcl error |
| Build fails | Open first synthesis/implementation error; later errors are often consequences |
| Negative setup or hold slack | Inspect the failing path and clock; do not accept the 50 MHz performance claim until fixed |
| Hardware target absent | Data-capable cable, board power, programming USB port, cable drivers, Auto Connect |
| FPGA visible, no VIO | Correct same-build `.bit/.ltx`; refresh device; confirm heartbeat/free-running clock |
| No heartbeat | Power/boot/PHY clock on H16 or MMCM lock problem; establish clock before debugging inference |
| `done` never changes | Release control_reset; commit features; toggle cmd_toggle; check completed_count |
| Old done mistaken for new result | Use completed_count increment; done is sticky |
| Feature produces a different species | Check byte order, standardization, signed values, and exact frozen weights |
| Negative score looks huge | Select signed decimal radix; raw bits are two's complement |
| Tcl cannot resolve probe names | List `get_hw_probes -of_objects [get_hw_vios]`; inspect actual NAME values and matching `.ltx`; keep the first error |
| Sequential/parallel mismatch | Preserve the input case and output values; rerun behavioral simulation with matching weights before changing logic |

If you need help with an error, provide the first error text, its source-file
line, and your Vivado version. For a hardware problem, include the VIO table
and whether the heartbeat runs. Those distinguish build, clock, transport,
and arithmetic faults quickly.

## 16. What is verified now and what remains

Verified during preparation: deterministic model export, held-out integer
accuracy, SystemVerilog compilation with Icarus 12.0, both cores against
4,502 independent vectors, pipeline bursts and bubbles, accepted-input
latching, command hold/busy behaviour, reset abort/recovery, deterministic
ties, ReLU saturation, and the demo controller's latency counters.

Pending on your equipment: Vivado 2025.1.1 compilation/IP generation,
synthesis/implementation, routed timing and resource figures, and physical
PYNQ-Z2 execution. No prebuilt FPGA files or on-board performance results
are claimed in this pack.

## Primary references

- AMD PYNQ-Z2 device, clocks, and USB-JTAG:
  https://www.amd.com/en/corporate/university-program/aup-boards/pynq-z2.html
- AMD/Xilinx PYNQ-Z2 lab pin constraints (H16 clock and four LED pins):
  https://github.com/Xilinx/xup_fpga_vivado_flow/blob/main/source/pynq-z2/lab5/uart_led_pins_pynq.xdc
- Vivado 2025.1 VIO tutorial:
  https://docs.amd.com/r/2025.1-English/ug936-vivado-tutorial-programming-debugging/Using-a-VIO-Core-to-Debug-a-Design-in-Vivado-Design-Suite
- VIO product guide PG159:
  https://docs.amd.com/v/u/en-US/pg159-vio
- Vivado 2025.1 commit and refresh commands:
  https://docs.amd.com/r/2025.1-English/ug835-vivado-tcl-commands/commit_hw_vio
  https://docs.amd.com/r/2025.1-English/ug835-vivado-tcl-commands/refresh_hw_vio
- Iris source and corrected dataset loader:
  https://archive.ics.uci.edu/dataset/53/iris
  https://scikit-learn.org/stable/modules/generated/sklearn.datasets.load_iris.html

Competition title/rubric sources: your uploaded original BuildX chat,
page 4, and `documents req(1).pdf`, pages 1–6. The supplied guidelines have
an older September 23 deadline; use the organizers' current deadline for
your submission schedule.
