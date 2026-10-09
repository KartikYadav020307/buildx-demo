"""Regenerate the organizer's two PDF reports from the archived evidence.

Dependencies: reportlab and Pillow. Run from any directory.
"""
from pathlib import Path
from xml.sax.saxutils import escape
import csv
from io import BytesIO
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from PIL import Image as PILImage
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, Image,
                               Table, TableStyle, PageBreak, Preformatted)

ROOT = Path(__file__).resolve().parents[1]
font_root = Path('/usr/share/fonts/truetype/dejavu')
SANS, BOLD, MONO = 'Helvetica', 'Helvetica-Bold', 'Courier'
if (font_root/'DejaVuSans.ttf').exists():
    for name, file in [('ReportSans', 'DejaVuSans.ttf'),
                       ('ReportSans-Bold', 'DejaVuSans-Bold.ttf'),
                       ('ReportMono', 'DejaVuSansMono.ttf')]:
        pdfmetrics.registerFont(TTFont(name, str(font_root/file)))
    pdfmetrics.registerFontFamily('ReportSans', normal='ReportSans',
                                  bold='ReportSans-Bold', italic='ReportSans',
                                  boldItalic='ReportSans-Bold')
    SANS, BOLD, MONO = 'ReportSans', 'ReportSans-Bold', 'ReportMono'
W, H = A4
WIDTH = W - 92
NAVY = colors.HexColor('#163d55')
TEAL = colors.HexColor('#087c83')
GRAY = colors.HexColor('#53636e')
styles = getSampleStyleSheet()
styles.add(ParagraphStyle('ReportTitle', fontName=BOLD, fontSize=22,
                         leading=27, textColor=NAVY, spaceAfter=15))
styles.add(ParagraphStyle('Section', fontName=BOLD, fontSize=16,
                         leading=21, textColor=NAVY, spaceAfter=13))
styles.add(ParagraphStyle('Text', fontName=SANS, fontSize=9.5,
                         leading=14, spaceAfter=10))
styles.add(ParagraphStyle('Caption2', fontName=SANS, fontSize=8.2,
                         leading=12, textColor=GRAY, spaceAfter=12))
styles.add(ParagraphStyle('Cell', fontName=SANS, fontSize=8.5,
                         leading=12, spaceAfter=0))
styles.add(ParagraphStyle('Code2', fontName=MONO, fontSize=7.3,
                         leading=11, spaceAfter=10))

def p(text, style='Text'):
    return Paragraph(text, styles[style])

def heading(text):
    return p(text, 'Section')

def pic(name, max_height=300, width=WIDTH):
    path = ROOT / name
    with PILImage.open(path) as im:
        iw, ih = im.size
    scale = min(width / iw, max_height / ih)
    if path.suffix.lower() in ('.jpg', '.jpeg'):
        # Size embedded photographs for print; keep original source JPEG bytes.
        with PILImage.open(path) as im:
            im = im.convert('RGB')
            im.thumbnail((round(iw * scale * 3), round(ih * scale * 3)))
            data = BytesIO()
            im.save(data, format='JPEG', quality=92)
            data.seek(0)
        return Image(data, width=iw * scale, height=ih * scale, hAlign='CENTER')
    return Image(str(path), width=iw * scale, height=ih * scale, hAlign='CENTER')

def table(rows, widths=None):
    data = [[p(('<b><font color="#ffffff">' + escape(str(c)) + '</font></b>')
               if i == 0 else escape(str(c)), 'Cell') for c in row]
            for i, row in enumerate(rows)]
    t = Table(data, colWidths=widths or [WIDTH / len(rows[0])] * len(rows[0]),
              hAlign='LEFT', repeatRows=1)
    t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), NAVY),
        ('TEXTCOLOR', (0,0), (-1,0), colors.white),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('LEFTPADDING', (0,0), (-1,-1), 9),
        ('RIGHTPADDING', (0,0), (-1,-1), 9),
        ('TOPPADDING', (0,0), (-1,-1), 7),
        ('BOTTOMPADDING', (0,0), (-1,-1), 7),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.HexColor('#edf4f7'), colors.white]),
        ('LINEBELOW', (0,0), (-1,0), 1, TEAL),
        ('LINEBELOW', (0,1), (-1,-1), .3, colors.HexColor('#cfdae0')),
    ]))
    return t

def footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(colors.HexColor('#cfdae0'))
    canvas.line(46, H-36, W-46, H-36)
    canvas.setFont(SANS, 7.2)
    canvas.setFillColor(GRAY)
    canvas.drawString(46, H-28, 'V-SPACE FPGA Build Challenge | Experiment 2 | PYNQ-Z2')
    canvas.drawString(46, 29, 'Evidence: 8 October 2026 IST | Documentation: 9 October 2026')
    canvas.drawRightString(W-46, 29, f'{doc.page}')
    canvas.restoreState()

def build(path, story, title):
    doc = SimpleDocTemplate(str(ROOT/path), pagesize=A4, leftMargin=46,
                            rightMargin=46, topMargin=58, bottomMargin=48,
                            title=title, author='Shanshank Pulipati; Kartik Yadav',
                            subject='Verified streaming CFAR radar detection on PYNQ-Z2')
    doc.build(story, onFirstPage=footer, onLaterPages=footer)

def page(story, title, *items):
    if story:
        story.append(PageBreak())
    story.extend([heading(title), *items])

report = []
page(report, '1. Objective',
    p('Reconfigurable FPGA<br/>radar target detector', 'ReportTitle'),
    p('<b>Official title:</b> Design and Implementation of a Reconfigurable FPGA-Based Architecture for Real-Time Radar Signal Processing and Intelligent Target Detection.'),
    table([['Team member', 'Registration number'],
           ['Shanshank Pulipati', '25BEC0573'], ['Kartik Yadav', '25BEC0087']], [WIDTH*.65, WIDTH*.35]),
    Spacer(1,12),
    p('<b>Team name:</b> Beyond Boolean. <b>Platform:</b> PYNQ-Z2 / xc7z020clg400-1. <b>Tool:</b> Vivado 2025.1.1. <b>Processing clock:</b> 50 MHz.'),
    p('Implement a streaming cell-averaging constant-false-alarm-rate (CA-CFAR) style threshold detector in programmable logic. Demonstrate exact target detection, runtime sensitivity selection, valid-sample stalls and overflow-safe comparison using controlled synthetic magnitude sequences.'),
    p('The FPGA generates and processes every sample; the host starts frames and reads retained results through Vivado VIO/JTAG. The scope is a reusable detection stage. RF acquisition, ADC, range/Doppler FFT, trained ML and partial bitstream reconfiguration are not implemented.'),
    table([['Verified outcome', 'Measured or checked result'],
           ['Core simulation', '10,721 checked results from 12,963 accepted samples'],
           ['Controller and physical sweep', 'All 32 scenario/alpha/gap combinations plus repeat'],
           ['Standard frame', '80 full windows; targets at CUT indices 30, 60, 85'],
           ['Routed timing', 'WNS 12.176 ns; WHS 0.018 ns; WPWS 2.000 ns']], [WIDTH*.40,WIDTH*.60]),
    Spacer(1,10),
    p('The original successful build and physical evidence are retained. This documentation update does not claim a new board execution. The final narrated video URL is intentionally blank. Original routed report text and native .xpr/IP source archive have not yet been supplied.', 'Caption2'))

page(report, '2. Block diagram and detection method',
    pic('Images/block_diagram.png', 280),
    p('Figure 1. Source-derived architecture. The VIO, controller and detector share the 50 MHz clock. The H16 reference is nominally 125 MHz; the MMCM settings multiply by eight and divide by twenty.', 'Caption2'),
    p('A chronological window contains <b>8 training + 2 guard + 1 CUT + 2 guard + 8 training</b> samples. The sixteen training values are accumulated at full precision. Guard cells exclude nearby energy from the estimated background.'),
    Preformatted('threshold = floor(training_sum / 16) * alpha\nalpha = 1, 2, 4 or 8\ndetection = (unsigned CUT > full 19-bit threshold)', styles['Code2']),
    p('The total training sum has 20 bits; the full threshold has 19 bits. The displayed 16-bit threshold saturates at 65,535, while detection always uses the full threshold. Equality does not detect. These alpha values demonstrate sensitivity selection, not a calibrated probability of false alarm.'),
    p('The window advances only on accepted samples. The first complete window uses samples 0-20 and reports CUT index 10. A 100-sample frame yields exactly 80 results, indices 10-89; no boundary padding is added. The controller drains the pending pipeline before finishing.'),
    p('Partial training sums, total sum and threshold/comparison form three register stages. A result appears two clock intervals after accepting the newest sample in its full window. Configuration and CUT metadata travel with the arithmetic. Reset clears the window and pending valid results.'))

page(report, '3. RTL design, hierarchy and schematic',
    table([['Module / instance', 'Responsibility'],
           ['radar_top', 'Board clock/MMCM, startup reset, VIO, LEDs and u_demo'],
           ['radar_top.u_demo : radar_demo', 'Generate 100 samples; latch configuration; insert optional gaps; capture counts, masks, indices and timing'],
           ['radar_demo.u_core : cfar_core', '21-cell window, pipelined training sums, full-width threshold and comparison'],
           ['radar_top.u_vio : vio_radar', 'Five control outputs and seventeen monitored inputs; generated by Vivado Tcl']], [WIDTH*.39, WIDTH*.61]),
    Spacer(1,13),
    pic('Images/rtl_schematic.png', 195),
    p('Figure 2. Genuine Yosys 0.33 elaborated top schematic. The full-resolution SVG/DOT, used-module JSON netlist and tool transcript are supplied for zoomed inspection. This overview is not a Vivado GUI export. Proprietary VIO and clock primitives are black boxes/library declarations in this offline structural check; their timing/behavior is established by the supplied Vivado build and physical evidence, not by Yosys.', 'Caption2'),
    p('<b>Control and observation:</b> reset, start, scenario, scale and gap are VIO outputs. Monitored values include busy/done, timeout, frame ID, counts, three positions, full detection mask, full/display thresholds, cycles, retained configuration and the RAD2 design identifier (0x52414432).'),
    p('<b>Clock/reset and constraints:</b> 50 MHz clock buffers feed all processing and VIO. The eight-stage startup reset releases after clock lock. XDC assigns H16 and LEDs R14/P14/N16/M14, with LVCMOS33. Only human-visible LED output paths are false-pathed; detector/VIO internal paths are not exempted.'),
    p('All three original RTL modules, both testbenches and all five original Vivado Tcl files retain exact byte/CRC identity with the successful build manifest. No functional RTL edit was made for this documentation upload.', 'Caption2'))

page(report, '4. Simulation results',
    p('The independent chronological-array scoreboard checks arithmetic, CUT indices, thresholds, valid timing and detections rather than reproducing the DUT shift-register implementation. Supplied Icarus Verilog 12.0 results passed on 8 October 2026. The full successful laptop log independently records both suites passing in Vivado XSim 2025.1.1.'),
    pic('Images/simulation_waveform.png', 300),
    p('Figure 3. Actual supplied core VCD rendered as a waveform; not a fabricated GUI capture. The original VCD remains in Simulation/. See the dedicated simulation PDF for the standard-target plot, exact transcript and reproduction steps.', 'Caption2'),
    table([['Test', 'Coverage / outcome'],
           ['Core scoreboard', '10,721 valid results; 12,963 samples; 112 directed/random/reset frame sequences'],
           ['Core corner cases', 'Unsigned overflow, display saturation, equality, guards, truncation, gaps, random alpha changes, short frames and reset'],
           ['Controller', '4 scenarios x 4 alpha factors x 2 gap settings, then a repeat: 33 checked frames'],
           ['Controller robustness', 'Held-start and reset during active frame checks'],
           ['Standard synthetic sequence', 'Three detections at 30, 60, 85; 80 results for indices 10-89']], [WIDTH*.32,WIDTH*.68]),
    Spacer(1,9),
    p('Local simulation traces/logs are preserved under their real origin. The original Vivado log is Evidence/vivado_build.log. No additional simulator run is claimed during publication.', 'Caption2'))

page(report, '5. Hardware implementation - routed build',
    p('The supplied laptop build completed on <b>8 October 2026 at 22:40:16 IST</b>. It created a fresh xc7z020clg400-1 project, generated VIO, passed both XSim suites, synthesized, routed, checked setup/hold/pulse-width timing and DRC, and wrote matching bitstream/probe files. The full successful log and original BUILD_SUCCESS marker are included.'),
    table([['Metric', 'Actual available evidence'],
           ['Vivado / device', '2025.1.1 / xc7z020clg400-1'],
           ['Processing clock', '50 MHz; 20 ns period'],
           ['WNS (setup slack)', '12.176 ns'],
           ['WHS (hold slack)', '0.018 ns'],
           ['WPWS (pulse-width slack)', '2.000 ns'],
           ['Bitstream DRC', 'Full log: DRC finished with 0 Errors; bitgen completed successfully'],
           ['LUT / FF / BRAM / DSP', 'Original utilization.rpt not supplied; no resource count invented'],
           ['Power', 'No measured power supplied; default-activity estimate not treated as measurement'],
           ['Hardware outputs', 'Original radar_top.bit and radar_top.ltx, unchanged bytes']], [WIDTH*.39,WIDTH*.61]),
    Spacer(1,12),
    p('<b>Warning review remains partial.</b> The log includes bus-skew-report and power-activity warnings. It records the generated routed bus-skew report, but its contents were not supplied. The methodology/check-timing reports also need retrieval. Positive setup/hold/pulse-width margins and the build success marker do not prove every methodology or bus-skew recommendation is resolved.'),
    p('The original generated .xpr/IP directory and routed checkpoint are also absent from the provided inputs. Original build Tcl and dependencies recreate a real native project; the tested BIT/LTX can already be programmed without rebuilding. No replacement .xpr or missing report was fabricated.'),
    p('An archive audit checks all eleven source CRCs and exact BIT/LTX SHA-256 identities, every saved board CSV row and the simulated standard-frame indices. Tools/validate_evidence.py records that audit; it does not rerun or remeasure hardware.', 'Caption2'))

page(report, '5. Hardware implementation - physical setup',
    p('The actual PYNQ-Z2 was programmed through Vivado Hardware Manager using the supplied matching BIT/LTX. The existing normal power/boot setup and USB/JTAG connection were used. Ethernet is visible in the photographs; the CFAR data/control path is in PL and VIO/JTAG, not network sample transport.'),
    pic('Images/board_setup.jpg', 330),
    p('Figure 4. Original user-supplied PYNQ-Z2 setup photo from the Project 2 Drive folder. No generated hardware photograph is used.', 'Caption2'),
    pic('Images/hardware_output.jpg', 205),
    p('Figure 5. Original photo of the real board beside the laptop showing the passing Vivado hardware console. The exact console capture is supplied on the following page and in Images/.', 'Caption2'))

page(report, '5. Hardware implementation - verified output',
    pic('Images/hardware_verification.png', 285),
    p('Figure 6. Actual Vivado console: all combinations passed and final standard three-target frame retained. Original HARDWARE_PASS marker time: 8 October 2026 23:54:05 IST.', 'Caption2'),
    table([['Physical case', 'Alpha', 'Targets / zero-based indices'],
           ['Noise: constant 100', '1 / 2 / 4 / 8', '0 / none'],
           ['Targets 1000, 1200, 900; background 100', '1 / 2 / 4 / 8', '3 / 30, 60, 85'],
           ['Weak 300; background 100', '1 / 2', '1 / 30'],
           ['Weak 300; background 100', '4 / 8', '0 / none'],
           ['Target 60000; background 20000', '1 / 2', '1 / 30'],
           ['Target 60000; background 20000', '4 / 8', '0 / none; full-width threshold']], [WIDTH*.48,WIDTH*.19,WIDTH*.33]),
    Spacer(1,10),
    p('Every scenario/factor pair passed with both continuous and gapped input: <b>32 unique combinations</b>, followed by a repeated standard frame. The unchanged saved CSV contains <b>39 PASS rows</b>, including additional repetitions/demonstrations. Reset explains repeated frame IDs in the later demonstration rows.'),
    p('Each frame returned 80 windows. Continuous input takes 104 cycles (2.08 microseconds); two idle clocks between samples takes 302 cycles (6.04 microseconds). These are FPGA frame-processing times at 50 MHz, excluding host/JTAG command overhead.'),
    p('The hardware script verifies counts, three positions, the full 128-bit detection mask, thresholds, cycles, frame/configuration and design ID before writing a PASS row. The CSV itself stores counts/cycles/last threshold, not separate position/mask columns; the PASS marker and console corroborate those additional checks.', 'Caption2'))

page(report, '6. Applications',
    p('A streaming background-adaptive threshold stage can follow a radar magnitude or power pipeline and mark candidate detections. Deterministic FPGA processing and one accepted sample per clock support integration with streaming acquisition/FFT logic. This controlled experiment establishes the detector arithmetic, valid timing and observation interface rather than a full sensing system.'),
    p('Runtime alpha selection demonstrates the sensitivity tradeoff: the weak target at index 30 is rejected at factor four and accepted at factor two. The same hardware and bitstream handle both choices. Gapped input preserves the exact detections because the sample window advances only on data_valid.'),
    heading('7. Conclusion and future scope'),
    p('The original complete design passed the independent core simulation, all controller cases and the physical 32-combination sweep plus repeat. The standard frame produced three correct indices and 80 full windows. Routed setup/hold/pulse-width margins are positive at the 50 MHz processing clock; the original bitstream and matching probes are preserved.'),
    p('Next technical steps are to retrieve/review the original utilization, timing, methodology and bus-skew reports; integrate real acquisition and range/Doppler processing; calibrate alpha against representative clutter and false-alarm requirements; and validate performance on recorded or live radar measurements. A wider framing/index scheme would be needed for long streams beyond the demonstration\'s 100-sample frames.'),
    p('<b>Submission status:</b> final narrated video URL intentionally blank. Team: Beyond Boolean. The original routed reports and native project source archive remain to be supplied. These are documented gaps, not evidence that the completed board test failed.'),
    heading('Evidence and primary references'),
    p('Local evidence: Results/BUILD_SUCCESS.txt; Results/HARDWARE_PASS.txt; Results/hardware_results.csv; Evidence/vivado_build.log; Simulation/transcript.txt and VCD/CSV files. The readiness audit maps every organizer item to a file.', 'Caption2'),
    p('AMD/Xilinx PYNQ-Z2 XDC: github.com/Xilinx/xup_fpga_vivado_flow, source/pynq-z2/lab5/uart_led_pins_pynq.xdc. AMD 7-Series Libraries Guide UG953: MMCME2_BASE. AMD Vivado Tcl Command Reference UG835: commit_hw_vio and refresh_hw_vio. Original links are in README.md.', 'Caption2'))

build('Documentation/Project2_Radar_Report.pdf', report,
      'Project 2 - Reconfigurable FPGA Radar Target Detector')

simulation = []
page(simulation, 'Simulation report - Experiment 2',
    p('Streaming CA-CFAR<br/>verification evidence', 'ReportTitle'),
    p('DUTs: cfar_core and radar_demo. Original SystemVerilog testbenches and exact source bytes match the successful Vivado build. Supplied local simulation: Icarus Verilog 12.0, 8 October 2026. Independent laptop confirmation: Vivado XSim 2025.1.1, same day.'),
    table([['Test suite', 'Observed pass output'],
           ['tb_cfar_core', 'CORE SIMULATION PASS: checked=10721 accepted=12963'],
           ['tb_radar_demo', 'DEMO SIMULATION PASS: 33 frame checks']], [WIDTH*.30,WIDTH*.70]),
    Spacer(1,12),
    p('<b>Reference model:</b> independent chronological sample array and expected-result queue. It checks full-width arithmetic, valid timing, index alignment and detection against each emitted DUT result. Coverage includes equality, training/guard exclusion, integer truncation, unsigned high values, display saturation, continuous/gapped traffic, random values/scales, short frames and reset.'),
    p('<b>Controller:</b> four scenarios, four factors and two gap modes produce 32 combinations; one repeated standard frame gives 33 checks. The testbench additionally checks held-start behavior and reset during processing.'),
    pic('Images/cfar_detection.png', 250),
    p('Figure S1. Plot from the original standard-frame result CSV. Exactly 80 full windows and three detections at 30, 60, 85; alpha four. Magnitudes are controlled synthetic unsigned linear-domain values, not RF measurements.', 'Caption2'))

page(simulation, 'Waveform, timing and expected results',
    pic('Simulation/waveform.png', 330),
    p('Figure S2. Real supplied cfar_core.vcd rendered as traces. Reset clears pending results; result_valid starts only after a full window and pipeline latency. Threshold_full is the comparison value, distinct from a saturating display. Full original traces are retained in Simulation/.', 'Caption2'),
    table([['Case at alpha four', 'Detection result', 'Frame results'],
           ['Constant 100', '0 targets', '80'],
           ['1000/1200/900 at 30/60/85', '3 targets: 30, 60, 85', '80'],
           ['Weak 300 at 30', '0; factor two produces 1 at 30', '80'],
           ['20000 background / 60000 target', '0: compare against full 80000 threshold', '80']], [WIDTH*.47,WIDTH*.36,WIDTH*.17]),
    Spacer(1,10),
    p('A result for CUT n-10 appears two clocks after the accepted newest sample n (n at least 20). Stalls change wall-clock spacing but never duplicate a sample window. The controller captures/drains outputs and finishes in 104 continuous cycles or 302 gapped cycles. At the confirmed 50 MHz design clock these equal 2.08 and 6.04 microseconds; host/JTAG time is excluded.'))

page(simulation, 'Transcripts and reproduction',
    p('The complete exact local output is Simulation/transcript.txt. The full successful XSim/synthesis/routing run is Evidence/vivado_build.log. Representative unmodified local transcript lines follow:'),
    Preformatted('CORE SIMULATION PASS: checked=10721 accepted=12963\nDEMO PASS sc=1 alpha=4 gap=0 detections=3 results=80 cycles=104\nDEMO PASS sc=1 alpha=4 gap=1 detections=3 results=80 cycles=302\nDEMO PASS sc=2 alpha=4 gap=0 detections=0 results=80 cycles=104\nDEMO PASS sc=2 alpha=2 gap=0 detections=1 results=80 cycles=104\nDEMO SIMULATION PASS: 33 frame checks', styles['Code2']),
    heading('Reproduce locally with Icarus'),
    p('Run from the experiment root with iverilog/vvp installed. The testbenches save VCD/CSV/PASS outputs. Use a separate copy to preserve this original archive.'),
    Preformatted('mkdir -p Results Simulation\niverilog -g2012 -s tb_cfar_core -o core.vvp \\\n  RTL/cfar_core.v Testbench/tb_cfar_core.sv\nvvp core.vvp +OUTDIR=.\niverilog -g2012 -s tb_radar_demo -o demo.vvp \\\n  RTL/cfar_core.v RTL/radar_demo.v Testbench/tb_radar_demo.sv\nvvp demo.vvp +OUTDIR=.', styles['Code2']),
    p('For the complete vendor flow, RUN_PROJECT2.cmd invokes Vivado/build_project.tcl, which runs both XSim suites and requires their PASS markers before synthesis/routing. This flow recreates VIO and the native project. A new build clears old markers and hardware outputs; preserve the original archive first.'),
    heading('Schematic and evidence audit'),
    p('The Yosys structural check generates the actual top schematic. Simulation/vio_elaboration_stub.v and vendor clock-library declarations serve as black boxes; this check does not verify their implementation, lock, routing or timing. Images contains the DOT/PNG/SVG; Simulation contains the used-module JSON and complete tool transcript. The generation recipe is Tools/SCHEMATIC_REPRODUCTION.md.'),
    p('Run python Tools/validate_evidence.py for source/bitstream identity and saved CSV consistency. No simulation or new board run is claimed by the PDF generation process. Old September standalone core or AXI overlay results are not used as evidence for this complete October design.', 'Caption2'))

build('Simulation/simulation_report.pdf', simulation, 'Project 2 - Simulation Report')
print('Generated Documentation/Project2_Radar_Report.pdf and Simulation/simulation_report.pdf')
