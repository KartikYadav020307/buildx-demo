# OPTIONAL reproduction: Python + numpy + scikit-learn. Not required for Vivado.
# Run from anywhere; outputs go in Training_Reproduction, leaving the shipped models unchanged.
from pathlib import Path
import argparse
parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,default=Path(__file__).resolve().parents[1]/'Training_Reproduction');args=parser.parse_args()
args.output.mkdir(parents=True,exist_ok=True)
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import numpy as np,itertools
from sklearn.model_selection import train_test_split
Xraw=np.array(list(itertools.product(range(5),repeat=4)));X=(Xraw[:,:,None]>np.arange(4)).reshape(-1,16).astype(int)*2-1
r=Xraw.sum(1)
# Frozen feature extractor: monotone binary projection with 16 trainable thresholds.
# Binary output weights/bias and thresholds fit by discrete quantization-aware search.
def loss(s,y):
 z=s/2;z-=z.max(1,keepdims=True);return (np.log(np.exp(z).sum(1))-z[np.arange(len(y)),y]).mean()
for pf in range(2):
 y=np.searchsorted([4,7,10] if pf==0 else [3,6,9],r,side='right')
 tr,rem=train_test_split(np.arange(625),train_size=375,stratify=y,random_state=500+pf);va,te=train_test_split(rem,test_size=125,stratify=y[rem],random_state=700+pf)
 best=(-1,1e9)
 for seed in range(12):
  rng=np.random.default_rng(2000+pf*100+seed);t=np.arange(1,17);w=np.ones((16,16),int);o=rng.choice([-1,1],(4,16));b=np.zeros(4,int)
  h=((X[tr]@w.T+16)//2>=t).astype(int)*2-1;s=h@o.T+b;yt=y[tr]
  for ep in range(400):
   changed=False
   for j in rng.permutation(4):
    for k in rng.permutation(16):
     ss=s.copy();ss[:,j]-=2*h[:,k]*o[j,k]
     if loss(ss,yt)<loss(s,yt)-1e-9:o[j,k]*=-1;s=ss;changed=True
    ss=np.tile(s,(65,1,1));bs=np.arange(-32,33);ss[:,:,j]+=bs[:,None]-b[j]
    zz=ss/2;zz-=zz.max(2,keepdims=True);ls=(np.log(np.exp(zz).sum(2))-zz[:,np.arange(len(tr)),yt]).mean(1);idx=int(np.argmin(ls))
    if ls[idx]<loss(s,yt)-1e-9:b[j]=bs[idx];s=ss[idx];changed=True
   for j in rng.permutation(16):
    hs=(((X[tr]@w[j]+16)//2)[None,:]>=np.arange(18)[:,None]).astype(int)*2-1
    ss=s[None,:,:]+(hs-h[:,j])[:,:,None]*o[:,j][None,None,:]
    zz=ss/2;zz-=zz.max(2,keepdims=True);ls=(np.log(np.exp(zz).sum(2))-zz[:,np.arange(len(tr)),yt]).mean(1);idx=int(np.argmin(ls))
    if ls[idx]<loss(s,yt)-1e-9:t[j]=idx;h[:,j]=hs[idx];s=ss[idx];changed=True
   hf=((X@w.T+16)//2>=t).astype(int)*2-1;sc=hf@o.T+b;pred=3-np.argmax(sc[:,::-1],1);vaacc=(pred[va]==y[va]).mean();vl=loss(sc[va],y[va]);metric=(vaacc,-vl)
   if metric>(best[0],-best[1]):
    best=(vaacc,vl);np.savez(args.output/f'simple_model{pf}.npz',w=w,t=t,o=o,b=b,train=tr,validation=va,test=te,seed=2000+pf*100+seed)
    print(pf,seed,ep,'val',vaacc,'train',(pred[tr]==yt).mean(),flush=True)
   if not changed:
    j=rng.integers(4);k=rng.integers(16);o[j,k]*=-1;s=h@o.T+b
 print('FROZEN',pf,best,flush=True)

print("Frozen reproduction exports:",args.output)
