"""Rebuild Project 1 PDFs from preserved diagrams, images, traces and report values."""
from pathlib import Path
from xml.sax.saxutils import escape
import re
from PIL import Image as PILImage
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet,ParagraphStyle
from reportlab.platypus import SimpleDocTemplate,Paragraph,Spacer,Image,Table,TableStyle,PageBreak,Preformatted
ROOT=Path(__file__).resolve().parents[1];WIDTH=A4[0]-92
styles=getSampleStyleSheet()
styles.add(ParagraphStyle('Body2',fontName='Helvetica',fontSize=10,leading=14,spaceAfter=10))
styles.add(ParagraphStyle('Caption2',fontName='Helvetica',fontSize=8,leading=11,textColor=colors.HexColor('#455866'),spaceAfter=10))
styles.add(ParagraphStyle('Cell2',fontName='Helvetica',fontSize=8.6,leading=11))
def p(s,style='Body2'):return Paragraph(s,styles[style])
def pic(name,height=290):
    path=ROOT/name
    with PILImage.open(path) as im:w,h=im.size
    scale=min(WIDTH/w,height/h)
    return Image(str(path),width=w*scale,height=h*scale,hAlign='CENTER')
def table(rows,widths=None):
    t=Table([[p(escape(str(c)),'Cell2') for c in row] for row in rows],colWidths=widths or [WIDTH/len(rows[0])]*len(rows[0]),repeatRows=1)
    t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#ddeaf0')),('VALIGN',(0,0),(-1,-1),'TOP'),('TOPPADDING',(0,0),(-1,-1),7),('BOTTOMPADDING',(0,0),(-1,-1),7),('LINEBELOW',(0,0),(-1,-1),.3,colors.HexColor('#b5c4cb'))]))
    return t
def footer(canvas,doc):
    canvas.setFont('Helvetica',8);canvas.setFillColor(colors.HexColor('#455866'))
    canvas.drawString(46,28,'Beyond Boolean | Project 1 AES-128 | Review: 10 October 2026')
    canvas.drawRightString(A4[0]-46,28,str(doc.page))
def build(path,story,title):
    SimpleDocTemplate(str(ROOT/path),pagesize=A4,leftMargin=46,rightMargin=46,topMargin=42,bottomMargin=45,title=title,author='Shanshank Pulipati; Kartik Yadav',subject='Original evidence and independently reviewed AES timing repair').build(story,onFirstPage=footer,onLaterPages=footer)
def page(story,title,*items):
    if story:story.append(PageBreak())
    story.extend([p(title,'Heading1'),*items])
def timing(path):
    t=path.read_text();m=re.search(r'WNS\(ns\).*?\n.*?\n(.*?)\n',t,re.S)
    fields=m.group(1).split();return fields[0],fields[4],fields[8]
report=[]
page(report,'AES-128 hardware encryption accelerator',
    p('Experiment 1 - Beginner | V-SPACE FPGA Build Challenge 2026'),
    table([['Team','Beyond Boolean'],['Members','Shanshank Pulipati - 25BEC0573; Kartik Yadav - 25BEC0087'],['Board / device','PYNQ-Z2 / xc7z020clg400-1'],['Tool / clock constraint','Vivado 2025.1.1 / 125 MHz (8 ns)']],[WIDTH*.30,WIDTH*.70]),
    p('1. Objective','Heading2'),
    p('Implement iterative AES-128 encryption in programmable logic and observe a retained 128-bit ciphertext through VIO/JTAG. A key-expansion register change addresses the archived setup-timing failure while preserving the interface and cycle behavior. The original board demonstration and repaired candidate have distinct evidence.'),
    p('2. Block Diagram','Heading2'),pic('Images/block_diagram.png',280),
    p('Conceptual drawing grounded in the original RTL, not a native Vivado block-design capture. The repaired core keeps this top-level architecture and adds a previous-key register internally. No AXI DMA or PS block is instantiated.','Caption2'))
page(report,'3. RTL Design',
    table([['Source / instance','Role'],['aes_top.v','Common board clock, virtual_interface (vio_0), encryption_hardware (aes_core)'],['aes_core.v','Key expansion; SubBytes, ShiftRows, MixColumns and AddRoundKey; four-state control'],['vio_0','Four control/data outputs and two monitored inputs'],['pynq.xdc','H16, LVCMOS33, unchanged 8 ns constraint']],[WIDTH*.32,WIDTH*.68]),
    pic('Images/rtl_schematic.png',275),
    p('Source-derived top connectivity drawing. It represents actual port directions and widths, not a Vivado netlist GUI capture. The same top wiring applies to both revisions.','Caption2'),
    p('S_IDLE captures key/plaintext and performs the initial XOR. S_KEY_EXP stores ten expanded round keys. S_ROUNDS reuses the round datapath; round ten omits MixColumns. S_FINISHED registers ciphertext and asserts done, returning to IDLE. Completion is 21 clock intervals after an accepted start; done lasts one clock. Held start retriggers in IDLE.'),
    p('The repair reads a dedicated 128-bit previous_key register, loaded on start and updated for each expansion, instead of selecting round_keys[k_idx-1]. It still writes the original round-key bank. Original RTL remains in RTL/; candidate RTL and a source diff are in Timing_Repair/.'))
page(report,'4. Simulation Results',
    p('Original: the preserved 100 MHz testbench/transcript passes one known-answer vector. Its historical waveform photo and native WDB remain in Simulation/. Repair: Vivado XSim 2025.1.1 independently reran the supplied 125 MHz equivalence regression on 10 October 2026 and reached all final PASS markers.'),
    table([['Signal','First known-answer vector'],['Key','2B7E151628AED2A6ABF7158809CF4F3C'],['Plaintext','6BC1BEE22E409F96E93D7E117393172A'],['Ciphertext','3AD77BB40D7A3660A89ECAF32466EF97']],[WIDTH*.25,WIDTH*.75]),
    pic('Timing_Repair/Validation/waveform.png',255),
    p('Scientific plot of the actual new XSim VCD, not a fabricated simulator screenshot. Full trace: Timing_Repair/Validation/regression.vcd. Original/repaired done and ciphertext events agree throughout the regression.','Caption2'),
    p('104 key/plaintext/reference triples were independently recomputed with AES-ECB on individual 16-byte blocks. The paired testbench checks exact ciphertexts, cycle-by-cycle output equivalence, 21-cycle completion, one-cycle done, retention, input changes while busy, asynchronous mid-encryption reset, restart and repeated encryption with held start. Behavioral simulation does not measure routed propagation delay.'))
page(report,'5. Hardware Implementation - original physical evidence',
    pic('Images/recorded_board.png',195),
    p('Unchanged powered PYNQ-Z2 frame supplied in AESRepair.zip. The original board_setup.jpg is also retained. The normal PYNQ power/boot setup and USB/JTAG are required; standalone PL evidence does not establish independent PS initialization.','Caption2'),
    pic('Images/recorded_hardware_output.png',280),
    p('Unchanged original recording frame: programmed target and full key/plaintext/ciphertext visible. done=0 is consistent with a one-clock done pulse and retained ciphertext. This frame documents the original demonstration, not a board test of repaired programming files.','Caption2'),
    p('The older low-resolution hardware_output.jpg preview and programmed-VIO screenshot remain untouched. The repaired BIT/LTX pairs are separately supplied; no physical execution of either repaired pair is claimed.'))
rows=[['Metric','Original archived build','Supplied repair / checkpoint recheck'],['Clock constraint','125 MHz / 8 ns','125 MHz / 8 ns'],['Setup WNS / TNS','-0.104 / -0.276 ns','1.490 / 0.000 ns'],['Setup failing endpoints','4','0'],['Hold slack / failing endpoints','0.028 ns / 0','0.033 ns / 0'],['Pulse-width slack','See original report','2.750 ns'],['Integrated LUTs / FF','3222 / 3912','2860 / 4043'],['BRAM / DSP','0 / 0','0 / 0'],['Bus skew','Original report retained','Four MET; minimum 6.642 ns'],['Unconstrained internal endpoints','Original report retained','0']]
fresh=ROOT/'Timing_Repair/Reproduced_Outputs/timing_summary_routed.rpt'
fresh_message='Fresh source-build status and its independent measurements are recorded in Documentation/FINAL_VALIDATION.md; this table applies only to the supplied repaired checkpoint.'
if fresh.exists() and (fresh.parent/'BUILD_STATUS.txt').exists():
    a,b,d=timing(fresh)
    fresh_message=f'A separate complete source reproduction passed XSim, synthesis, routing, explicit post-route optimization and export gates. Its measured setup/hold/pulse-width slacks are {a} / {b} / {d} ns. The matched output set is Timing_Repair/Reproduced_Outputs/. These measurements are separate from the supplied checkpoint table.'
page(report,'5. Hardware Implementation - build results',table(rows,[WIDTH*.30,WIDTH*.29,WIDTH*.41]),
    p('The supplied repaired checkpoint was opened in Vivado 2025.1.1 and timing, utilization, bus skew, DRC and methodology were regenerated. Its regenerated bitstream configuration payload matches the supplied BIT exactly; the header timestamp differs. Regenerated probe JSON matches the supplied LTX. This establishes checkpoint/programming-file correspondence, not physical board operation.'),
    p(fresh_message),
    p('Warnings remain: five DRC Warning checks (three PDCN-1569 and one RTSTAT-10 inside vendor dbg_hub, plus ZPS7-1 for absent PS7); four LUTAR-1 methodology Warning checks concern asynchronous debug-hub FIFO resets. No Error/Critical Warning checks are listed. Static timing does not remove potential reset hazards. Do not describe the build as warning-free or independently bootable.'))
page(report,'6. Applications',
    p('An iterative AES block can support an embedded cryptographic coprocessor or laboratory teaching platform. This VIO-controlled experiment verifies block encryption. Production use needs suitable interfaces, buffering, secure key handling, an encryption mode and authentication; those capabilities are future work.'),
    p('7. Conclusion and Future Scope','Heading1'),
    p('The original design has authentic single-vector simulation and physical demonstration evidence but retains its negative 125 MHz setup slack. The separate key-expansion repair passes an extended functional equivalence regression and the supplied routed checkpoint closes static timing under the unchanged clock constraint. Original technical assets and measurements remain preserved.'),
    p('Physical verification of the repaired files and review of final video content/public access remain pending. Test the repaired pair on the actual board, retain the build identity and result screenshots, and review PS initialization/debug-IP warnings. The supplied <link href="https://drive.google.com/file/d/1HdQFdZ9_jw4ydN3tetVhZn5XoXck3o-m/view?usp=sharing">final demonstration URL</link> is recorded in Video_Link.txt. Its presence does not establish all required presentation sections or repaired-board execution.'),
    p('Reproducibility','Heading2'),
    p('Original native source: FPGA_Project_Files/Native_Project/Project1_AES_Vivado_Source.zip. Repaired native source: Project1_AES_Repaired_Vivado_Source.zip in the same folder; extract the complete layout and open AESRepair/build_repaired/aes125_repaired.xpr. Clean repair reproduction uses Timing_Repair/BUILD_REPAIRED.tcl in a new short writable folder. Each BIT/LTX pair is tied to its own checkpoint and manifest.'),
    p('Provenance and preserved records','Heading2'),
    p('Hardware frames come unchanged from the supplied ZIP. Architecture/connectivity drawings are source-based illustrations. Original RTL, constraints, IP, testbench, reports, native project, programming files, WDB, transcript and photographs are preserved. The previous report PDF is retained in Documentation/Archive. New validation logs/reports are labeled by origin; no fresh board execution is claimed.'),
    p('AI assistance was used to prepare documentation and validation tooling. This disclosure does not assign a percentage of HDL authorship. Organizer file requirements are mapped in SUBMISSION_READINESS.md. The original organizer PDF lists 23 September 2026 as its deadline; current deadline/naming must be confirmed separately.','Caption2'))
build('Documentation/Project1_AES_Report.pdf',report,'Project 1 AES-128 - original evidence and timing repair')
import sys
if '--report-only' in sys.argv:
    print('Generated current Project 1 report; saved simulation PDF preserved')
    raise SystemExit(0)
sim=[]
page(sim,'AES timing repair - simulation and evidence review',
    p('Beyond Boolean: Shanshank Pulipati (25BEC0573); Kartik Yadav (25BEC0087). Vivado XSim 2025.1.1, 10 October 2026. DUT: Timing_Repair/RTL/aes_core.v; comparison: Testbench/aes_core_original.v.'),
    p('The testbench checks 104 deterministic known/reference vectors at 125 MHz and compares the original and repaired ciphertext/done each cycle. All reference ciphertexts were recomputed independently with PyCryptodome AES-ECB. It also checks input capture, reset during encryption, restart, held start, 21-cycle completion and retention.'),
    pic('Timing_Repair/Validation/waveform.png',300),
    p('Actual VCD rendered as a plot. Source VCD and vendor console log remain beside this PDF; no schematic or hardware image is generated by this plot.','Caption2'),
    Preformatted('\n'.join(x for x in (ROOT/'Timing_Repair/Validation/xsim_regression_2026-10-10.log').read_text().splitlines() if x.startswith('PASS:')),styles['Code']),
    p('The original one-vector 100 MHz simulation remains in Simulation/simulation_report.pdf. Behavioral simulation is distinct from static timing and board execution. Neither repaired pair has been physically verified during this review.'))
build('Timing_Repair/Validation/simulation_report.pdf',sim,'AES timing repair - independent XSim regression')
print('Generated current Project 1 report and supplemental regression PDF')
