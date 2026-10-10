# Physical-board evidence

hardware_test_results.csv is the original original physical-board 7 October CSV, not a recreated reference or mocked run. hardware_validation.json independently compares all 45 true labels, predicted classes and scores against frozen Data/iris_cases.csv, checks test-set completeness/uniqueness, and audits cycle metadata. It does not claim a new FPGA execution.

Board/VIO screenshots are under Images/. The completed counts 46/47/48 followed the original 45-case test; a later synchronized reset was used for recording. Counts are session state, not accuracy.

The raw video is referenced in RAW_VIDEO.md; Video_Link.txt records the final Drive URL. Historical repair/review notes are retained under Historical/ and do not override the current report/checklist.
