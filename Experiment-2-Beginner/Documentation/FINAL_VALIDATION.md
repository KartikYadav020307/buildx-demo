# Final validation - Project 2

Review date: 10 October 2026 (Asia/Kolkata). Team: Beyond Boolean; Shanshank Pulipati 25BEC0573; Kartik Yadav 25BEC0087.

Vivado 2025.1.1 reran the unchanged core and controller testbenches in isolated projects. Core PASS: 10,721 results / 12,963 accepted samples. Controller PASS: 33 frames, including the full 32-combination sweep and repeated standard frame; held-start and active-reset assertions passed. Logs: `../Validation_2026-10-10/`. The first attempt omitted simulator output directories and failed to write PASS markers; after creating those directories, both complete suites passed. No failed attempt is presented as a pass.

Reloading the original routed checkpoint reproduced setup 12.176 ns, hold 0.018 ns and pulse-width 2.000 ns, zero failing endpoints and zero unconstrained internal endpoints. All four bus-skew constraints are MET (19.081, 19.034, 19.339, 19.044 ns). Regenerated probe JSON exactly matches the original LTX. Five DRC Warning checks and four methodology Warning checks remain; none is claimed resolved. No synthesis/routing rerun or new board test was required for these unchanged files.

The archive audit checks eleven source identities, native ZIP integrity/XPR references, original BIT/LTX SHA-256, all 39 saved hardware rows and all 32 distinct combinations, and standard simulation CUT indices 10-89 with detections at 30/60/85. On Windows it first checks raw bytes, then permits only CRLF-to-LF normalization for Git text checkout; archive sources must still match the successful manifest exactly.

Final URL: [https://drive.google.com/file/d/1GVxgJAPUFZR8cL2akO7Jz29AENO5zwNO/view?usp=sharing](https://drive.google.com/file/d/1GVxgJAPUFZR8cL2akO7Jz29AENO5zwNO/view?usp=sharing). Exact text is validated in `Video_Link.txt`. Browser title: `2nd final.mp4`; preview was blank. Web retrieval failed. Video playback, narration, technical agreement and unauthenticated access are incomplete checks. Earlier raw-video observations are not proof of the final edit.

The original RTL, XDC, testbenches, five Vivado scripts, hardware files, checkpoint, reports, physical evidence and historical logs were preserved. Earlier PDF versions are retained in Documentation/Archive and Simulation/Archive. Figures and measurements in the revised report retain their original provenance. The historical FILE_MANIFEST.json and EVIDENCE_AUDIT.txt describe the earlier package; their references to a blank video link are historical, not current status.

Drive metadata lookup also identified `2nd final.mp4` as a 132,493,275-byte video/mp4 file. Sharing permissions/video metadata were not returned (`access_not_verified`); text/content retrieval failed. This does not establish playback or anonymous judge access.
