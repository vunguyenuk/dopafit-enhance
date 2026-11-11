#!/usr/bin/env python3
"""Integrity gate for the pinned local Form prototype; never a form certification."""
import hashlib,json,struct,math
from pathlib import Path
root=Path(__file__).resolve().parent.parent
manifest=json.loads((root/'third_party/exercise-animations/manifest.json').read_text())
for item in manifest['bundledFiles']:
 p=root/item['path'];assert p.is_file(),f'Missing {p}'
 assert hashlib.sha256(p.read_bytes()).hexdigest()==item['sha256'],f'Changed Form resource without manifest: {p}'
up=root/'third_party/exercise-animations/upstream'
for name in ['character/generated/figure','highlighting/generated/atlas']:
 meta=json.loads((up/f'src/{name}.json').read_text());data=(up/f'src/{name}.bin').read_bytes()
 assert len(data)==meta['bytes'] and hashlib.sha256(data).hexdigest()==meta['sha256']
raw=(root/'DopafitRebuild/Form3D/neutral.glb').read_bytes();magic,ver,length=struct.unpack_from('<III',raw)
assert magic==0x46546c67 and ver==2 and length==len(raw)
jslen=struct.unpack_from('<I',raw,12)[0];g=json.loads(raw[20:20+jslen]);start=28+jslen
assert len(g['extras']['openGymMuscleNames'])==16
attrs=g['meshes'][0]['primitives'][0]['attributes']
counts=[]
for key,index in attrs.items():
 a=g['accessors'][index];v=g['bufferViews'][a['bufferView']];components={'VEC3':3,'VEC4':4}[a['type']]
 values=struct.unpack_from('<'+'f'*(a['count']*components),raw,start+v['byteOffset'])
 assert all(math.isfinite(x) for x in values),f'Non-finite {key}'
 if key.startswith('_MUSCLE_'):
  assert all(0<=x<=1 for x in values)
  counts.extend(sum(values[i]>0 for i in range(k,len(values),4)) for k in range(4))
assert all(counts),f'Empty native region: {counts}'
qa=json.loads((root/'rebuild/verification/form-motion-qa.json').read_text())
assert len(qa['results'])==8 and all(r['samples']==33 and not r['failures'] for r in qa['results'])
s=(root/'DopafitRebuild/OpenGymBody.swift').read_text()
assert '"dumbbell-row":"form:' not in s and '"arnold":"form:' not in s and '"goodmorning":"form:' not in s,'Incorrect motion variation alias'
html=(root/'DopafitRebuild/Form3D/index.html').read_text();assert 'connect-src data:' in html
assert (root/'DopafitRebuild/Form3D/licenses/INTEGRATION-NOTICE.txt').is_file()
print('Form integrity passed: pinned resource hashes, finite neutral mesh, 16 nonempty masks, 8 motions ×33 CPU poses, offline CSP, variation identities and provenance notice. Project-code release license remains unresolved.')
