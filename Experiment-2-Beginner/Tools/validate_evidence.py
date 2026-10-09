"""Check source/build identity and every supplied physical-result CSV row."""
from pathlib import Path
import csv
import hashlib
import itertools
import re
import zlib
import zipfile
import posixpath

ROOT = Path(__file__).resolve().parents[1]
manifest = (ROOT / "Results/BUILD_SUCCESS.txt").read_text()
sources = re.findall(r"^(\S+) bytes=(\d+) crc32=([0-9a-f]{8})$", manifest, re.M)
assert len(sources) == 11, "Expected eleven build-manifest source entries"
for name, length, checksum in sources:
    data = (ROOT / name).read_bytes()
    assert len(data) == int(length), name
    assert f"{zlib.crc32(data):08x}" == checksum, name

expected_hashes = {
    "Hardware/radar_top.bit": "88271fc169ca91f16e16ed15e0bd5f1ef874f0dc97cfdcda7fe1f413f6e44dc6",
    "Hardware/radar_top.ltx": "34adb974e793b880dfe469cd21c3c9b3cd039e650a4a76f72d9fe5dcfd575102",
}
for name, digest in expected_hashes.items():
    assert hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == digest, name

with (ROOT / "Results/hardware_results.csv").open(newline="") as f:
    rows = list(csv.DictReader(f))
assert len(rows) == 39, "Expected the original 39-row saved CSV"
seen = set()
for row in rows:
    scenario, alpha, gap = (int(row[k]) for k in ("scenario", "alpha", "gap"))
    seen.add((scenario, alpha, gap))
    count = 3 if scenario == 1 else int(scenario in (2, 3) and alpha <= 2)
    base = 20000 if scenario == 3 else 150 if scenario == 1 else 100
    assert row["status"] == "PASS"
    assert int(row["detections"]) == count, row
    assert int(row["results"]) == 80, row
    assert int(row["cycles"]) == (302 if gap else 104), row
    assert int(row["last_threshold_full"]) == base * alpha, row
assert seen == set(itertools.product(range(4), (1, 2, 4, 8), (0, 1)))

with (ROOT / "Simulation/core_standard_results.csv").open(newline="") as f:
    standard = list(csv.DictReader(f))
assert len(standard) == 80
assert [int(r["cut_index"]) for r in standard] == list(range(10, 90))
assert [int(r["cut_index"]) for r in standard if int(r["detected"])] == [30, 60, 85]
assert (ROOT / "Video_Link.txt").read_bytes() == b"", "Final demo link must remain blank"

with zipfile.ZipFile(ROOT / "FPGA_Project/Project2_Radar_Vivado_Source.zip") as archive:
    assert archive.testzip() is None
    xpr = "Project2_Radar_Final/Build/run_20261008_222502/project2_radar.xpr"
    text = archive.read(xpr).decode()
    references = re.findall(r'<File Path="([^"]+)"', text)
    assert len(references) == 8
    for reference in references:
        target = reference.replace("$PPRDIR", posixpath.dirname(xpr)).replace(
            "$PSRCDIR", posixpath.dirname(xpr) + "/project2_radar.srcs")
        assert posixpath.normpath(target) in archive.namelist(), reference
    for name, _, _ in sources:
        assert archive.read("Project2_Radar_Final/" + name) == (ROOT/name).read_bytes(), name
    assert not any("run_20261008_221922" in name or ".cache/" in name for name in archive.namelist())

bus_skew = (ROOT / "Reports/bus_skew_routed.rpt").read_text()
slacks = re.findall(r"Slack \(MET\)\s*:\s*([\d.]+)ns", bus_skew)
assert slacks == ["19.081", "19.034", "19.339", "19.044"]
assert "VIOLATED" not in bus_skew
assert "unconstrained_internal_endpoints (0)" in (ROOT/"Reports/check_timing.rpt").read_text()
assert "12.176" in (ROOT/"Reports/timing_summary.rpt").read_text()
assert len(re.findall(r"#\d+ Warning", (ROOT/"Reports/drc.rpt").read_text())) == 5
assert len(re.findall(r"#\d+ Warning", (ROOT/"Reports/methodology.rpt").read_text())) == 4
print("EVIDENCE AUDIT PASS: 11 source CRCs, original BIT/LTX SHA-256, 39 physical CSV rows,")
print("all 32 combinations, 80 simulated windows and three exact target indices; final link blank.")
print("Native ZIP integrity, all 8 XPR dependencies and all 11 archived sources verified.")
print("Original reports: 4 bus-skew constraints MET, no unconstrained internal endpoints;")
print("5 DRC and 4 methodology Warning checks retained and disclosed.")
print("This is an archive audit; no new physical-board run is claimed.")
