"""Build the evidence-based Project 4 PDFs and render the genuine VCD trace.
Run from any directory: python Documentation/build_report.py
Dependencies: reportlab, matplotlib, Pillow. No FPGA build is performed.
"""
from pathlib import Path
import csv, json, re, sys
from collections import defaultdict
from xml.sax.saxutils import escape
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
except ImportError:
    plt = None
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image, PageBreak, Preformatted
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
import reportlab
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from PIL import Image as PILImage

ROOT=Path(__file__).resolve().parents[1]
# Embed the portable fonts bundled with ReportLab, avoiding viewer-dependent
# substitution of the PDF base fonts and their character widths.
font_dir=Path(reportlab.__file__).parent/'fonts'
pdfmetrics.registerFont(TTFont('Vera',str(font_dir/'Vera.ttf')))
pdfmetrics.registerFont(TTFont('VeraBold',str(font_dir/'VeraBd.ttf')))
pdfmetrics.registerFont(TTFont('VeraItalic',str(font_dir/'VeraIt.ttf')))
pdfmetrics.registerFont(TTFont('VeraBoldItalic',str(font_dir/'VeraBI.ttf')))
pdfmetrics.registerFontFamily('Vera',normal='Vera',bold='VeraBold',italic='VeraItalic',boldItalic='VeraBoldItalic')
styles=getSampleStyleSheet()
styles.add(ParagraphStyle(name='Body',fontName='Vera',fontSize=10,leading=14,spaceAfter=8))
styles.add(ParagraphStyle(name='SmallBody',fontName='Vera',fontSize=8.2,leading=11,spaceAfter=6))
styles.add(ParagraphStyle(name='TableBody',fontName='Vera',fontSize=9,leading=12))
styles.add(ParagraphStyle(name='Title4',fontName='VeraBold',fontSize=21,leading=26,spaceAfter=15))
styles.add(ParagraphStyle(name='Mono4',fontName='Courier',fontSize=7.1,leading=10))
styles['Heading1'].fontSize=15
styles['Heading1'].fontName='VeraBold'
styles['Heading1'].leading=19
styles['Heading1'].spaceAfter=10
styles['Heading2'].fontSize=11
styles['Heading2'].fontName='VeraBold'
styles['Heading2'].leading=15
W=A4[0]-84
def p(t,style='Body'): return Paragraph(t,styles[style])
def h(t): return p(t,'Heading1')
def sub(t): return p(t,'Heading2')
def img(path,width=W,max_height=350):
    im=PILImage.open(ROOT/path); w,hh=im.size
    ratio=min(width/w,max_height/hh)
    return Image(str(ROOT/path),width=w*ratio,height=hh*ratio)
def table(rows,widths=None):
    body=[[p(escape(str(c)),'TableBody') for c in row] for row in rows]
    t=Table(body,colWidths=widths or [W/len(rows[0])]*len(rows[0]),repeatRows=1,hAlign='LEFT')
    t.setStyle(TableStyle([
        ('BACKGROUND',(0,0),(-1,0),colors.HexColor('#e9eef5')),
        ('VALIGN',(0,0),(-1,-1),'TOP'),('BOX',(0,0),(-1,-1),.4,colors.HexColor('#bbc5d1')),
        ('INNERGRID',(0,0),(-1,-1),.3,colors.HexColor('#d7dfe8')),
        ('LEFTPADDING',(0,0),(-1,-1),7),('RIGHTPADDING',(0,0),(-1,-1),7),
        ('TOPPADDING',(0,0),(-1,-1),6),('BOTTOMPADDING',(0,0),(-1,-1),6)]))
    return t
def footer(c,doc):
    c.setFont('Vera',8); c.setFillColor(colors.HexColor('#526073'))
    c.drawString(42,27,'V-SPACE Build Challenge 2026 | Experiment 4 | PYNQ-Z2')
    c.drawRightString(A4[0]-42,27,str(doc.page))
def pdf(path,story):
    SimpleDocTemplate(str(ROOT/path),pagesize=A4,rightMargin=42,leftMargin=42,topMargin=38,bottomMargin=42,
                      title='Project 4 - FPGA Neural Network Accelerator',author='Beyond Boolean').build(story,onFirstPage=footer,onLaterPages=footer)

def audit_hardware():
    actual=list(csv.DictReader((ROOT/'Evidence/hardware_test_results.csv').open()))
    refs={r['index']:r for r in csv.DictReader((ROOT/'Data/iris_cases.csv').open())}
    # The original frozen CSV column names are read explicitly, not inferred from scores.
    header=list(next(iter(refs.values())).keys())
    problems=[]
    for r in actual:
        ref=refs[r['index']]
        values=list(ref.values())
        expected=[values[7],values[13],values[14],values[15]]
        got=[r['predicted_class'],r['score0'],r['score1'],r['score2']]
        if got!=expected: problems.append(r['index'])
        if r['true_class']!=values[6]: problems.append('label:'+r['index'])
    assert len(actual)==45 and len({r['index'] for r in actual})==45
    assert not problems,problems
    assert all(r['reference_match']=='1' and (r['parallel_cycles'],r['serial_cycles'])==('4','36') for r in actual)
    expected_indices={r['index'] for r in refs.values() if r['split']=='test'}
    assert {r['index'] for r in actual}==expected_indices
    correct=sum(r['predicted_class']==r['true_class'] for r in actual)
    assert correct==43
    summary={'source':'recorded physical-board hardware_test_results.csv, 7 October 2026',
             'rows':45,'unique_indices':45,'independent_frozen_reference_matches':45,
             'correct_classifications':correct,'accuracy_percent':100*correct/45,
             'cycle_pairs':[[4,36]],'misclassified_indices':[int(r['index']) for r in actual if r['true_class']!=r['predicted_class']],
             'scope':'Offline audit of saved physical-board results; no new FPGA execution.'}
    (ROOT/'Evidence/hardware_validation.json').write_text(json.dumps(summary,indent=2)+'\n')
    return summary

def waveform():
    widths={}; names={}; events=defaultdict(list); t=0
    for line in (ROOT/'Simulation/waveform.vcd').read_text().splitlines():
        if line.startswith('$var '):
            a=line.split(); widths[a[3]]=int(a[2]); names[a[4]]=a[3]
        elif line.startswith('#'): t=int(line[1:])/1000
        elif line.startswith('b'):
            value,key=line[1:].split(); events[key].append((t,value))
        elif line and line[0] in '01xz' and not line.startswith('$'):
            events[line[1:]].append((t,line[0]))
    signals=['clk','rst','launch','pv','sv','busy','done','mismatch','parallel_cycles','serial_cycles','completed_count']
    fig,axes=plt.subplots(len(signals),1,figsize=(12,6.3),sharex=True,gridspec_kw={'hspace':.07})
    for ax,name in zip(axes,signals):
        key=names[name]; ev=events[key]; ev=[(a,b) for a,b in ev if a<=900]
        ax.set_ylabel(name,rotation=0,ha='right',va='center',fontsize=10,labelpad=15)
        if widths[key]==1:
            xx=[a for a,b in ev]+[900]; yy=[int(b) if b in '01' else .5 for a,b in ev]
            ax.step(xx,yy+[yy[-1]],where='post',color='#244b76',linewidth=1.5)
            ax.set_ylim(-.15,1.15); ax.set_yticks([])
        else:
            ax.set_ylim(0,1); ax.set_yticks([])
            for i,(a,b) in enumerate(ev):
                end=ev[i+1][0] if i+1<len(ev) else 900
                if end-a<15: continue
                ax.hlines([.23,.77],a,end,color='#244b76',linewidth=1)
                ax.vlines([a,end],.23,.77,color='#244b76',linewidth=.7)
                txt='X' if any(c in b for c in 'xz') else str(int(b,2))
                ax.text((a+end)/2,.5,txt,ha='center',va='center',fontsize=9)
        ax.grid(axis='x',color='#e5e9ef'); ax.spines[['top','right','left']].set_visible(False)
        for edge,col in [(110,'#555'),(190,'#27835c'),(830,'#bb672c')]: ax.axvline(edge,color=col,linestyle='--',linewidth=.8)
    axes[-1].set_xlim(0,900); axes[-1].set_xlabel('Simulation time (ns); 50 MHz clock, 20 ns period',fontsize=10)
    fig.suptitle('Actual Icarus VCD trace: first demo transaction (Setosa)',fontsize=15,y=.99)
    axes[0].set_title('Acceptance: 110 ns    Parallel valid: 190 ns (80 ns)    Sequential valid: 830 ns (720 ns)',fontsize=10,pad=9)
    fig.subplots_adjust(left=.21,right=.98,top=.89,bottom=.10)
    fig.savefig(ROOT/'Simulation/waveform.png',dpi=180); plt.close(fig)
    # Get actual accepted rising clock after launch assertion and valid event timestamps.
    clk_rise=[a for a,b in events[names['clk']] if b=='1']
    launches=[a for a,b in events[names['launch']] if b=='1']
    pv=[a for a,b in events[names['pv']] if b=='1']; sv=[a for a,b in events[names['sv']] if b=='1']
    rows=[]
    for n,(launch,parallel,serial) in enumerate(zip(launches,pv,sv)):
        acceptance=next(a for a in clk_rise if a>=launch)
        assert parallel-acceptance==80 and serial-acceptance==720
        rows.append([n,acceptance,parallel,serial,parallel-acceptance,serial-acceptance])
    assert len(rows)==3
    with (ROOT/'Simulation/waveform_measurements.csv').open('w') as f:
        wr=csv.writer(f); wr.writerow(['class','acceptance_ns','parallel_valid_ns','serial_valid_ns','parallel_latency_ns','serial_latency_ns']); wr.writerows(rows)

def reports():
    scope='Vivado 2025.1.1 | xc7z020clg400-1 | 50 MHz | audit: 9 October 2026 (IST)'
    story=[p('Design of an FPGA-Based Hardware Accelerator for Low-Latency Neural Network Inference','Title4'),
           p('Experiment 4 - Intermediate','Heading2'),p(scope,'SmallBody'),
           p('Team: Beyond Boolean. Members: Shanshank Pulipati (25BEC0573) and Kartik Yadav (25BEC0087).'),
           h('1. Objective'),p('Implement a trained 4-input, 4-hidden-neuron, 3-output Iris classifier on the PYNQ-Z2. Compare a pipelined parallel accelerator with a sequential shared-MAC core using identical frozen weights, arithmetic, inputs and clock frequency.'),
           p('The engineering question is whether parallel hardware reduces inference latency, and what DSP/resource cost that reduction requires. Software performs training and input preparation; neural inference itself executes in FPGA logic.'),
           table([['Verified metric','Result'],['Physical numeric correctness','45/45 held-out inputs match every frozen integer score'],['Classification accuracy','43/45 (95.56%); two model errors'],['Core latency at 50 MHz','Parallel: 4 cycles / 80 ns; sequential: 36 cycles / 720 ns'],['Architecture comparison','9x lower core latency; host/JTAG transfer time excluded'],['Routed timing','Setup +5.813 ns; hold +0.048 ns; no failing endpoints']], [W*.34,W*.66]),
           Spacer(1,12),sub('Demonstration scope'),p('This is a small classification benchmark demonstrating fixed-point inference and an FPGA architecture tradeoff. It does not validate an application-specific sensor system or claim an end-to-end CPU speedup. The VIO transaction wrapper runs one comparison at a time; the parallel core alone accepts a new input each clock.'),
           PageBreak(),h('2. Block Diagram'),img('Images/block_diagram.png',max_height=355),
           p('Source-derived architecture diagram from the original implementation pack. Clocking Wizard generates 50 MHz from the board 125 MHz PL clock; lock release is synchronized. Vivado VIO drives reset, a command toggle and the packed input word. The controller launches both cores and holds their results for JTAG inspection.','SmallBody'),
           sub('Model and numeric representation'),table([['Item','Frozen implementation'],['Dataset split','90 training / 15 validation / 45 held-out; 150 Iris records'],['Features and classes','Sepal length/width and petal length/width; 0 Setosa, 1 Versicolor, 2 Virginica'],['Input and weight formats','Signed 8-bit inputs at scale 32; signed 8-bit weights at scale 64'],['Internal arithmetic','16-bit hidden activations; 32-bit sums/scores; input byte i is features[8*i +: 8]'],['Activation and prediction','Arithmetic shift by 6 then ReLU saturation to 0..32767; signed argmax with lower-index tie priority']], [W*.30,W*.70]),
           PageBreak(),h('3. RTL Design'),table([['File / instance','Function'],['nn_board_top.sv','Board clock/reset, clock/VIO IP, heartbeat and class/status LEDs'],['nn_demo_controller.sv / u_demo','Toggle launch, busy rejection, sticky scores/classes, counters and mismatch comparison'],['nn_parallel.sv / u_parallel','16 first-layer products, ReLU, 12 second-layer products, scores and argmax'],['nn_serial.sv / u_serial','One shared multiplication/MAC datapath controlled by a sequencer'],['nn_weights.vh; nn_math.vh','Frozen weights/biases; signed extension, saturation and argmax helpers'],['pynq_z2.xdc','Board sysclk/LED pins and exceptions; primary clock supplied by Clocking Wizard']], [W*.42,W*.58]),
           Spacer(1,10),sub('Parallel pipeline: elapsed periods from acceptance'),
           p('<b>E0:</b> input/products captured. <b>E1:</b> first-layer sums, bias, rescale and ReLU. <b>E2:</b> second-layer products. <b>E3:</b> three scores. <b>E4:</b> valid scores and class. Five registered stages span four elapsed clock periods.'),
           img('Images/rtl_schematic.png',max_height=210),
           p('Actual source-elaborated schematic generated with Yosys 0.33 and Graphviz. Clocking Wizard and VIO are port-accurate black boxes for this view; their vendor internals are not simulated by these declarations. This is not a Vivado GUI capture. Full-resolution PNG/SVG, netlist, tool transcript and reproduction recipe are included.','SmallBody'),
           PageBreak(),h('4. Simulation Results'),
           p('Original local XSim evidence is preserved in Results/vivado_batch.log and simulation_pass.flag. Icarus Verilog 12.0 regression and VCD capture provide additional simulation evidence. On 9 October 2026 (IST), the unchanged source passed the full suite and three-case waveform bench again in local Vivado XSim 2025.1.1. The new outputs are current_xsim_regression.txt and current_xsim_waveform.txt; the original Icarus waveform is retained.'),
           img('Simulation/waveform.png',max_height=285),
           p('Measured from actual VCD transitions: first input accepted at 110 ns; parallel output valid at 190 ns; sequential output valid at 830 ns. Sticky controller outputs are captured later, so the picture distinguishes core valid timing from the host-visible comparison result.','SmallBody'),
           Preformatted((ROOT/'Simulation/transcript.txt').read_text().strip(),styles['Mono4']),
           p('The full regression verifies exact scores and classes for 4,502 vectors per core, full-rate parallel bursts and bubbles, sequential input latching, 150 controller cases, held-toggle non-retriggering, busy rejection, reset cancellation/recovery, argmax ties and ReLU saturation. The supplementary waveform bench independently checks the three recorded demo inputs and 4/36-cycle valid timing.','SmallBody'),
           PageBreak(),h('5. Hardware Implementation'),
           p('The team programmed the physical PYNQ-Z2 over USB/JTAG and ran hardware_test.tcl on 7 October. The script checked 45 held-out records against frozen reference scores. Board photo, hardware PASS screenshot, three-case console output and final VIO screenshot are preserved in Images/.'),
           table([['Scope','LUTs','FFs','DSPs'],['Parallel core',247,263,28],['Sequential core',208,330,1],['Whole board design',1515,2648,29]], [W*.46,W*.18,W*.18,W*.18]),
           Spacer(1,8),p('Raw routed reports: setup +5.813 ns; hold +0.048 ns; pulse width +2.000 ns; all four bus-skew checks pass, minimum slack +19.066 ns. The original matching 6 October bitstream and LTX pair are included; the reports describe the recorded build.','SmallBody'),
           img('Images/hardware_output.jpg',max_height=275),
           p('Final VIO output for 37281210: both classes 2, scores -13784 / -6177 / 16696, mismatch 0, cycles 4/36, completed count 48. The visible values were read from actual FPGA probes.','SmallBody'),
           p('Numeric correctness is 45/45, while species accuracy is 43/45. Records 68 and 138 are misclassified by the model but their FPGA scores match the software model exactly. The saved CSV was independently cross-checked against all frozen test records.','SmallBody'),
           PageBreak(),h('5. Hardware Implementation (continued)'),
           img('Images/board_setup.jpg',width=200,max_height=195),
           p('PYNQ-Z2 setup photograph: PYNQ-Z2 with USB/JTAG and Ethernet attached. Ethernet/Jupyter is not used for this RTL/VIO inference workflow. VIO availability and the heartbeat were observed after programming.','SmallBody'),
           sub('Warnings and script maintenance'),p('DRC reports 44 warnings and no errors; methodology reports four LUTAR-1 reset warnings inside AMD debug-hub IP. DSP pipeline warnings are performance recommendations; timing meets the chosen 50 MHz target. ZPS7-1 remains recorded in the PL-only design. Raw reports are retained, and successful physical VIO testing supplies board/clock evidence for this setup.','SmallBody'),
           p('The VIO script originally parsed all readbacks as hexadecimal. Decimal display caused a false timeout although hardware finished correctly. nn_hw_read now uses INPUT_VALUE_RADIX and restores signed scores as 32-bit two\'s-complement values. The corrected reader was tested in the live session; the persistent repository script includes it. HDL/model and bitstream are unchanged.','SmallBody'),
           h('6. Applications'),p('The architecture illustrates low-latency embedded classification, FPGA ML teaching and controlled resource/latency comparisons. Applying it to industrial inspection or sensor processing requires suitable training data, preprocessing and domain validation. More parallel arithmetic trades DSP use for latency; the small Iris model makes that tradeoff easy to reproduce.'),
           h('7. Conclusion'),p('A trained quantized network executes correctly in two FPGA architectures. Both match the integer reference; the parallel implementation reduces core latency from 36 to 4 cycles at the same 50 MHz clock. The experiment demonstrates fixed-point arithmetic, pipelining, resource sharing, verification and hardware debugging.'),
           p('Future scope: larger datasets/networks, configurable weights, measured power and an AXI-stream/DMA interface. Team identity and final demo URL are recorded. Evidence/RAW_VIDEO.md preserves the raw recording; Video_Link.txt points to the final edit. Content and public reviewer access need review (Documentation/VIDEO_REVIEW.md). The final video must include introduction, problem, architecture/RTL presentation, working hardware and conclusion.'),
           p('The original native Vivado project descriptor and clock/VIO IP configuration files were recovered from the laptop and archived in FPGA_Project/Project4_NN_Vivado_Source_Project.zip with the source tree. Original descriptor/IP bytes are preserved, including machine-specific paths and historical run settings. Generated caches/runs are excluded. Use the supplied project-generation Tcl for a clean relocated rebuild.','SmallBody'),
           p('Evidence sources: Data/model.json and iris_cases.csv; Results/*.rpt and vivado_batch.log; Evidence/hardware_test_results.csv and hardware_validation.json; Simulation/transcript.txt and waveform.vcd. Dataset attribution and original guide are included in Data/ATTRIBUTION.md and START_HERE.md.','SmallBody')]
    pdf('Documentation/Project4_NN_Report.pdf',story)
    simulation=[p('Project 4 - Simulation Report','Title4'),p(scope,'SmallBody'),
                h('Test setup and coverage'),p('Recovered unchanged inference RTL, frozen model headers and 4,502 precomputed Python golden vectors. Simulator: Icarus Verilog 12.0. DUTs: nn_parallel, nn_serial and nn_demo_controller. Simulation clock period is 20 ns. No vendor VIO/clock IP or physical board is simulated by these benches.'),
                table([['Check','Observed result'],['Parallel reference suite','4,502 exact score/class matches; 4 elapsed periods'],['Sequential reference suite','4,502 exact score/class matches; 36 elapsed periods'],['Streaming / input latching','Consecutive parallel inputs and bubbles pass; serial captures input'],['Controller suite','150 Iris cases, hold/busy/reset handling, counters and mismatch pass'],['Arithmetic/reset boundaries','Reset abort/recovery, argmax ties and ReLU saturation pass'],['Three-case trace bench','All three exact reference scores; 80/720 ns valid timing']], [W*.39,W*.61]),
                Spacer(1,10),sub('Actual regression output'),Preformatted((ROOT/'Simulation/transcript.txt').read_text().strip(),styles['Mono4']),
                p('The original Vivado/XSim log also contains ALL TESTS PASSED and is preserved in Results/vivado_batch.log. The full regression and waveform bench passed again in local Vivado XSim 2025.1.1 on 9 October 2026 (IST); the current_xsim files preserve these new outputs. Icarus outputs are separately named. Compiler executable files and temporary simulator files are excluded from the repository.','SmallBody'),
                PageBreak(),h('Measured waveform'),img('Simulation/waveform.png',max_height=325),
                p('Plot rendered from the genuine included VCD, not from expected values. Acceptance / parallel valid / sequential valid occur at 110 / 190 / 830 ns for class 0, then 1050 / 1130 / 1770 ns for class 1, and 1990 / 2070 / 2710 ns for class 2. Latencies are 80/720 ns in each case.','SmallBody'),
                sub('Supplementary capture output'),Preformatted((ROOT/'Simulation/waveform_transcript.txt').read_text().strip(),styles['Mono4']),
                p('Reproduction: from the experiment folder run python python/run_open_source_tests.py with Icarus installed, then python Documentation/build_report.py. The script creates fresh transcripts, pass marker and VCD. Vivado builds use RUN_PROJECT4.cmd and the original tb_nn.sv.','SmallBody')]
    pdf('Simulation/simulation_report.pdf',simulation)

if __name__=='__main__':
    audit_hardware()
    if '--reuse-waveform' not in sys.argv:
        if plt is None:
            raise RuntimeError('Install matplotlib to regenerate the waveform, or use --reuse-waveform to retain the verified existing plot.')
        waveform()
    reports()
    print('Hardware audit: 45/45 exact reference matches; 43/45 classifications')
    print('Created Project4_NN_Report.pdf and simulation_report.pdf; existing verified waveform retained' if '--reuse-waveform' in sys.argv else 'Created Project4_NN_Report.pdf and simulation_report.pdf; VCD measurements: PASS')
