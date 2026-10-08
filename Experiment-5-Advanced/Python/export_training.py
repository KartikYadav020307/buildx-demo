from pathlib import Path
import numpy as np,json,csv,itertools,hashlib
import argparse
parser=argparse.ArgumentParser();parser.add_argument('--input',type=Path,default=Path(__file__).resolve().parents[1]/'Training_Reproduction');parser.add_argument('--output',type=Path,default=Path(__file__).resolve().parents[1]/'Training_Reproduction'/'exported');args=parser.parse_args()
root=args.output
for d in ['Models','Data']: (root/d).mkdir(parents=True,exist_ok=True)
raw=np.array(list(itertools.product(range(5),repeat=4)));bits=(raw[:,:,None]>np.arange(4)).reshape(-1,16).astype(int)
# Independent signed-dot-product predictor, no popcount.
def predict(x,w,t,o,b):
 hh=((x*2-1)@w.T+16>=2*t).astype(int);ss=(hh*2-1)@o.T+b
 cc=3-np.argmax(ss[:,::-1],1);sm=np.sort(ss,axis=1);mm=sm[:,-1]-sm[:,-2]
 return hh,ss,cc,mm
def pack(row):return sum((int(v)>0)<<i for i,v in enumerate(row))
def crc(words):
 v=65535
 for addr,word in enumerate(words):
  for byt in (addr,word>>8,word&255):
   for k in range(7,-1,-1):v=((v<<1)&65535)^(0x1021 if (v>>15)^((byt>>k)&1) else 0)
 return v
metrics={}
for pf,name in enumerate(['normal','cautious']):
 mo=np.load(args.input/f'simple_model{pf}.npz');w,t,o,b=mo['w'],mo['t'],mo['o'],mo['b'];h,s,p,m=predict(bits,w,t,o,b)
 y=np.searchsorted([4,7,10] if pf==0 else [3,6,9],raw.sum(1),side='right')
 words=[pack(z) for z in w]+[pack(z) for z in o]+list(map(int,t))+[int(z)&65535 for z in b]+[pf+1,1]
 assert len(words)==42
 (root/'Models'/f'{name}.mem').write_text(''.join(f'{z:04x}\n' for z in words))
 model={'name':name,'model_id':pf+1,'minimum_margin':1,'hidden_weights':words[:16],'output_weights':words[16:20],'thresholds':list(map(int,t)),'biases':list(map(int,b)),'words':words,'crc16':crc(words),'training_seed':int(mo['seed']),'training':'Discrete quantization-aware coordinate search; fixed monotone +1 hidden projection; learned integer hidden thresholds and binary output weights/biases. No STE trainer in the delivered frozen model.'}
 (root/'Models'/f'{name}.json').write_text(json.dumps(model,indent=2)+'\n')
 mt={}
 for split in ['train','validation','test','all']:
  ids=mo[split] if split!='all' else np.arange(625);conf=np.zeros((4,4),int)
  for yy,pp in zip(y[ids],p[ids]):conf[yy,pp]+=1
  mt[split]={'count':len(ids),'correct':int((y[ids]==p[ids]).sum()),'accuracy':float((y[ids]==p[ids]).mean()),'confusion_matrix':conf.tolist(),'stop_to_continue':int(((y[ids]==3)&(p[ids]==0)).sum())}
 metrics[name]=mt
 (root/'Data'/f'{name}_splits.json').write_text(json.dumps({key:list(map(int,mo[key])) for key in ['train','validation','test']},indent=2))
 allx=(np.arange(65536)[:,None]>>np.arange(16)&1).astype(int);hh,ss,cc,mm=predict(allx,w,t,o,b)
 vals=[]
 for i in range(65536):
  val=int(cc[i])|(int(mm[i])<<2)
  for j in range(4):val|=(int(ss[i,j])&511)<<(11+9*j)
  val|=pack(hh[i])<<47;val|=i<<63
  vals.append(f'{val:020x}\n')
 (root/'Data'/f'{name}_golden.mem').write_text(''.join(vals))
 with (root/'Data'/f'{name}_hardware_cases.csv').open('w',newline='') as f:
  wr=csv.writer(f);wr.writerow(['raw_hex','hidden_hex','score0','score1','score2','score3','class','margin','oracle','critical'])
  # All 625 raw inputs; hardware script can run first 32 or all.
  # Put selected demo cases first, then seeded shuffled remaining inputs.
  demos=[(0,0,0,0),(1,1,1,0),(2,2,2,0),(3,3,2,0),(3,3,2,2),(4,2,0,0)]
  indices=[int(np.where((raw==z).all(1))[0][0]) for z in demos];indices+=list(np.random.default_rng(88).permutation([i for i in range(625) if i not in indices]))
  for i in indices:
   rw=sum(int(raw[i,j])<<(4*j) for j in range(4));wr.writerow([f'{rw:04x}',f'{pack(h[i]):04x}',*map(int,s[i]),int(p[i]),int(m[i]),int(y[i]),int(raw[i,0]==4 and (raw[i,1]>=2 or raw[i,2]>=2))])
print(json.dumps(metrics,indent=2));(root/'Models'/'metrics.json').write_text(json.dumps(metrics,indent=2)+'\n')
with (root/'Data'/'dataset.csv').open('w',newline='') as f:
 wr=csv.writer(f);wr.writerow(['index','d','v','a','u','severity_sum','normal','cautious','critical_guard'])
 for i,z in enumerate(raw):wr.writerow([i,*map(int,z),int(z.sum()),int(np.searchsorted([4,7,10],z.sum(),side='right')),int(np.searchsorted([3,6,9],z.sum(),side='right')),int(z[0]==4 and(z[1]>=2 or z[2]>=2))])
