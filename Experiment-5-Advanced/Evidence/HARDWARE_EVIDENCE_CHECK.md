# Earlier recording evidence

This note describes the earlier recording and saved hardware observations. The replacement final demo is listed in Documentation/VIDEO_REVIEW.md; its content has not been independently reviewed.

# Original hardware exports verified

The original HARDWARE_CORE_PASS.txt, HARDWARE_LIVE_PASS.txt and hardware_test_results.csv have been copied byte-for-byte into Results/run_20261008_121952_125/.

The 64 CSV rows contain 32 normal-model and 32 cautious-model cases. Every row was compared with the committed Data/<profile>_hardware_cases.csv: hidden bits, all four signed scores, class, margin, model ID and cycle counts agree. All reference_match fields are 1; all fast_cycles are 5 and folded_cycles are 21.

The core marker also records CRC rejection, active-write protection, switching and rollback. The live marker records A/B switching, neural/critical/invalid-input STOP, 10 ms watchdog and safe clear. These are original test exports, not newly rerun physical tests.

The automated live PASS does not change the final recorded demo ending, which remained STOP. A replacement final edit is now linked; these observations remain the record for the earlier footage. Physical-button evidence remains the recorded video and earlier console observations.
