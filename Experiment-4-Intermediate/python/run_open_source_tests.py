"""Reproduce original regression plus supplementary VCD capture with Icarus."""
from pathlib import Path
import shutil, subprocess, tempfile
root=Path(__file__).resolve().parents[1]
iv=shutil.which('iverilog'); vvp=shutil.which('vvp')
if not iv or not vvp: raise SystemExit('Install Icarus Verilog (iverilog and vvp) first.')
rtl=['RTL/nn_parallel.sv','RTL/nn_serial.sv','RTL/nn_demo_controller.sv']
with tempfile.TemporaryDirectory(prefix='project4_sim_') as tmp:
    for top,bench,transcript in [('tb_nn','Testbench/tb_nn.sv','transcript.txt'),('tb_nn_waveform','Testbench/tb_nn_waveform.sv','waveform_transcript.txt')]:
        output=Path(tmp)/(top+'.vvp')
        cmd=[iv,'-g2012','-I','RTL','-I','Testbench','-s',top]
        if top=='tb_nn':
            cmd += ['-Ptb_nn.GOLDEN_FILE="Data/golden_vectors.mem"','-Ptb_nn.PASS_FILE="Simulation/nn_simulation_pass.flag"']
        subprocess.run(cmd+['-o',str(output),bench]+rtl,cwd=root,check=True)
        result=subprocess.run([vvp,str(output)],cwd=root,text=True,capture_output=True,check=True)
        (root/'Simulation'/transcript).write_text(result.stdout+result.stderr)
        marker='ALL TESTS PASSED' if top=='tb_nn' else 'WAVEFORM TEST PASS'
        if marker not in result.stdout: raise SystemExit('Missing pass marker: '+top)
        print(result.stdout,end='')
