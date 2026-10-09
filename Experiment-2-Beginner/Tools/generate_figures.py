"""Render exact diagrams and simulation figures. Requires matplotlib only."""
from pathlib import Path
import csv
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

ROOT = Path(__file__).resolve().parents[1]
IMAGES = ROOT / "Images"
IMAGES.mkdir(exist_ok=True)
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 10})

with (ROOT / "Simulation/core_standard_results.csv").open() as f:
    rows = list(csv.DictReader(f))
xs = [int(r["cut_index"]) for r in rows]
ths = [int(r["threshold_full"]) for r in rows]
ys = [100] * 100
ys[30], ys[60], ys[85] = 1000, 1200, 900
fig, ax = plt.subplots(figsize=(10.5, 4.8), layout="constrained")
ax.plot(range(100), ys, color="#1c506b", lw=1.7, label="Synthetic input magnitude")
ax.step(xs, ths, where="mid", color="#bd7326", lw=1.7, label="Full CFAR threshold (alpha 4)")
hits = [int(r["cut_index"]) for r in rows if int(r["detected"]) == 1]
ax.scatter(hits, [ys[i] for i in hits], color="#b63544", s=50, zorder=5, label="Simulated detections")
for i in hits:
    ax.annotate(f"Target {i}", (i, ys[i]), xytext=(0, 12), textcoords="offset points", ha="center", weight="bold")
ax.set(xlabel="Sample / CUT index (zero-based)", ylabel="Unsigned linear-domain value",
       title="CA-CFAR simulation: 3 targets, 80 complete windows", ylim=(0, 1400))
ax.grid(alpha=.15); ax.legend(loc="upper right", fontsize=9)
fig.savefig(IMAGES / "cfar_detection.png", dpi=160);plt.close(fig)

fig, ax = plt.subplots(figsize=(11.2, 5.8))
ax.set(xlim=(0, 11.2), ylim=(0, 5.8));ax.axis("off")
def box(x,y,w,h,text,color="#eaf2f4"):
    ax.add_patch(FancyBboxPatch((x,y),w,h,boxstyle="round,pad=0.05,rounding_size=.12",facecolor=color,edgecolor="#386073",lw=1.3))
    ax.text(x+w/2,y+h/2,text,ha="center",va="center",fontsize=10)
def arrow(a,b,text=None):
    ax.add_patch(FancyArrowPatch(a,b,arrowstyle="-|>",mutation_scale=14,color="#386073",lw=1.4))
    if text: ax.text((a[0]+b[0])/2,(a[1]+b[1])/2+.12,text,ha="center",fontsize=8)
ax.text(.2,5.45,"PYNQ-Z2 radar target detector",fontsize=17,weight="bold")
box(.3,3.5,2.3,1.0,"FPGA sample sequencer\n100 synthetic samples\ncontinuous / gapped")
box(3.15,3.4,4.2,1.25,"Streaming CA-CFAR\n21-cell window; 16 training cells\npartial sums → total → comparison")
box(8.0,3.5,2.8,1.0,"Result capture\n80 results; count / mask\nCUT indices / thresholds")
arrow((2.65,4.0),(3.1,4.0));arrow((7.4,4.0),(7.95,4.0))
box(3.3,1.2,4.0,1.0,"Vivado VIO / JTAG\nstart, reset, scenario, alpha, gaps\nstable result readout", "#f7eee2")
arrow((4.0,2.25),(1.45,3.45),"control")
arrow((6.05,2.25),(5.2,3.35),"alpha")
arrow((9.35,3.45),(7.35,1.7),"results")
box(.3,.3,2.25,.75,"125 MHz H16 reference\nMMCM → 50 MHz")
box(8.0,.3,2.8,.75,"LD0 heartbeat; LD1 busy\nLD2 done; LD3 target")
ax.text(3.3,.55,"All PL processing / VIO use the same 50 MHz clock.",fontsize=9)
fig.savefig(IMAGES / "block_diagram.png",dpi=160,bbox_inches="tight")
fig.savefig(IMAGES / "block_diagram.svg",bbox_inches="tight");plt.close(fig)

# Read the real Icarus VCD; select only top-level DUT interface traces.
vcd=ROOT/"Simulation/cfar_core.vcd"
if vcd.exists():
    names={}; traces={}; scope=[]; in_defs=True; time_ps=0
    wanted={"reset","data_valid","result_valid","target_detected","cut_index","threshold_full"}
    for line in vcd.open():
        line=line.strip()
        if in_defs:
            p=line.split()
            if line.startswith("$scope"):scope.append(p[2])
            elif line.startswith("$upscope"):scope.pop()
            elif line.startswith("$var") and scope==["tb_cfar_core"] and p[4] in wanted:
                names[p[3]]=p[4];traces[p[4]]=[]
            elif line.startswith("$enddefinitions"):in_defs=False
            continue
        if line.startswith("#"):
            time_ps=int(line[1:])
            if time_ps>2200000:break
        elif line and not line.startswith("$"):
            if line[0] in "bB":
                val,code=line[1:].split()
            else:val,code=line[0],line[1:]
            if code in names and not any(c in val.lower() for c in "xz"):
                traces[names[code]].append((time_ps/1000,int(val,2)))
    fig,axes=plt.subplots(6,1,figsize=(11,7),sharex=True,layout="constrained")
    for ax,name in zip(axes,["reset","data_valid","result_valid","target_detected","cut_index","threshold_full"]):
        data=traces[name]
        if data:
            x,y=zip(*data);ax.step([*x,2200],[*y,y[-1]],where="post",lw=1.3,color="#1c506b")
        ax.set_ylabel(name,fontsize=9);ax.grid(alpha=.15);ax.set_xlim(0,2200)
        if name in {"reset","data_valid","result_valid","target_detected"}:ax.set_yticks([0,1]);ax.set_ylim(-.15,1.15)
    axes[0].set_title("Actual simulation waveform — standard 100-sample frame (50 MHz testbench)",fontsize=12)
    axes[-1].set_xlabel("Time (ns)")
    fig.savefig(IMAGES/"simulation_waveform.png",dpi=160);plt.close(fig)
print("Rendered block diagram, CFAR detection plot and simulation waveform.")
