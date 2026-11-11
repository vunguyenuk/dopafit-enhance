#!/usr/bin/env python3
"""Protect exact exercise identity and honest resolution provenance before builds."""
from pathlib import Path
import hashlib,json,re,struct
root=Path(__file__).resolve().parents[1]
media=root/'DopafitRebuild/ExerciseMedia'
load=lambda p:json.loads(p.read_text())
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
mapping=load(media/'exercisedb-mapping.json')
video={r['id']:r for r in load(root/'rebuild/verification/exercise-video-qa.json')['clips']}
guide={r['id']:r for r in load(root/'rebuild/verification/guide-upscale-qa.json')['clips']}
ids=set()
for key,row in mapping.items():
 ident=row['exerciseId'];assert re.fullmatch('[A-Za-z0-9]+',ident),key
 assert row['gifUrl']=='https://static.exercisedb.dev/media/'+ident+'.gif',key
 ids.add(ident)
 source=media/'gifs'/(ident+'.gif');raw=source.read_bytes()
 assert raw[:6] in [b'GIF87a',b'GIF89a'] and struct.unpack('<HH',raw[6:10])==(180,180),key
 digest=sha(source);assert video[ident]['sourceSHA256']==digest and guide[ident]['sourceSHA256']==digest,key
 for folder,report,hashkey in [('videos',video,'videoSHA256'),('guide-previews',guide,'outputSHA256')]:
  path=media/folder/(ident+'.mp4');assert path.read_bytes()[4:8]==b'ftyp' and sha(path)==report[ident][hashkey],(key,folder)
 assert guide[ident]['nativeHD'] is False and guide[ident]['outputPixels']==[720,720],key
assert ids==set(video)==set(guide),'orphaned/missing media QA'
stock=load(root/'third_party/stock-motion/manifest.json')
assert stock['localID']=='discovery-plank' and stock['nativeHD'] is True
assert sha(root/stock['sourcePath'])==stock['sourceSHA256']
for item in stock['outputs']:
 path=root/item['path'];assert sha(path)==item['sha256'] and path.read_bytes()[4:8]==b'ftyp'
 assert float(item['probe']['format']['duration'])==4
assert stock['cropPixels']==[2160,2160,0,1300] and stock['clipStartSeconds']==1
photos=load(root/'third_party/challenge-photos/manifest.json')
for row in photos:
 path=root/'DopafitRebuild/Assets.xcassets'/(row['asset']+'.imageset')/'photo.jpg'
 assert sha(path)==row['sha256'],row['asset']
 if row.get('sourceVideo'):
  source=root/row['sourceVideo']['path'];assert sha(source)==row['sourceVideo']['sha256'],row['asset']
# Supplemental demo clips have a separate reviewed allowlist and full source/output hashes.
zpath=media/'zenith/zenith-manifest.json'
zenith=load(zpath);review=load(root/zenith['reviewPath'])
assert sha(root/zenith['reviewPath'])==zenith['reviewSHA256'],'Zenith review drift'
assert sha(root/'third_party/zenith-video/zenith-mapping.json')==review['sourceMappingSHA256']
assert set(zenith['clips'])==set(review['accepted']) and not set(review['rejected']) & set(zenith['clips'])
assert 'dumbbell-row' in zenith['clips'] and 'bent-over-dumbbell-row' not in zenith['clips']
expected=set();zvariants=0
for key,row in zenith['clips'].items():
 for variant in [row]+([row['female']] if 'female' in row else []):
  zvariants+=1
  assert sha(root/variant['sourcePath'])==variant['sha256Source'],key
  assert [variant['sourceProbe']['width'],variant['sourceProbe']['height']]==[1920,1080]
  assert len(variant['outputs'])==2
  for item in variant['outputs']:
   path=media/'zenith'/item['file'];expected.add(item['file'])
   assert sha(path)==item['sha256'] and path.read_bytes()[4:8]==b'ftyp',item['file']
   assert item['probe']['width']==item['probe']['height']==item['outputPixels'][0]
   assert item['sourceSquarePixels']>=max(variant['bbox'][2:])
   assert not item['probe']['audio'] and item['probe']['frames']>1
   assert abs(item['probe']['duration']-variant['sourceProbe']['duration'])<0.1
assert expected=={p.name for p in (media/'zenith').glob('*.mp4')},'Orphaned/rejected Zenith output'
print(f'Exercise media integrity passed: {len(mapping)} pinned variants, source180px hashes, small MP4s, guide-only720px upscales (not nativeHD), {len(photos)} attributed photo hashes +1 separately licensed real Plank video (2 encodes); Zenith {len(zenith['clips'])} reviewed pins/{zvariants} motion variants/{len(expected)} output hashes (local demo, media rights unresolved).')
