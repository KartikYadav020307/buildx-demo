#!/usr/bin/env python3
"""Run the unmodified generated FIR RTL using Icarus Verilog 12+.

Run from any directory: python Testbench/run_rtl_sim.py
Requires Python/NumPy, iverilog and vvp on PATH. IVERILOG_BASE may specify a
relocated Icarus backend directory; otherwise the normal installation is used.
"""
from pathlib import Path
import datetime, hashlib, json, os, shutil, subprocess, sys

root = Path(__file__).resolve().parents[1]
sim = root/'Simulation'
iverilog = os.environ.get('IVERILOG',shutil.which('iverilog') or '')
vvp = os.environ.get('VVP',shutil.which('vvp') or '')
if not iverilog or not vvp:
    raise SystemExit('Install Icarus Verilog, or set IVERILOG and VVP executable paths.')
subprocess.run([sys.executable,'Testbench/generate_vectors.py'],cwd=root,check=True)
rtl = sorted((root/'RTL/Generated_Verilog').glob('ecg_bandpass_filter*.v'))
args=[iverilog]
if os.environ.get('IVERILOG_BASE'):args+=['-B',os.environ['IVERILOG_BASE']]
args+=['-g2012','-I','RTL/Generated_Verilog','-s','tb_top','-o','Simulation/rtl_sim.vvp','Testbench/tb_top.v']
args += [p.relative_to(root).as_posix() for p in rtl]
compile_result=subprocess.run(args,cwd=root,text=True,capture_output=True)
run_result=None
if compile_result.returncode==0:
    run_result=subprocess.run([vvp,'Simulation/rtl_sim.vvp'],cwd=root,text=True,capture_output=True)
version=subprocess.run([iverilog,'-V'],text=True,capture_output=True).stdout.splitlines()[0]
sources=[root/'Testbench/tb_top.v']+rtl+[root/'RTL/Generated_Verilog/ecg_bandpass_filter_hls_deadlock_kernel_monitor_top.vh']
hashes={p.relative_to(root).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in sources}
passed=(compile_result.returncode==0 and run_result is not None and run_result.returncode==0 and 'RTL TEST PASS:' in run_result.stdout)
metadata={'utc_run_time':datetime.datetime.now(datetime.timezone.utc).isoformat(),'simulator':version,
          'compile_return_code':compile_result.returncode,'run_return_code':None if run_result is None else run_result.returncode,
          'passed':passed,'checked_samples':28672,'payload_samples':20480,'zero_flush_samples':8192,'batches':14,
          'clock_period_ns':10,'unit_scope':'HLS FIR core; not full Zynq PS or vendor DMA simulation','source_sha256':hashes}
(sim/'rtl_run_metadata.json').write_text(json.dumps(metadata,indent=2)+'\n')
transcript='Project 3 RTL simulation\n'+json.dumps({k:v for k,v in metadata.items() if k!='source_sha256'},indent=2)+'\n\n'
transcript+='Commands (normal installation):\npython Testbench/generate_vectors.py\n'
transcript+='iverilog -g2012 -I RTL/Generated_Verilog -s tb_top -o Simulation/rtl_sim.vvp Testbench/tb_top.v RTL/Generated_Verilog/ecg_bandpass_filter*.v\n'
transcript+='vvp Simulation/rtl_sim.vvp\n\nCompiler output:\n'+compile_result.stdout+compile_result.stderr
if run_result:transcript+='\nSimulator output:\n'+run_result.stdout+run_result.stderr
(sim/'transcript.txt').write_text(transcript)
if run_result:(sim/'rtl_run.log').write_text(run_result.stdout+run_result.stderr)
print(transcript)
if not passed:raise SystemExit(1)
