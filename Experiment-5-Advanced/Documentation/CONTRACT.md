# Frozen implementation contract

Raw fields are `u:a:v:d`, four bits each; valid levels are 0..4. Four thermometer bits per feature encode level L with its lowest L bits one. Bit 0 represents -1 and bit 1 represents +1. The network is 16-16-4; hidden bit j is one when `popcount(XNOR(x,w_j))>=T_j`. Output score is `2*popcount(XNOR(h,w_c))-16+b_c`. Higher class index wins equal scores; margin is best minus runner-up, including ties.

Popcount is 5 bits, thresholds 0..17, signed bias -128..127, signed score 9 bits (-144..143), margin 9 bits (0..287). Balanced popcount trees are used. Arbitrary runtime weights are supported, not only the shipped monotone projection.

Parallel acceptance E0 -> hidden popcounts E1 -> hidden bits E2 -> output popcounts E3 -> scores E4 -> registered neural telemetry and final action E5. The predecision interface feeds the safety register at E5, avoiding an accidental sixth period. II is 1. Folded acceptance E0 -> 16 hidden neurons E1..E16 -> four scores E17..E20 -> class/margin E21; next acceptance E22. In live mode the folded core is disabled; it only runs during disarmed manual comparisons.

Banks expose 42 canonical 16-bit words: 0..15 hidden weights; 16..19 output weights; 20..35 thresholds; 36..39 sign-extended biases; 40 nonzero model ID; 41 minimum margin. BEGIN invalidates an inactive bank and clears its completeness bitmap. WRITE checks ranges and padding. READ requires a written word. SEAL uses CRC-16/CCITT-FALSE: polynomial 0x1021, initial 0xffff, no reflection, final XOR zero. For each ascending address feed address byte, high word byte, low word byte. The serial seal measures exactly 1008 cycles. COMMIT blocks acceptance, drains both cores, then switches bank and ID together. The previous image remains sealed for rollback. Active writes/abort/begin are refused.

The VIO mailbox stages `command`, `bank`, `address`, `payload`, then toggles `request`. Payload remains stable until `ack`. A held toggle executes once. Reset aligns request/ack to retained VIO outputs and reports RESET_ABORT (0x80); host must reinitialize both images. CRC failures preserve the active bank and return the inactive image to loading.

| Command | Payload / behavior |
|---:|---|
| 1 | BEGIN bank |
| 2 | WRITE address with low 16 payload bits |
| 3 | READ address; canonical word in readback |
| 4 | SEAL using expected CRC in low 16 bits |
| 5 | COMMIT sealed inactive bank |
| 6 | ABORT inactive bank |
| 7 | Manual compare: raw bits 15:0, sensor-valid bit 16; live mode must be disabled |
| 8 | Live scenario: raw bits 15:0, sensor-valid bit 16, host RUN bit 17 |
| 9 | Pause generation using payload bit 0 |
| 10 | Explicit clear/arm; eligible only with fresh safe decision |
| 11 | Disarm and leave live mode; acknowledge after cores drain |

| Status | Meaning |
|---:|---|
| 0x00 | Success |
| 0x01 | Protected active-bank access |
| 0x02 | Wrong bank state / incomplete image / unwritten read |
| 0x03 | Illegal address, range or padding |
| 0x04 | CRC mismatch |
| 0x05 | Invalid commit target |
| 0x06 | Unknown command |
| 0x11 | Manual/mode request refused (busy, live, no model) |
| 0x12 | Clear/arm refused |
| 0x13 | Manual frame invalid |
| 0x14 | Parallel/folded mismatch |
| 0x80 | Reset aborted prior state; reinitialize |

Safety faults win over clear and safe results. STOP latches on emergency, invalid frame/sensing, hard critical guard, watchdog or a live neural STOP. Disarmed/no-model/reset outputs STOP. Model commits/new-result wait and low margin floor the proposal to BRAKE. The watchdog saturates at 500000 cycles, refreshed by valid current-model decisions; a fresh result wins watchdog expiry, independent faults still win. Critical guard trips one period after a presented legal critical frame, including held frames during commit. Invalid data trips on its presentation edge.

Clear/arm needs RUN, a valid active model, released emergency, last legal sensor frame, no pending commit/awaiting result, empty cores, no simultaneous acceptance, matching latest accepted/completed sample and model IDs, fresh CONTINUE and adequate margin. Faults win on the clear edge. Switching never clears STOP.

`history` bits 0..4 record emergency, invalid input, critical guard, watchdog and neural STOP. `reasons` also includes bit 5 low margin, bit 6 commit/new-model pending, bit 7 disarmed, bit 8 no model. History is sticky until an eligible clear or reset; reasons and action are registered. The registered reasons mask can lag a newly updated action/history by one period; at the slow VIO display rate they are stable together. `model_id` is active ID; `result_model` identifies captured neural telemetry.

The current scenario is sampled every 50000 cycles. A pending frame is held during commit. New scenario commands affect subsequent generated frames; they do not mutate a previously captured frame. Button inputs use two-stage synchronizers. Emergency assertion bypasses the neural pipeline and has no long debounce. Clear/next buttons have event suppression; no clocks are gated.
