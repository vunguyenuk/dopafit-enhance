#!/usr/bin/env python3
"""Encode only visually reviewed demo clips. Preserve raw downloads and native timing."""
from pathlib import Path
import hashlib,json,re,subprocess,tempfile,shutil
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'DopafitRebuild/ExerciseMedia/zenith'
MAPPING=ROOT/'third_party/zenith-video/zenith-mapping.json'
REVIEW=ROOT/'third_party/zenith-video/mapping-review.json'
mapping=json.loads(MAPPING.read_text());review=json.loads(REVIEW.read_text())
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(MAPPING)==review['sourceMappingSHA256'],'Source mapping changed; re-review before encoding'
def probe(p):
 d=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(p)]))
 s=next(x for x in d['streams'] if x['codec_type']=='video')
 return {'width':s['width'],'height':s['height'],'fps':s['avg_frame_rate'],'duration':float(d['format']['duration']),'frames':int(s.get('nb_frames',0)),'audio':any(x['codec_type']=='audio' for x in d['streams'])}
def bbox(p,meta):
 # All decoded frames contribute to a cumulative box. Inverting white background makes cropdetect usable.
 result=subprocess.run(['ffmpeg','-hide_banner','-i',str(p),'-vf','scale=480:270,negate,cropdetect=limit=22:round=2:reset=0','-an','-f','null','-'],capture_output=True,text=True,check=True)
 boxes=[tuple(map(int,v)) for v in re.findall(r'crop=(\d+):(\d+):(\d+):(\d+)',result.stderr)]
 assert boxes,'No foreground box: '+str(p)
 x=min(b[2] for b in boxes);y=min(b[3] for b in boxes);right=max(b[2]+b[0] for b in boxes);bottom=max(b[3]+b[1] for b in boxes)
 sx=meta['width']/480;sy=meta['height']/270
 return [int(x*sx),int(y*sy),int((right-x)*sx),int((bottom-y)*sy)]
def encode(src,dst,box,size,margin,crf):
 x,y,w,h=box;side=int(max(max(w,h)*margin,520)/2+1)*2;cx=x+w/2;cy=y+h/2;pad=side
 crop=[side,side,int(cx+pad-side/2)//2*2,int(cy+pad-side/2)//2*2]
 vf=f'pad=iw+{2*pad}:ih+{2*pad}:{pad}:{pad}:color=white,crop={crop[0]}:{crop[1]}:{crop[2]}:{crop[3]},scale={size}:{size}:flags=lanczos,format=yuv420p'
 subprocess.run(['ffmpeg','-v','error','-y','-i',str(src),'-vf',vf,'-an','-c:v','libx264','-preset','veryfast','-crf',str(crf),'-fps_mode','passthrough','-movflags','+faststart',str(dst)],check=True)
 return {'file':dst.name,'sha256':sha(dst),'sourceSquarePixels':side,'outputPixels':[size,size],'spatialUpscale':side<size,'probe':probe(dst)}
work=ROOT/'.build/zenith-encode';work.mkdir(parents=True,exist_ok=True)
stage=Path(tempfile.mkdtemp(prefix='clips-',dir=work));clips={}
try:
 for app,decision in review['accepted'].items():
  row=mapping[decision['candidateKey']];entry={'sourceId':row['sourceId'],'sourceName':row['name'],'model':row['model'],'sourceURL':row['video'],'visualIdentity':decision['visualIdentity'],'steps':row['steps'],'formCues':row['formCues'],'commonMistakes':row['commonMistakes'],'breathing':row['breathing']}
  for female in [False,True]:
   if female and not row.get('femaleSlug'):continue
   src=ROOT/'third_party/zenith-video'/('raw-female' if female else 'raw')/((row['femaleSlug'] if female else row['slug'])+'.mp4')
   assert src.is_file() and src.stat().st_size>0,'Missing source: '+str(src)
   meta=probe(src);assert [meta['width'],meta['height']]==[1920,1080] and 0<meta['duration']<60
   box=bbox(src,meta);prefix=app+('-f' if female else '')
   outputs=[encode(src,stage/(prefix+'-guide.mp4'),box,720,1.12,20),encode(src,stage/(prefix+'-thumb.mp4'),box,240,1.08,24)]
   info={'sourceURL':row['femaleVideo'] if female else row['video'],'sourcePath':str(src.relative_to(ROOT)),'sha256Source':sha(src),'sourceProbe':meta,'bbox':box,'bboxMethod':'cumulative cropdetect over all decoded frames at480x270; white background threshold22; padding8/12percent','outputs':outputs}
   if female:entry['female']=info
   else:entry.update(info)
  clips[app]=entry;print('encoded',app,flush=True)
 manifest={'date':'2026-11-11','license':review['licenseStatus'],'repo':'https://github.com/buzops9/exercisedb','commit':'399a8af3bedd4f5959381ce4dedc28366db387d4','reviewPath':str(REVIEW.relative_to(ROOT)),'reviewSHA256':sha(REVIEW),'timing':'Original source timing retained; no optical-flow/AI frames.1920x1080 is source canvas, not proof of effective720px anatomy detail.','clips':clips}
 (stage/'zenith-manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
 # Archive previous derived outputs; retain raw source downloads and never erase them.
 if OUT.exists():
  archive=ROOT/'rebuild/archive/zenith-before-2026-11-11';archive.mkdir(parents=True,exist_ok=True)
  previous=Path(tempfile.mkdtemp(prefix='outputs-',dir=archive));OUT.rename(previous/'zenith')
 stage.rename(OUT)
 print(f'{len(clips)} exercise pins, {sum("female" in v for v in clips.values())} additional female variants; {sum(len(v["outputs"])+(len(v["female"]["outputs"]) if "female" in v else 0) for v in clips.values())} MP4 outputs')
except BaseException:
 shutil.rmtree(stage,ignore_errors=True);raise
