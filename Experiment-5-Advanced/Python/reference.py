"""Standard-library-only independent predictor and frozen-data checks. No FPGA needed."""
from pathlib import Path
import argparse,csv,itertools,json,hashlib
ROOT=Path(__file__).resolve().parents[1]
def encode(raw):
    levels=[(raw>>(4*f))&15 for f in range(4)]
    if any(z>4 for z in levels):raise ValueError('Illegal feature level; expected 0..4.')
    return sum(int(levels[f]>k)<<(4*f+k) for f in range(4) for k in range(4))
def critical(raw):return (raw&15)==4 and (((raw>>4)&15)>=2 or ((raw>>8)&15)>=2)
def crc16(words):
    crc=65535
    for addr,word in enumerate(words):
        for byte in (addr,word>>8,word&255):
            for k in range(7,-1,-1):
                feedback=(crc>>15)^((byte>>k)&1)
                crc=((crc<<1)&65535)^(0x1021 if feedback else 0)
    return crc
def predict_binary(x,model):
    # Signed +/-1 dot products deliberately avoid XNOR/popcount.
    hidden=0
    for j,w in enumerate(model['hidden_weights']):
        dot=sum((1 if x>>k&1 else -1)*(1 if w>>k&1 else -1) for k in range(16))
        if dot+16>=2*model['thresholds'][j]:hidden|=1<<j
    scores=[sum((1 if hidden>>k&1 else -1)*(1 if w>>k&1 else -1) for k in range(16))+b for w,b in zip(model['output_weights'],model['biases'])]
    winner=max(range(4),key=lambda c:(scores[c],c));sorted_scores=sorted(scores)
    return {'hidden':hidden,'scores':scores,'class':winner,'margin':sorted_scores[-1]-sorted_scores[-2]}
def packed_golden(x,r):
    return (x<<63)|(r['hidden']<<47)|sum((s&511)<<(11+9*j) for j,s in enumerate(r['scores']))|(r['margin']<<2)|r['class']
def verify():
    for name in ['normal','cautious']:
        model=json.loads((ROOT/'Models'/f'{name}.json').read_text())
        words=[int(line,16) for line in (ROOT/'Models'/f'{name}.mem').read_text().split()]
        assert words==model['words'] and crc16(words)==model['crc16']
        splits=json.loads((ROOT/'Data'/f'{name}_splits.json').read_text());groups=[set(splits[k]) for k in ['train','validation','test']]
        assert list(map(len,groups))==[375,125,125] and len(set.union(*groups))==625 and sum(map(len,groups))==625
        golden=(ROOT/'Data'/f'{name}_golden.mem').read_text().split();assert len(golden)==65536
        for x,line in enumerate(golden):assert packed_golden(x,predict_binary(x,model))==int(line,16),(name,x)
        with (ROOT/'Data'/f'{name}_hardware_cases.csv').open() as f:
            rows=list(csv.DictReader(f));assert len(rows)==625
            for row in rows:
                raw=int(row['raw_hex'],16);r=predict_binary(encode(raw),model)
                assert r['hidden']==int(row['hidden_hex'],16) and r['scores']==[int(row[f'score{j}']) for j in range(4)] and r['class']==int(row['class']) and r['margin']==int(row['margin'])
        print(f'{name}: 65536 signed-dot goldens, 625 hardware rows, CRC and disjoint split membership PASS')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--verify',action='store_true');p.add_argument('--profile',choices=['normal','cautious'],default='normal');p.add_argument('--raw',default='0000');a=p.parse_args()
    if a.verify:verify()
    else:
        raw=int(a.raw,16);model=json.loads((ROOT/'Models'/f'{a.profile}.json').read_text());r=predict_binary(encode(raw),model);r['critical_guard']=critical(raw);print(json.dumps(r,indent=2))
