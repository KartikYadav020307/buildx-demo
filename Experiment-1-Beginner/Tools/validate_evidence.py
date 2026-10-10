"""Read-only checks of current package hashes, AES vectors and saved timing."""
from pathlib import Path
import hashlib,json,re,zipfile
ROOT=Path(__file__).resolve().parents[1]
manifest=json.loads((ROOT/'Documentation/FINAL_REVIEW_MANIFEST.json').read_text())
for name,record in manifest['files'].items():
    data=(ROOT/name).read_bytes()
    if record['normalization']=='crlf_to_lf':data=data.replace(b'\r\n',b'\n')
    assert hashlib.sha256(data).hexdigest()==record['sha256'],name
for folder in ('Supplied_Outputs','Reproduced_Outputs'):
    r=ROOT/'Timing_Repair'/folder
    t=(r/'timing_summary_routed.rpt').read_text()
    a=re.search(r'WNS\(ns\).*?\n.*?\n(.*?)\n',t,re.S).group(1).split()
    assert [a[i] for i in (0,4,8)]==['1.490','0.033','2.750']
    assert all(a[i]=='0' for i in (2,6,10))
    assert 'All user specified timing constraints are met' in t
    assert 'unconstrained_internal_endpoints (0)' in t and 'no_clock (0)' in t
    assert re.findall(r'Slack \(MET\)\s*:\s*([\d.]+)ns',(r/'bus_skew_routed.rpt').read_text())==['7.391','7.100','6.642','7.250']
    assert len(re.findall(r'#\d+ Warning',(r/'drc_routed.rpt').read_text()))==5
    assert len(re.findall(r'#\d+ Warning',(r/'methodology_routed.rpt').read_text()))==4
def payload(path):
    data=path.read_bytes();i=2+int.from_bytes(data[:2],'big')+2
    while i<len(data):
        tag=chr(data[i]);i+=1;k=4 if tag=='e' else 2;n=int.from_bytes(data[i:i+k],'big');i+=k
        if tag=='e':return data[i:i+n]
        i+=n
    raise AssertionError('No bitstream configuration payload')
a=ROOT/'Timing_Repair/Supplied_Outputs';b=ROOT/'Timing_Repair/Reproduced_Outputs'
assert payload(a/'aes_top.bit')==payload(b/'aes_top.bit')
assert json.loads((a/'aes_top.ltx').read_text())==json.loads((b/'aes_top.ltx').read_text())
log=(ROOT/'Timing_Repair/Validation/fresh_build_2026-10-10.log').read_text()
assert 'SUCCESS: outputs in' in log and 'PASS: cycle-by-cycle original/repaired equivalence throughout' in log
assert not re.search(r'^(ERROR:|Fatal:|FATAL:)',log,re.M)
for z in (ROOT/'FPGA_Project_Files/Native_Project').glob('*.zip'):
    with zipfile.ZipFile(z) as archive:assert archive.testzip() is None
try:
    from Crypto.Cipher import AES
except ImportError:
    print('Optional live vector recomputation skipped: install pycryptodome. Recorded recomputation remains documented.')
else:
    vectors=(ROOT/'Timing_Repair/Testbench/vectors.mem').read_text().split()
    assert len(vectors)==312
    for i in range(0,len(vectors),3):
        assert AES.new(bytes.fromhex(vectors[i]),AES.MODE_ECB).encrypt(bytes.fromhex(vectors[i+1])).hex()==vectors[i+2].lower()
    print('PASS: 104 AES golden vectors recomputed independently')
assert (ROOT/'Video_Link.txt').read_text().strip()=='https://drive.google.com/file/d/1HdQFdZ9_jw4ydN3tetVhZn5XoXck3o-m/view?usp=sharing', 'Incorrect final Project 1 video URL'
print('PASS: current package manifest, supplied/fresh timing, bus skew, warnings, matched payload/probes and archive integrity')
print('Project 1 final URL is recorded; video content/access and repaired physical-board execution remain unverified.')
