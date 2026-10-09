# Original native Vivado source project

`Project4_NN_Vivado_Source_Project.zip` contains the original laptop's
`build/NN_Inference.xpr`, Clocking Wizard and VIO `.xci` files, and the generated
debug constraint file, with RTL, frozen data, testbenches and build scripts.
`ORIGINAL_NATIVE_MANIFEST.json` records exact original descriptor/IP hashes.

The descriptor retains its original machine paths and historical run status.
Generated implementation runs, caches and simulator executables are excluded.
For a portable clean rebuild, extract the archive and use `RUN_PROJECT4.cmd`
or `Vivado/create_project.tcl` in Vivado 2025.1.1. The archive has not been
opened and rebuilt as a native project during this documentation task.
The original matching routed BIT/LTX pair remains separately in `Results/`.
