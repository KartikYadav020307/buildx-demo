#!/usr/bin/env python3
"""Generate deterministic Q4.12 stimuli and an integer FIR reference."""
from pathlib import Path
import json
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'Testbench' / 'vectors'
OUT.mkdir(exist_ok=True)
coeff = np.asarray(json.loads((ROOT / 'PYNQ_Hardware/fir_reference.json').read_text())['coefficients_q412'], dtype=np.int64)

def encode(x):
    q = np.rint(np.asarray(x) * 4096)
    if q.min() < -32768 or q.max() > 32767:
        raise ValueError('Input exceeds Q4.12 range')
    return q.astype(np.int16)

def reference(q):
    q = np.asarray(q, dtype=np.int64)
    acc = np.zeros(len(q), dtype=np.int64)
    for j,c in enumerate(coeff):
        acc[j:] += (q[:len(q)-j] * c) >> 4
    acc = (acc + (1 << 23)) % (1 << 24) - (1 << 23)
    y = acc >> 8
    return ((y + 32768) % 65536 - 32768).astype(np.int16)

impulse = np.zeros(2048, dtype=np.int16)
impulse[0] = 4096
t = np.arange(2048) / 360.0
sine = encode(np.sin(2*np.pi*5*t) + 0.5*np.sin(2*np.pi*50*t))
rng = np.random.RandomState(20261009)
random = rng.randint(-32768,32768,size=4096).astype(np.int16)
random[:8] = [-32768,32767,0,1,-1,4096,-4096,16384]
ecg = np.loadtxt(ROOT / 'PYNQ_Hardware/ecg_record100_360hz.csv',skiprows=1)
te = np.arange(len(ecg))/360.0
ecg_q = encode(ecg-np.median(ecg)+0.15*np.sin(2*np.pi*50*te))

cases = [impulse,sine,random,ecg_q]
history = np.zeros(0,dtype=np.int16)
for label,payload in zip(['impulse','sine','random','ecg'],cases):
    # Match the hardware notebook: a full zero DMA batch clears FIR history.
    # The generated core initializes delay registers at configuration; its
    # control reset alone does not clear all static FIR data registers.
    q = np.concatenate([np.zeros(2048,dtype=np.int16),payload])
    history = np.concatenate([history,q])
    y = reference(history)[-len(q):]
    for kind,a in [('input',q),('expected',y)]:
        (OUT/f'{label}_{kind}.hex').write_text(''.join(f'{int(v)&65535:04x}\n' for v in a))

# Verify the model against the independently preserved physical-board CSV.
saved = np.genfromtxt(ROOT / 'PYNQ_Hardware/Supporting_Data_and_Results/hardware_ecg_results.csv',delimiter=',',names=True)
saved_q = np.rint(saved['fpga_output_mV']*4096).astype(np.int16)
if not np.array_equal(reference(ecg_q),saved_q):
    raise AssertionError('Reference does not match saved physical-board ECG output')
print('Generated 28672 checked samples: 20480 payload + 8192 zero-flush samples; ECG reference agrees with saved board output.')
