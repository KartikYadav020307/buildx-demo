"""Assemble current individual PDFs without rerunning or altering FPGA evidence."""
from pathlib import Path
from io import BytesIO
from xml.sax.saxutils import escape
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak
from pypdf import PdfReader, PdfWriter

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / 'Final_Report/Beyond_Boolean_Final_Report.pdf'
WIDTH = A4[0] - 92
STYLES = getSampleStyleSheet()
STYLES.add(ParagraphStyle('Body2', fontName='Helvetica', fontSize=10, leading=14, spaceAfter=10))
STYLES.add(ParagraphStyle('Cell2', fontName='Helvetica', fontSize=9, leading=12))
PROJECTS = [
    ('AES-128', 'Experiment-1-Beginner', 'Project1_AES_Report.pdf'),
    ('Radar CA-CFAR', 'Experiment-2-Beginner', 'Project2_Radar_Report.pdf'),
    ('ECG FIR', 'Experiment-3-Intermediate', 'Project3_ECG_Report.pdf'),
    ('NN inference', 'Experiment-4-Intermediate', 'Project4_NN_Report.pdf'),
    ('BNN response', 'Experiment-5-Advanced', 'Project5_Report.pdf'),
]

def paragraph(text, style='Body2'):
    return Paragraph(text, STYLES[style])

def table(rows, widths):
    result = Table([[paragraph(escape(str(c)), 'Cell2') for c in row] for row in rows], colWidths=widths, repeatRows=1)
    result.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#e8edf1')),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('TOPPADDING', (0, 0), (-1, -1), 7),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 7),
        ('LINEBELOW', (0, 0), (-1, -1), .3, colors.HexColor('#c3ccd3')),
    ]))
    return result

def footer(canvas, doc):
    canvas.setFont('Helvetica', 8)
    canvas.setFillColor(colors.HexColor('#455866'))
    canvas.drawString(46, 28, 'Beyond Boolean | Submission overview | 10 October 2026')
    canvas.drawRightString(A4[0] - 46, 28, f'Overview {doc.page}')

story = [
    paragraph('V-SPACE FPGA Build Challenge 2026', 'Title'),
    paragraph('Beyond Boolean - combined team report', 'Heading1'),
    table([
        ['Team member', 'Registration number'],
        ['Shanshank Pulipati', '25BEC0573'],
        ['Kartik Yadav', '25BEC0087'],
    ], [WIDTH * .62, WIDTH * .38]),
    Spacer(1, 12),
    paragraph('<b>Board:</b> PYNQ-Z2. <b>FPGA:</b> Xilinx Zynq-7000 XC7Z020CLG400-1. <b>Tools:</b> Vivado 2025.1.1, Vitis HLS and Python/PYNQ.'),
    paragraph('Five experiments: two beginner, two intermediate and one advanced. This overview is followed by the current individual project reports, preserving their diagrams, results, dates, warnings and provenance.'),
    paragraph('Implemented scope and recorded results', 'Heading2'),
    table([
        ['Experiment', 'Implementation and recorded evidence'],
        ['1 - Beginner\nAES-128', 'Iterative VIO-controlled block encryption. Original board evidence is preserved. Separate repair: 104-vector equivalence and full source build; 125 MHz WNS +1.490 ns. Repaired-board test pending.'],
        ['2 - Beginner\nRadar CA-CFAR', '21-cell detector on synthetic magnitudes at 50 MHz; 80 windows per 100 samples. Saved 39 PASS rows cover 32 parameter combinations. Routed WNS +12.176 ns.'],
        ['3 - Intermediate\nECG FIR', '128-tap Q4.12 FIR in PL; DMA and ARM peak analysis. Saved 12,288 ECG board samples agree with reference. Sine-test 50 Hz reduction 53.74 dB.'],
        ['4 - Intermediate\nNN inference', 'Frozen trained 4-4-3 Iris model. Parallel/shared-MAC core latencies 4/36 cycles at 50 MHz. All 45 saved score rows agree; labels correct in 43/45.'],
        ['5 - Advanced\nBNN response', '16-16-4 BNN, CRC-checked policy banks and independent latched fault controller. Saved 64 core cases agree. Parallel/folded latency 5/21 cycles; 10 ms watchdog.'],
    ], [WIDTH * .25, WIDTH * .75]),
    PageBreak(),
    paragraph('Submission and verification status', 'Heading1'),
    paragraph('All required experiment folders and technical file categories are present. Each individual PDF contains objective, block diagram, RTL design, simulation results, hardware implementation, applications and conclusion/future scope. The home README records the confirmed team, registrations, board and all five summaries.'),
    paragraph('Final demonstration links', 'Heading2'),
]
for index, (name, folder, _) in enumerate(PROJECTS, 1):
    url = (ROOT / folder / 'Video_Link.txt').read_text().strip()
    assert url.startswith('https://drive.google.com/'), (folder, url)
    story.append(paragraph(f'<b>Project {index} - {escape(name)}:</b> <link href="{escape(url)}" color="blue">Open final demonstration</link>'))
story.extend([
    paragraph('All five final URLs are recorded. Final edit content, required presentation sections and anonymous reviewer access remain unverified. Organizer page 6 requires introduction/problem, architecture and RTL in software, physical setup/connections/working demonstration, and conclusion.'),
    paragraph('Evidence qualifications and remaining work', 'Heading2'),
    paragraph('<b>AES:</b> original 125 MHz build retains WNS -0.104 ns and four failing setup endpoints. The repaired candidate passes static timing (+1.490 ns), simulation and full reproduction, but needs a genuine board test using its matching BIT/LTX. Original footage does not establish repaired-board operation.'),
    paragraph('<b>Other projects:</b> Project 4 inventory/status metadata has been refreshed; historical snapshots remain preserved. Original native project paths may need relocation. Project 3 full workspaces are linked externally. Project 5 automated VIO safety PASS is distinct from physical-button evidence; review the replacement video for eligible watchdog clear. Earlier footage ended with STOP latched.'),
    paragraph('<b>Scope and provenance:</b> source-derived conceptual diagrams remain labeled; actual tool schematics and recorded board results retain their origin. Raw DRC/methodology warnings and AI-assistance disclosures are preserved. Report generation and metadata checks do not run hardware, HDL simulation, synthesis or routing. These demonstrations do not establish clinical or autonomous-vehicle validation.'),
    paragraph('<b>Organizer checks:</b> confirm the active deadline/extension and accepted repository name. The supplied requirements print 23 September 2026 and different leader/team naming examples. The repository remains buildx-demo. See Final_Report/SUBMISSION_STATUS.md for the current checklist.'),
])
stream = BytesIO()
SimpleDocTemplate(stream, pagesize=A4, leftMargin=46, rightMargin=46, topMargin=42, bottomMargin=45,
                  title='Beyond Boolean - V-SPACE combined report', author='Shanshank Pulipati; Kartik Yadav').build(story, onFirstPage=footer, onLaterPages=footer)
overview = PdfReader(stream)
assert len(overview.pages) == 2, f'Overview overflow: {len(overview.pages)} pages'
writer = PdfWriter()
writer.append(overview, import_outline=False)
page_count = 2
for name, folder, report in PROJECTS:
    source = PdfReader(ROOT / folder / 'Documentation' / report)
    writer.add_outline_item(name, page_count)
    writer.append(source, import_outline=False)
    page_count += len(source.pages)
writer.add_metadata({'/Title': 'Beyond Boolean - V-SPACE combined final report', '/Author': 'Shanshank Pulipati; Kartik Yadav', '/Subject': 'Current individual reports and submission overview; saved evidence qualifications preserved'})
with DEST.open('wb') as output:
    writer.write(output)
assert len(PdfReader(DEST).pages) == page_count
print(f'Combined report: {page_count} pages, including two overview pages.')
