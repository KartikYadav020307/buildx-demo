# Final validation - Project 1

Review date: 10 October 2026 (Asia/Kolkata). Team: Beyond Boolean; Shanshank Pulipati 25BEC0573; Kartik Yadav 25BEC0087. Baseline main: `3df784fb57d35c7d0635ddc98c66a815144bba49`.

## Inputs and source identity

Both supplied continuity snapshots are byte-identical and were read along with the pasted deep AI-use audit, all six pages of the organizer PDF, and AESRepair.zip. The organizer PDF is byte-identical to `../../Submission_Guidelines/documents_req.pdf`. Historical statements were treated as context; current artifacts determined the results.

The repair package's entire original SHA256.json manifest passes. Its Original_RTL matches the repository's original RTL after Git checkout newline normalization; no logic/constraint discrepancy was found. The supplied candidate changes only the key-expansion previous-key selection/register and removes nonfunctional streaming-generation comments. Original AES transformations, ports, top wiring and 8 ns clock constraint remain. Original repository RTL/testbench/evidence were preserved without edits.

## Functional verification

104 reference triples in Testbench/vectors.mem were independently recomputed with PyCryptodome AES-ECB, one 16-byte block per pair; all ciphertexts agree. The original and repaired cores were independently compiled and simulated together in Vivado XSim 2025.1.1 on 10 October. All four final PASS markers were reached: 104 vectors, 21-cycle completion/one-cycle done/retention, input capture/mid-encryption reset/restart/held start, and cycle-by-cycle output equivalence. Actual log and VCD are in `../Timing_Repair/Validation/`; the plotted waveform is generated only from that VCD. The complete build also reran this regression before synthesis.

## Supplied checkpoint and programming files

The supplied repaired post-route checkpoint opened successfully. Timing, utilization, DRC, methodology, route status and bus skew were regenerated. WNS 1.490 ns, WHS 0.033 ns, WPWS 2.750 ns; zero setup/hold/pulse-width failing endpoints, zero no-clock pins and zero unconstrained internal endpoints. The sys_clk_pin clock remains 8 ns / 125 MHz. Bus-skew constraints all MET: 7.391, 7.100, 6.642, 7.250 ns. Integrated resources: 2860 LUTs, 4043 FF, zero BRAM, zero DSP.

Generating a bitstream from this supplied checkpoint reproduced the exact configuration payload; only nonconfiguration header fields such as the timestamp differ. Regenerated LTX JSON exactly matches the supplied probe JSON. Previous-key register cells are present in the netlist. Recheck reports are in `../Timing_Repair/Validation/Checkpoint_Recheck/`. These checks do not constitute physical-board execution.

## Fresh complete reproduction

The final `../Timing_Repair/BUILD_REPAIRED.tcl` was run unchanged from a fresh isolated directory in Vivado 2025.1.1. It completed IP generation, XSim regression, synthesis, placement/routing, explicit post-route optimization, setup/hold/pulse-width and coverage checks, bus-skew review, bitstream DRC, checkpoint/BIT/LTX export and BUILD_STATUS creation. Full log: `../Timing_Repair/Validation/fresh_build_2026-10-10.log`. Outputs: `../Timing_Repair/Reproduced_Outputs/`.

The fresh build independently reports the same WNS 1.490 ns, WHS 0.033 ns and WPWS 2.750 ns, zero failing/unconstrained internal endpoints, all four bus-skew constraints MET and the same resource totals. Its configuration payload matches the supplied repaired BIT, and probe JSON matches the supplied LTX. Use files from a single output set together; the supplied and reproduced checkpoint files have different packaging hashes and are retained separately.

Earlier attempts exposed an invalid supplied `post_route_phys_opt_design` run-step name and a run-status check that treats a completed route as incomplete when later strategy steps have not started. The corrected runner checks the completed route marker/checkpoint, opens the routed checkpoint directly and calls `phys_opt_design -directive Explore`. A temporary review edit used unsupported `redirect`; that edit was removed after checking Vivado's installed command help. The original valid `check_timing -verbose -file` form is retained. Bus-skew reporting/gating was added. Only the final complete successful run is presented as the accepted reproduction; supplied script bytes remain preserved in `Supplied/`.

## Warnings and native project

Both repaired output sets retain five DRC Warning checks: three PDCN-1569 LUT-equation and one RTSTAT-10 unroutable-load check in vendor dbg_hub, plus ZPS7-1 for the omitted PS7. Four LUTAR-1 methodology Warning checks concern debug-hub FIFO asynchronous-reset paths. No Error/Critical Warning checks are listed. Static timing does not eliminate these potential reset/boot hazards. Maintain the normal PYNQ power/boot setup and review PS initialization for deployment. The VIO out-of-context synthesis log also notes its default 10 ns versus integrated 8 ns clock; integrated routed timing is checked under the actual 8 ns constraint. No warning severity was lowered.

The curated repaired native source ZIP retains the original XPR relative layout, RTL, constraints, testbench/vectors, VIO XCI/generated dependencies and its referenced generated VIO DCP. All selected source/IP bytes match the supplied archive. It opened in an extracted copy with zero missing file references and up-to-date VIO. Missing disposable generated-run folders produce archive-opening warnings and are recreated by rebuilding. The original 71-file AES source archive remains unchanged. The independently checked Project 2 archive also opened with zero missing references.

## Physical evidence and remaining requirements

The genuine supplied recording frame now shows readable original plaintext, key and ciphertext. Its PNG bytes are unchanged; the older preview JPG and all earlier photographs/captures remain. The frame is original-demonstration evidence, not a test of repaired BIT/LTX. Both conceptual/source-derived diagrams match the unchanged top interface and keep their truthful non-Vivado-capture labels. Current project/regression PDFs were rendered and reviewed for figures, values, team spelling, sections and layout; the previous project PDF is byte-preserved in Documentation/Archive. Original Simulation/simulation_report.pdf is untouched.

No final Project 1 video URL was supplied; Video_Link.txt stays empty. Physical-board testing of repaired programming files remains pending. All required technical folder/file categories are present, but these pending checks prevent a claim of complete submission or complete hardware verification. No notebook/HWH/AXI functionality was fabricated. AI assistance in documentation and validation tooling is disclosed without inferring a percentage of HDL authorship.

The combined root report and root status summaries still contain older Project 1-2 material; refresh them only after separate authorization. Organizer deadline/naming need confirmation because the supplied PDF prints 23 September 2026 and different leader/team repository-name examples. Root files and Projects 3-5 remain outside the edit scope.
