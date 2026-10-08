"""Optional Icarus reproduction. Vivado launcher does not require this script."""
from pathlib import Path
import argparse,datetime,shutil,subprocess,os
root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--iverilog',default=shutil.which('iverilog'));p.add_argument('--vvp',default=shutil.which('vvp'));p.add_argument('--ivl-lib');a=p.parse_args()
if not a.iverilog or not a.vvp:raise SystemExit('Install Icarus Verilog, or specify --iverilog and --vvp.')
out=root/'Simulation'/('reproduction_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'));out.mkdir(parents=True)
rtl=[root/'RTL'/f for f in ['bnn_math_pkg.sv','bnn_parallel.sv','bnn_folded.sv','bnn_config.sv','bnn_safety.sv','bnn_system.sv']]
for top,marker,data in [('tb_cores','CORE',True),('tb_diagnostics','DIAGNOSTIC',False),('tb_config','CONFIG',False),('tb_safety','SAFETY',False),('tb_system','SYSTEM',True)]:
 passfile=out/f'{marker}_TEST_PASS.txt';exe=out/f'{top}.vvp'
 cmd=[a.iverilog]+(['-B',a.ivl_lib] if a.ivl_lib else [])+['-g2012','-s',top,f'-P{top}.PASS_FILE="{passfile.as_posix()}"']
 if data:cmd.append(f'-P{top}.DATA_DIR="{root.as_posix()}"')
 cmd+=['-o',str(exe)]+list(map(str,rtl))+[str(root/'Testbench'/f'{top}.sv')]
 c=subprocess.run(cmd,capture_output=True,text=True);(out/f'{top}_compile.log').write_text(c.stdout+c.stderr)
 if c.returncode:raise SystemExit(f'{top} compile failed; {out}')
 with (out/f'{top}_transcript.txt').open('w') as f:r=subprocess.run([a.vvp,str(exe)],stdout=f,stderr=subprocess.STDOUT,cwd=out)
 if r.returncode or not passfile.exists() or not passfile.read_text().startswith('PASS '):raise SystemExit(f'{top} failed; {out}')
 print(f'{top} PASS',flush=True)
print('All five suites passed:',out)
