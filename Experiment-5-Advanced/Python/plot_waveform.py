from pathlib import Path
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
p=Path(__file__).resolve().parents[1]
codes={'!':'clk','#':'accept','(':'parallel valid',')':'folded valid','*':'parallel class','+':'folded class'}
events={c:[] for c in codes}; t=0
for line in (p/'Simulation/waveform.vcd').read_text().splitlines():
 if line.startswith('#'):t=int(line[1:])/1000
 elif line and line[0] in '01xz' and line[1:] in codes:events[line[1:]].append((t,line[0]))
 elif line.startswith('b'):
  v,c=line[1:].split()
  if c in codes:events[c].append((t,v))
fig,axs=plt.subplots(2,1,figsize=(12,7.2),layout='constrained')
for ax,start,title,cl in zip(axs,[1090,4150],['Normal model 1 | raw 0222 | encoded 0333 | CAUTION (1)','Cautious model 2 | same input | BRAKE (2)'],[1,2]):
 for idx,c in enumerate(codes):
  seq=events[c];last='0';xs=[-30];ys=[]
  for tm,v in seq:
   if tm<=start-30:last=v
  def val(v):
   try:return int(v,2)
   except ValueError:return 0
  ys=[idx+val(last)*(.18 if c in '*+' else .55)]
  for tm,v in seq:
   if start-30<tm<=start+460:xs.append(tm-start);ys.append(idx+val(v)*(.18 if c in '*+' else .55))
  xs.append(460);ys.append(ys[-1]);ax.step(xs,ys,where='post',lw=1.4)
 ax.set_yticks(range(6),codes.values());ax.set_xlim(-30,460);ax.set_ylim(-.3,6);ax.grid(axis='x',alpha=.25);ax.set_title(title,loc='left',fontsize=12);ax.set_xlabel('Time from accepted rising edge (ns)')
 for tm,label in [(0,'accept'),(100,'5 cycles'),(420,'21 cycles')]:ax.axvline(tm,color='#64748b',ls=':',alpha=.6);ax.text(tm,5.75,label,ha='center',fontsize=9)
fig.savefig(p/'Simulation/waveform.png',dpi=180);plt.close(fig)
