"""Plot the actual XSim regression VCD; retain the source trace unchanged."""
from pathlib import Path
import re
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
ROOT=Path(__file__).resolve().parents[1]
text=(ROOT/'Validation/regression.vcd').read_text()
names={m.group(2):m.group(1) for m in re.finditer(r'\$var\s+\S+\s+\d+\s+(\S+)\s+(\w+)(?:\s+\[.*?\])?\s+\$end',text)}
assert re.search(r'\$timescale\s+1ps\s+\$end',text), 'Expected the archived XSim 1 ps trace'
events={n:[] for n in ('clk','reset','start','done','original_done','ciphertext','original_ciphertext')}
reverse={names[n]:n for n in events};time=0
for line in text.split('$enddefinitions $end',1)[1].splitlines():
    line=line.strip()
    if line.startswith('#'):time=int(line[1:])/1000
    elif line.startswith('b'):
        value,code=line[1:].split()
        if code in reverse:events[reverse[code]].append((time,value))
    elif line and line[0] in '01xz' and line[1:] in reverse:
        events[reverse[line[1:]]].append((time,line[0]))
done_time=next(t for t,v in events['done'] if v=='1')
end=done_time+12
result=next(v for t,v in events['ciphertext'] if t==done_time)
assert int(result,2)==int('3ad77bb40d7a3660a89ecaf32466ef97',16)
assert events['done']==events['original_done']
assert events['ciphertext']==events['original_ciphertext']
fig,axes=plt.subplots(5,1,figsize=(11,5.4),sharex=True,layout='constrained')
for ax,name in zip(axes,('clk','reset','start','done','original_done')):
    data=[(t,int(v)) for t,v in events[name] if t<=end and v in ('0','1')]
    data.append((end,data[-1][1]))
    ax.step([x[0] for x in data],[x[1] for x in data],where='post',color='#16485b')
    ax.set_ylim(-.2,1.2);ax.set_yticks([0,1]);ax.set_ylabel(name,rotation=0,labelpad=45,ha='right')
    ax.grid(axis='x',alpha=.2);ax.axvline(done_time,color='#a25a19',linestyle=':')
axes[-1].set_xlim(0,end);axes[-1].set_xlabel('Time (ns), actual 1 ps XSim trace')
fig.suptitle('AES repair regression: first known-answer transaction at 125 MHz\n'
             f'Ciphertext at done ({done_time:g} ns): {int(result,2):032X}; original and repaired outputs agree',fontsize=11)
fig.savefig(ROOT/'Validation/waveform.png',dpi=180)
print('Actual VCD waveform plotted; first completion:',done_time,'ns')
