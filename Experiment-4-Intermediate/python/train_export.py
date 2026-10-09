"""Train a tiny Iris MLP and export the exact fixed-point hardware model.

Requires only NumPy. All data are bundled; no downloads are performed.
Use --check to validate the existing exported model without retraining.
"""
from pathlib import Path
import argparse
import csv
import itertools
import json
import numpy as np

ROOT = Path(__file__).resolve().parents[1]

def quantize_input(x, model):
    z = (np.asarray(x) - np.asarray(model['mean'])) / np.asarray(model['std'])
    return np.clip(np.rint(z * 32), -128, 127).astype(np.int64)

def infer_integer(xq, model):
    xq = np.asarray(xq, dtype=np.int64)
    hacc = xq @ np.asarray(model['w1_q'], dtype=np.int64) + np.asarray(model['b1_q'])
    h = np.clip(hacc >> 6, 0, 32767)
    scores = h @ np.asarray(model['w2_q'], dtype=np.int64) + np.asarray(model['b2_q'])
    return scores, np.argmax(scores, axis=-1)

def split_indices(y):
    rng = np.random.default_rng(2026)
    train, val, test = [], [], []
    for c in range(3):
        ix = rng.permutation(np.flatnonzero(y == c))
        train.extend(ix[:30]); val.extend(ix[30:35]); test.extend(ix[35:])
    return np.asarray(train), np.asarray(val), np.asarray(test)

def integer_model(params, mean, std):
    w1, b1, w2, b2 = params
    return dict(mean=mean.tolist(), std=std.tolist(),
                w1_q=np.clip(np.rint(w1*64), -128, 127).astype(int).tolist(),
                b1_q=np.rint(b1*2048).astype(int).tolist(),
                w2_q=np.clip(np.rint(w2*64), -128, 127).astype(int).tolist(),
                b2_q=np.rint(b2*2048).astype(int).tolist())

def train(x, y, tr, va):
    mean, std = x[tr].mean(axis=0), x[tr].std(axis=0)
    z = (x[tr]-mean)/std
    rng = np.random.default_rng(42)
    params = [rng.normal(0, .5, (4,4)), np.full(4, .1),
              rng.normal(0, .5, (4,3)), np.zeros(3)]
    first = [np.zeros_like(p) for p in params]
    second = [np.zeros_like(p) for p in params]
    best_key, best = None, None
    for epoch in range(1, 4001):
        w1,b1,w2,b2 = params
        pre = z@w1+b1; h = np.maximum(pre,0); logits = h@w2+b2
        ex = np.exp(logits-logits.max(axis=1,keepdims=True))
        prob = ex/ex.sum(axis=1,keepdims=True)
        loss = -np.log(prob[np.arange(len(tr)),y[tr]]+1e-15).mean()
        d = prob.copy(); d[np.arange(len(tr)),y[tr]] -= 1; d /= len(tr)
        dh = (d@w2.T)*(pre>0)
        grads = [z.T@dh+.002*w1, dh.sum(axis=0), h.T@d+.002*w2, d.sum(axis=0)]
        for j,g in enumerate(grads):
            first[j] = .9*first[j]+.1*g
            second[j] = .999*second[j]+.001*g*g
            params[j] -= .02*(first[j]/(1-.9**epoch))/(np.sqrt(second[j]/(1-.999**epoch))+1e-8)
        params[0] = np.clip(params[0], -1.9, 1.9)
        params[2] = np.clip(params[2], -1.9, 1.9)
        if epoch % 100 == 0:
            m = integer_model(params,mean,std)
            _,pred = infer_integer(quantize_input(x[va],m),m)
            key = (int((pred == y[va]).sum()), -loss)
            if best_key is None or key > best_key:
                best_key = key
                best = ([p.copy() for p in params], epoch)
    params, epoch = best
    model = integer_model(params,mean,std)
    model.update(w1_float=params[0].tolist(),b1_float=params[1].tolist(),
                 w2_float=params[2].tolist(),b2_float=params[3].tolist(),
                 selected_epoch=epoch,seed_split=2026,seed_weights=42)
    return model

def signed_literal(n, bits):
    return f"{bits}'sh{int(n)&((1<<bits)-1):0{(bits+3)//4}x}"

def emit_function(name, weights, bits):
    arr = np.asarray(weights)
    is_matrix = arr.ndim == 2
    header = (f'function automatic signed [{bits-1}:0] {name}(input integer node, input integer term);\n'
              f'  case (node * 4 + term)\n') if is_matrix else (
              f'function automatic signed [{bits-1}:0] {name}(input integer node);\n  case (node)\n')
    lines = [header]
    if is_matrix:
        for node in range(arr.shape[1]):
            for term in range(arr.shape[0]):
                lines.append(f'    {node*4+term}: {name} = {signed_literal(arr[term,node],bits)};\n')
    else:
        for node,v in enumerate(arr):
            lines.append(f'    {node}: {name} = {signed_literal(v,bits)};\n')
    lines.append(f"    default: {name} = {bits}'sd0;\n  endcase\nendfunction\n\n")
    return ''.join(lines)

def export(model,x,y,tr,va,te):
    for d in ['RTL','Testbench','Data','Documentation','Simulation','Images','Vivado']:
        (ROOT/d).mkdir(parents=True,exist_ok=True)
    (ROOT/'Data/model.json').write_text(json.dumps(model,indent=2)+'\n')
    text = '// Generated trained constants. Include INSIDE each core module.\n// No include guard: both core modules need their own functions.\n\n'
    text += emit_function('nn_w1',model['w1_q'],8)
    text += emit_function('nn_b1',model['b1_q'],32)
    text += emit_function('nn_w2',model['w2_q'],8)
    text += emit_function('nn_b2',model['b2_q'],32)
    (ROOT/'RTL/nn_weights.vh').write_text(text)
    xq = quantize_input(x,model)
    rng = np.random.default_rng(8102)
    edge = np.array(list(itertools.product([-128,-1,0,127],repeat=4)),dtype=np.int64)
    vectors = np.concatenate([xq,edge,rng.integers(-128,128,size=(4096,4))])
    scores,pred = infer_integer(vectors,model)
    with (ROOT/'Data/golden_vectors.mem').open('w') as f:
        for q,s,p in zip(vectors,scores,pred):
            word = sum((int(v)&255)<<(8*i) for i,v in enumerate(q))
            for j,v in enumerate(s): word |= (int(v)&0xffffffff) << (32+32*j)
            word |= int(p)<<128
            f.write(f'{word:033x}\n')
    (ROOT/'Testbench/vector_count.vh').write_text(f'`define VECTOR_COUNT {len(vectors)}\n')
    scores_all,pred_all = infer_integer(xq,model)
    part = np.full(len(x),'test',dtype=object); part[tr]='train'; part[va]='validation'
    with (ROOT/'Data/iris_cases.csv').open('w',newline='') as f:
        w = csv.writer(f)
        w.writerow(['index','split','sepal_length','sepal_width','petal_length','petal_width',
                    'true_class','pred_class','packed_hex','x0_q','x1_q','x2_q','x3_q','score0','score1','score2'])
        for i in range(len(x)):
            packed = sum((int(v)&255)<<(8*j) for j,v in enumerate(xq[i]))
            w.writerow([i,part[i],*x[i],int(y[i]),int(pred_all[i]),f'{packed:08x}',*xq[i],*scores_all[i]])
    z = (x-model['mean'])/model['std']
    float_scores = np.maximum(z@model['w1_float']+model['b1_float'],0)@model['w2_float']+model['b2_float']
    fp = float_scores.argmax(axis=1)
    cm = np.zeros((3,3),dtype=int)
    for t,p in zip(y[te],pred_all[te]): cm[t,p] += 1
    stats = dict(topology=[4,4,3],macs_per_inference=28,train_size=len(tr),validation_size=len(va),test_size=len(te),
                 train_indices=tr.tolist(),validation_indices=va.tolist(),test_indices=te.tolist(),
                 selected_epoch=model['selected_epoch'],validation_correct=int((pred_all[va]==y[va]).sum()),
                 float_test_correct=int((fp[te]==y[te]).sum()),quantized_test_correct=int((pred_all[te]==y[te]).sum()),
                 quantized_test_accuracy=float((pred_all[te]==y[te]).mean()),
                 test_float_quantized_agreement=int((fp[te]==pred_all[te]).sum()),
                 confusion_matrix_test=cm.tolist(),rtl_vector_count=len(vectors),
                 max_absolute_golden_score=int(np.abs(scores).max()),
                 input_clipped_count=int(np.any(np.abs(np.rint(z*32))>127,axis=1).sum()))
    (ROOT/'Documentation/model_metrics.json').write_text(json.dumps(stats,indent=2)+'\n')
    # Selection is by validation accuracy, then training loss. Test labels are not used for selection.
    print(json.dumps({k:v for k,v in stats.items() if not k.endswith('indices')},indent=2))

def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--check',action='store_true'); args=ap.parse_args()
    data = np.loadtxt(ROOT/'Data/iris.csv',delimiter=',',skiprows=1)
    x,y = data[:,:4],data[:,4].astype(int)
    tr,va,te = split_indices(y)
    model = json.loads((ROOT/'Data/model.json').read_text()) if args.check else train(x,y,tr,va)
    export(model,x,y,tr,va,te)

if __name__ == '__main__': main()
