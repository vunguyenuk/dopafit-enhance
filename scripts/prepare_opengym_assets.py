#!/usr/bin/env python3
"""Stage pinned upstream sources only. Never overwrite the muscular app bundle."""
from pathlib import Path
import hashlib,io,json,urllib.request,zipfile
ROOT=Path(__file__).resolve().parents[1]
m=json.loads((ROOT/'third_party/opengym3d/manifest.json').read_text())
url=f"https://raw.githubusercontent.com/AssiamahS/opengym3d/{m['commit']}/{m['archive']}"
raw=urllib.request.urlopen(url).read();assert hashlib.sha256(raw).hexdigest()==m['archiveSha256'],'Archive changed'
out=ROOT/'.build/opengym-original';out.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(io.BytesIO(raw)) as archive:
 license=archive.read('pack/LICENSE');assert b'MIT License' in license and b'SylvesterAssiamahGK' in license
 for name,digest in m['upstreamModels'].items():
  data=archive.read('pack/models/'+name);assert hashlib.sha256(data).hexdigest()==digest,name
  (out/name).write_bytes(data)
 (out/'OpenGym3D-MIT.txt').write_bytes(license)
(out/'source-pack.zip').write_bytes(raw)
print('Staged pinned upstream models under .build/opengym-original; muscular app assets unchanged.')
