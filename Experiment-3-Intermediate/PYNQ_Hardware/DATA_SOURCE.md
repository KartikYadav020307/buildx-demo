# ECG source and transformations

MIT-BIH Arrhythmia Database v1.0.0, record 100, channel MLII.
Source: https://physionet.org/content/mitdb/1.0.0/
Data: https://physionet.org/files/mitdb/1.0.0/100.dat
Header: https://physionet.org/files/mitdb/1.0.0/100.hea
License: Open Data Commons Attribution License v1.0: https://opendatacommons.org/licenses/by/1-0/

The CSV contains samples 0 through 12287 at 360 samples/s (34.133 seconds).
WFDB format 212 is decoded using the official format specification:
https://physionet.org/physiotools/wag/signal-5.htm
The entire decoded MLII channel matches the original header checksum (-22131).
CSV physical units are mV: (digital sample - 1024) / 200.
These are actual recorded ECG samples, not a generated ECG waveform.
The notebook subtracts the excerpt median and adds a declared, reproducible
0.15 mV, 50 Hz sine interference for the filtering demonstration.

Original database citation:
Moody GB, Mark RG. The impact of the MIT-BIH Arrhythmia Database.
IEEE Engineering in Medicine and Biology 20(3):45-50, May-June 2001.

The peak detector is a simple Python height-threshold/refractory-period
demonstration tuned to this excerpt. It is not Pan-Tompkins, an arrhythmia
classifier, or a detector validated across the database.
