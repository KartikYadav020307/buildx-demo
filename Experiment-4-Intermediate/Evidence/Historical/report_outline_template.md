# Report outline — Project 4

**Design of an FPGA-Based Hardware Accelerator for Low-Latency Neural Network Inference**

**Working outline: complete the physical implementation evidence before
exporting this as the submission PDF.** The source pack has been simulated;
it has not been programmed onto the user's board during preparation.

Team: [enter team name, member names, registration numbers]
Board: PYNQ-Z2, Zynq-7000 XC7Z020-1CLG400C.
Tools: Vivado 2025.1.1; optional NumPy training/reference scripts.

## 1. Objective

Implement a trained 4-input, 4-hidden-neuron, 3-output neural network in FPGA
logic. Compare a parallel pipelined architecture with a sequential shared-MAC
architecture using identical integer arithmetic. Validate every output against
an independent Python reference and measure core latency in clock periods.

## 2. Block diagram

Insert `Images/block_diagram.png`. Explain the shared request path, two FPGA
cores, comparison logic, sticky outputs, and VIO connection. Model training
and feature standardization are offline host activities.

## 3. RTL design

Explain `nn_board_top`, `nn_demo_controller`, `nn_parallel`, and `nn_serial`.
Give the file/module hierarchy. Describe signed 8-bit inputs and weights,
16-bit ReLU activations, 32-bit biases/sums, five pipeline register stages,
valid bits, and the sequential MAC finite-state machine.

The input scaling is 32, weight scaling is 64, and raw-score scaling is
2048. Hidden-layer sums are arithmetically shifted right by six, then clipped
to [0,32767]. Ties in argmax select the lowest class index. Weights are
compile-time constants exported from a trained model.

## 4. Simulation results

The supplied simulation uses 4,502 independent integer-reference vectors:
150 Iris records, 256 signed-extreme combinations, and 4,096 random inputs.
It verifies all three scores and the class code for both cores. Additional
checks cover streaming bursts and bubbles, input latching, reset abort and
recovery, held toggle commands, busy-command rejection, argmax ties, and
ReLU saturation.

The preparation run passes with Icarus Verilog 12.0. Add the user's Vivado
XSim transcript and waveform, and state its actual result.

Model dataset split: 90 train, 15 validation, 45 held-out test. Normalization
uses training data only. Model/checkpoint selection uses validation accuracy
then training loss. On the held-out test, the frozen floating-point and
integer models both correctly classify 43/45 records (95.56%) and predict the
same class on all 45 records. The two integer-model classification mistakes
are Iris records 68 and 138; they are not arithmetic mismatches.

Held-out confusion matrix, rows=true class and columns=predicted class:

| True / predicted | setosa | versicolor | virginica |
|---|---:|---:|---:|
| setosa | 15 | 0 | 0 |
| versicolor | 0 | 14 | 1 |
| virginica | 0 | 1 | 14 |

## 5. Hardware implementation

Add the actual board photo, VIO screenshots, automated hardware-test CSV,
clock report, DRC result, and routed timing summary. Record the exact source
revision used for the `.bit` and `.ltx` files.

| Result | Parallel core | Sequential baseline |
|---|---|---|
| Actual generated clock frequency | [read clocks.rpt] | same clock |
| Simulated latency | 4 periods | 36 periods |
| Board counter result | [measure] | [measure] |
| Calculated ns at verified frequency | [calculate] | [calculate] |
| Hierarchical LUT count | [read utilization report] | [read utilization report] |
| Hierarchical register count | [read utilization report] | [read utilization report] |
| Hierarchical DSP count | [read utilization report] | [read utilization report] |
| Worst setup/hold slack | [read timing report] | [read timing report] |
| Held-out score matches | [hardware count]/45 | [hardware count]/45 |

If 50 MHz timing and board tests pass, the core latencies are 80 ns and
720 ns, a 9× reduction for this model at equal clock frequency. This is
an FPGA architecture comparison. VIO/JTAG and wrapper overhead are excluded.
One-result-per-cycle core throughput is verified in simulation; sustained
end-to-end throughput is not measured by this VIO demonstration.

## 6. Applications

Small, deterministic embedded classifiers can be used for sensor-feature
classification and other low-dimensional inputs. This build demonstrates
the inference architecture on a flower dataset; it does not validate those
other applications or perform image recognition.

## 7. Conclusion

Summarize the measured FPGA results, integer-reference agreement, model
accuracy, and resource/latency tradeoff. Discuss run-time weight loading,
larger models, and streaming host interfaces as future extensions. State
that the model is small and the held-out dataset contains only 45 records.

Append the primary references from START_HERE.md and the dataset attribution.
