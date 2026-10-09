"""Check the real Tcl VIO reader with mocked property values, without a board.

Run: python python/test_vio_radix.py
Python's tkinter Tcl interpreter is required. This is a host parser test;
it does not simulate Vivado, execute FPGA logic, or replace hardware evidence.
"""
from pathlib import Path
import tkinter

root = Path(__file__).resolve().parents[1]
source = (root / 'Vivado/hardware_test.tcl').read_text()
start = source.index('proc nn_hw_read {name}')
end = source.index('proc nn_hw_reset', start)
tcl = tkinter.Tcl()
tcl.eval('''
set nn_hw_probe(value) mock_probe
proc get_property {property probe} {
    global mock_raw mock_radix
    if {$property eq "INPUT_VALUE"} {return $mock_raw}
    if {$property eq "INPUT_VALUE_RADIX"} {return $mock_radix}
    error "Unexpected property $property"
}
''')
tcl.eval(source[start:end])
cases = [
    ('HEX', '00000024', 36),
    ('HEXADECIMAL', '0000_0024', 36),
    ('UNSIGNED', '36', 36),
    ('UNSIGNED', '49', 49),
    ('SIGNED', '-13784', (-13784) & 0xffffffff),
    ('SIGNED', '-24757', (-24757) & 0xffffffff),
    ('BINARY', '10_0100', 36),
    ('OCTAL', '44', 36),
    ('HEX', 'ffffffff', 0xffffffff),
    ('UNSIGNED', '4294967295', 0xffffffff),
]
for radix, raw, expected in cases:
    tcl.setvar('mock_radix', radix)
    tcl.setvar('mock_raw', raw)
    got = int(tcl.eval('nn_hw_read value'))
    assert got == expected, (radix, raw, got, expected)
    print(f'PASS {radix}: {raw} -> {got}')
assert int(tcl.eval('nn_hw_signed32 4294953512')) == -13784
tcl.setvar('mock_radix', 'UNKNOWN')
try:
    tcl.eval('nn_hw_read value')
except tkinter.TclError as exc:
    assert 'Unsupported radix' in str(exc)
else:
    raise AssertionError('Unknown radix was silently accepted')
print('ALL RADIX TESTS PASSED (10 conversions, signed restore, unknown-radix rejection)')
