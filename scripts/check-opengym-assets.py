#!/usr/bin/env python3
"""Validate offline GLB integrity, skinned geometry and finite animation data."""
from pathlib import Path
import hashlib,json,struct,math
root=Path(__file__).resolve().parents[1];bundle=root/'DopafitRebuild/OpenGym3D'
m=json.loads((root/'third_party/opengym3d/manifest.json').read_text())
for name,digest in m['models'].items():
 data=(bundle/'models'/name).read_bytes();assert hashlib.sha256(data).hexdigest()==digest,name
 magic,version,total=struct.unpack_from('<III',data);assert magic==0x46546c67 and version==2 and total==len(data)
 size=struct.unpack_from('<I',data,12)[0];g=json.loads(data[20:20+size]);bin_start=28+size
 assert len(g.get('animations',[]))==(0 if name==m['staticModel'] else 1),name+' must have exactly one synchronized exercise clip'
 names=g.get('extras',{}).get('openGymMuscleNames',[])
 assert len(names)==16 and len(set(names))==16,name+' muscle schema'
 for view in g['bufferViews']:assert view.get('byteOffset',0)+view['byteLength']<=g['buffers'][0]['byteLength']
 def values(index):
  a=g['accessors'][index];v=g['bufferViews'][a['bufferView']]
  count={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4,'MAT4':16}[a['type']]
  fmt,width={5121:('B',1),5123:('H',2),5125:('I',4),5126:('f',4)}[a['componentType']]
  offset=bin_start+v.get('byteOffset',0)+a.get('byteOffset',0);stride=v.get('byteStride',width*count)
  assert offset+(a['count']-1)*stride+width*count<=len(data),name
  return [struct.unpack_from('<'+fmt*count,data,offset+i*stride) for i in range(a['count'])]
 skinned=0;props=0
 for node in g['nodes']:
  if 'mesh' not in node:continue
  is_body='skin' in node
  skinned+=int(is_body);props+=int(not is_body)
  for primitive in g['meshes'][node['mesh']]['primitives']:
   attrs=primitive['attributes'];assert all(k in attrs for k in ['POSITION','NORMAL'])
   p=values(attrs['POSITION']);normals=values(attrs['NORMAL'])
   assert p and len(normals)==len(p) and all(math.isfinite(x) for row in p+normals for x in row),name
   assert all(i[0]<len(p) for i in values(primitive['indices'])),name
   if not is_body:
    assert not any(k.startswith('_MUSCLE_') for k in attrs),name+' prop must not glow'
    continue
   assert all(k in attrs for k in ['JOINTS_0','WEIGHTS_0'])
   weights=values(attrs['WEIGHTS_0']);joints=values(attrs['JOINTS_0'])
   assert len(weights)==len(joints)==len(p),name
   assert all(0.98<=sum(w)<=1.02 for w in weights),name
   assert all(int(j)<len(g['skins'][node['skin']]['joints']) for row in joints for j in row),name
   masks=[]
   for slot in range(4):
    assert '_MUSCLE_'+str(slot) in attrs,name
    mask=values(attrs['_MUSCLE_'+str(slot)])
    assert len(mask)==len(p) and all(math.isfinite(x) and 0<=x<=1 for row in mask for x in row),name
    masks.append(mask)
   assert all(any(masks[k//4][i][k%4]>.15 for i in range(len(p))) for k in range(16)),name+' empty muscle region'
 assert skinned>0 and (name==m['staticModel'] or props>0),name
 for animation in g.get('animations',[]):
  for sampler in animation['samplers']:
   assert all(math.isfinite(x) for row in values(sampler['output']) for x in row),name
   times=[v[0] for v in values(sampler['input'])];assert times==sorted(times),name
for id,model in m['exerciseMapping'].items():assert model+'.glb' in m['models'],id
assert set(p.name for p in (bundle/'models').glob('*.glb'))==set(m['models'])
for license in ['OpenGym3D-MIT.txt','Three-MIT.txt']:assert 'MIT License' in (bundle/'licenses'/license).read_text()
assert 'CC0' in (bundle/'licenses/MakeHuman-CC0.txt').read_text()
assert (bundle/'viewer.js').stat().st_size>100000
assert 'https://' not in (bundle/'index.html').read_text(),'Runtime must remain local'
qa=json.loads((root/'third_party/opengym3d/geometry-qa.json').read_text());assert len(qa)==4 and all(r['pass'] for r in qa)
for r in qa:
 assert r['sha256']==m['models'][r['id']+'.glb'],r['id']
 assert r['framesChecked']>=60 if r['id']!='muscular_body' else r['framesChecked']==1
 if r['id']!='muscular_body':
  assert r['maxFootDriftMeters']<=.002 and r['maxGripDistanceMeters']<=.025 and r['lowestBodyZMeters']>=-.015,r['id']
  assert r['loopSeamMeters']<=.005 and r['maxFrameStepMeters']<=.10,r['id']+' motion continuity'
  assert r['gripReference'].startswith('MCP palm center') and r['maxFingertipToHandleAxisMeters']<=.06,r['id']+' actual hand grip'
print('Asset integrity passed: 16 soft muscle masks; 3 single synchronized clips with implements; finite geometry, planted feet, grip, hashes, offline viewer and license notices.')
