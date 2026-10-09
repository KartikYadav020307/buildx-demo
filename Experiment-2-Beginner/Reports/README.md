# Original routed implementation reports

Recovered unchanged from the user-uploaded `Project2_Radar_Final (2).zip`, successful build `run_20261008_222502`, Vivado 2025.1.1, 8 October 2026. The seven reports and checkpoint came from original `Reports/`; `bus_skew_routed.rpt` came from the successful run's `project2_radar.runs/impl_1/radar_top_bus_skew_routed.rpt` (filename shortened only).

| Report | Verified result |
| --- | --- |
| timing_summary.rpt | WNS 12.176 ns, WHS 0.018 ns, WPWS 2.000 ns; no failing endpoints |
| bus_skew_routed.rpt | Four constraints MET; slack 19.081, 19.034, 19.339, 19.044 ns |
| utilization.rpt | Whole top, including VIO/debug hub: 2010 LUTs (1986 logic + 24 LUTRAM), 3329 FF, 0 BRAM, 0 DSP |
| check_timing.rpt | 0 unconstrained internal endpoints, 0 clock/loop issues; four intentionally false-pathed LED output ports have no output delay |
| clock_utilization.rpt / pulse_width.rpt | Original clock and pulse-width detail, retained alongside timing summary |
| drc.rpt | 0 Error/Critical Warning checks; 5 Warning checks, detailed below |
| methodology.rpt | 4 LUTAR-1 Warning checks inside vendor debug-hub FIFO reset logic |
| routed_design.dcp | Original routed checkpoint; not a new implementation |

DRC: three PDCN-1569 LUT-equation warnings and one RTSTAT-10 no-routable-load warning (19 nets) are inside vendor `dbg_hub`. ZPS7-1 identifies the missing PS7 block in this standalone PL demonstration. Retain the tested normal PYNQ boot/power setup; this evidence does not establish an independently bootable PS configuration. For deployment, review IP regeneration/tool-version behavior and PS initialization, and address or justify these warnings. Methodology LUTAR-1 warns about LUT-driven asynchronous resets in vendor debug-hub FIFOs; passing physical checks do not prove these potential reset hazards removed.

All warnings are reviewed and disclosed, not described as resolved or warning-free. The bus-skew report itself passes all four constraints despite the build log's request to review it. Power activity was not measured, so no power measurement is claimed. No RTL or bitstream was changed and no new board/build run is claimed.
