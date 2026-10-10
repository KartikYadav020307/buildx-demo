# Changes from the planning baseline

The exact project title, 16-16-4 topology, two runtime banks, independent guard, STOP latch, watchdog, sequential comparison, 50 MHz target and VIO workflow are retained.

**Dataset:** initial training against the proposed weighted/interacting risk oracle did not meet the 95% validation target in the compact network. Before freezing RTL, the synthetic policy was simplified to `r=d+v+a+u`. Normal thresholds are **4, 7, 10**; cautious thresholds are **3, 6, 9**. The labels are CONTINUE below the first threshold, CAUTION below the second, BRAKE below the third, and STOP otherwise. This is a deliberate change to the plan's proposed dataset, not an implementation of its original formula.

**Guarded policy is separate:** `d=4 && (v>=2 || a>=2)` independently forces a latched STOP. The raw BNN was trained against the severity-sum labels; guard overrides are assessed separately. For example raw `0024` gives normal neural CAUTION but final STOP under live operation. The guard is not counted as classifier accuracy.

**Trainer:** rather than the proposed gradient/STE procedure, the frozen models use reproducible discrete quantization-aware coordinate search. Hidden projections use +1 weights as a fixed monotone feature extractor. Integer hidden thresholds, binary output weights and integer output biases are learned from 375 training rows; validation chooses the checkpoint using accuracy then cross-entropy. No test labels are used to choose a checkpoint. Twelve seeded starts and 400 epochs are fixed in the supplied optional trainer. The complete FPGA datapath still accepts arbitrary binary weights and thresholds at runtime, which is covered by 1,024 diagnostic images.

**Results:** each frozen model obtains 125/125 validation cases, 125/125 held-out test cases and 625/625 domain cases. The simple synthetic dataset makes these figures straightforward; they do not establish real vehicle accuracy or safety. The domain metric includes training and validation examples and is not another held-out metric.

**Operator flow:** reset leaves no active model; the hardware script loads, reads back, seals and commits it. Presets are synthetic frames generated on the FPGA at 1 kHz. Live RUN is selected by the script and can also be requested by SW0 once live mode is selected. Physical button/switch positions must be checked before arming.

**Testing:** the source pack is locally simulated and linted. XSim and actual FPGA implementation run on the build workstation. Build/API mocks verify failure handling and host script consistency, and are explicitly not Vivado or physical-board evidence.
