"""Convert four flower measurements in cm to a VIO feature word."""
import argparse
import json
from pathlib import Path
import numpy as np
from train_export import quantize_input,infer_integer

parser=argparse.ArgumentParser()
parser.add_argument('measurements',nargs=4,type=float,help='sepal length, sepal width, petal length, petal width (cm)')
args=parser.parse_args()
model=json.loads((Path(__file__).resolve().parents[1]/'Data/model.json').read_text())
q=quantize_input(args.measurements,model)
scores,pred=infer_integer(q,model)
packed=sum((int(v)&255)<<(8*i) for i,v in enumerate(q))
names=['setosa','versicolor','virginica']
print('Quantized inputs:',q.tolist())
print(f'VIO features (hex): {packed:08x}')
print('Raw integer scores:',scores.tolist())
print('Prediction:',int(pred),names[int(pred)])
