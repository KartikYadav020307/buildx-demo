# Earlier recording evidence

This note describes the earlier recording and saved hardware observations. The replacement final demo is listed in Documentation/VIDEO_REVIEW.md; its content has not been independently reviewed.

# Demo evidence and limitations

Final supplied demo: https://drive.google.com/file/d/11JItdx7IdNwuDhve5nBIV5tBiZsHoPV7/view?usp=sharing

The accepted edit removes waiting gaps and aligns board clips with screen commands. Clips 1-4 are associated by their visible LED states; their exact original synchronization is not established. Clips 5-8 were identified by the operator as the emergency, explicit-clear, watchdog and recovery steps.

| Step | What the available recording establishes |
|---|---|
| 1 | Screen shows HARDWARE CORE PASS: 64/64. HARDWARE LIVE PASS is in Evidence/hardware_live_console.log, not visible in this screen recording. |
| 2 | Safe input and explicit arm; safe board state. |
| 3 | Normal model 1, input 0222, action 1 CAUTION. |
| 4 | Commit bank 1: model/result ID 2, action 2 BRAKE for the same input. |
| 5 | Emergency STOP: tripped 1, history 1; STOP persists after release. |
| 6 | Fresh 0000 alone retains STOP; explicit BTN1 clear reaches action 0, tripped 0. |
| 7 | Watchdog STOP, history 8. Switch return/resume is not clearly captured in this take. |
| 8 | Commit bank 0 restores active model ID 1, but final snapshot retains result_model 2, action 3, history 8 and reasons 72. The attempted watchdog clear did not complete. Recording then disarms. |

Earlier copied operator snapshots showed watchdog age 500000, STOP retained after a fresh age 17206, and successful explicit recovery with action 0/tripped 0/history 0. They support the earlier test, not success of the final recording's step 8. Reason 72 includes watchdog and commit/new-model-pending bits; the precise physical switch condition cannot be recovered from this take.

The current edit is a hardware demonstration. It does not contain the full spoken team introduction, RTL/software architecture walkthrough and closing presentation requested by the organizers. A short presentation segment can accompany it; no successful final recovery should be implied over the recorded STOP state. Drive link access must be verified in a signed-out browser by the submitter.
