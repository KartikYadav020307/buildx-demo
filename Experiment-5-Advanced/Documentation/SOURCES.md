# Primary technical references

Consulted for implementation interfaces and pins; the model/training/controller choices and measured test results are this project's own.

- AMD/Xilinx PYNQ-Z2 constraints: https://github.com/Xilinx/PYNQ/blob/master/boards/Pynq-Z2/base/vivado/constraints/base.xdc
- AMD/Xilinx BNN-PYNQ shared Z1/Z2 constraints (cross-check): https://github.com/Xilinx/BNN-PYNQ/blob/master/bnn/src/library/script/pynqZ1-Z2/pynqZ1-Z2.xdc
- AMD Vivado 2025.1 Tcl reference: https://docs.amd.com/r/2025.1-English/ug835-vivado-tcl-commands
- AMD VIO PG159: https://docs.amd.com/v/u/en-US/pg159-vio
- Courbariaux et al., binary neural-network training foundations: https://arxiv.org/abs/1602.02830
- Umuroglu et al., FINN/XNOR-popcount FPGA foundations: https://arxiv.org/abs/1612.07119

The delivered trainer uses discrete binary/integer search with a fixed monotone hidden projection; it does not claim to reproduce the original paper's gradient-training procedure. Pin assignments for buttons/switches/LEDs/clock are checked against the PYNQ-Z2 mappings. The initial input clock constraint is supplied by Clocking Wizard, avoiding duplicate definitions.
