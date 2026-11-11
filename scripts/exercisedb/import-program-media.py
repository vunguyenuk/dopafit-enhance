#!/usr/bin/env python3
"""Import six reviewed exact program variants from the official provider.
Reject misleading search metadata; do not map unmatched plank/bridge/squat.
Run after downloading the detail responses and GIFs listed in review evidence.
"""
from pathlib import Path
import json,shutil,subprocess,hashlib
root=Path(__file__).resolve().parents[2]
media=root/'DopafitRebuild/ExerciseMedia'
pins={'discovery-deadbug':'iny3m5y','discovery-crunch':'TFqbd8t','discovery-pushup':'I4hDWkc','discovery-wristcurl':'2dImyQ8','discovery-reversewristcurl':'BLCvwr2','discovery-farmercarry':'qPEzJjA'}
def read(p):return json.loads(p.read_text())
def write(p,x):p.write_text(json.dumps(x,ensure_ascii=False,indent=2)+'\n')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def probe(p):return json.loads(subprocess.check_output(['ffprobe','-v','error','-show_entries','stream=width,height,avg_frame_rate,nb_frames:format=duration','-of','json',str(p)]))
mapping=read(media/'exercisedb-mapping.json');videoPath=root/'rebuild/verification/exercise-video-qa.json';guidePath=root/'rebuild/verification/guide-upscale-qa.json'
video=read(videoPath);guide=read(guidePath);vs={r['id']:r for r in video['clips']};gs={r['id']:r for r in guide['clips']};review=[]
for key,ident in pins.items():
 row=read(root/'third_party/exercisedb/program-details'/f'{ident}.json')['data'];assert row['exerciseId']==ident and row['gifUrl']==f'https://static.exercisedb.dev/media/{ident}.gif'
 src=media/'gifs'/(ident+'.gif')
 assert src.is_file(),f'Missing pinned source GIF: {src}; restore from the documented provider URL, then verify review hash.'
 raw=src.read_bytes();assert raw[:6] in [b'GIF87a',b'GIF89a'] and raw[6:10]==bytes([180,0,180,0])
 mapping[key]=row
 for folder,filters,quality in [('videos','fps=30,scale=trunc(iw/2)*2:trunc(ih/2)*2','12'),('guide-previews','scale=720:720:flags=lanczos,unsharp=5:5:0.35:3:3:0,fps=30','16')]:
  out=media/folder/(ident+'.mp4')
  subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(src),'-vf',filters,'-an','-c:v','libx264','-preset','fast','-crf',quality,'-pix_fmt','yuv420p','-movflags','+faststart',str(out)],check=True)
  if folder=='videos':
   info=probe(out);s=info['streams'][0];vs[ident]={'id':ident,'sourceSHA256':sha(src),'videoSHA256':sha(out),'width':s['width'],'height':s['height'],'fps':s['avg_frame_rate'],'seconds':float(info['format']['duration']),'source':'GIF original180px poses. CFR duplicates frames, no invented anatomy.'}
  else:gs[ident]={'id':ident,'sourceSHA256':sha(src),'source':probe(src),'outputSHA256':sha(out),'outputPixels':[720,720],'outputBytes':out.stat().st_size,'nativeHD':False}
 pixels=subprocess.check_output(['ffmpeg','-hide_banner','-loglevel','error','-i',str(src),'-f','rawvideo','-pix_fmt','rgb24','-'])
 stride=180*180*3;distinct=len({hashlib.sha256(pixels[i:i+stride]).hexdigest() for i in range(0,len(pixels),stride)})
 assert distinct>1
 review.append({'localID':key,'providerID':ident,'name':row['name'],'sourceSHA256':sha(src),'decodedFrames':len(pixels)//stride,'distinctDecodedFrames':distinct,'visualReview':'Reviewed0.7s pose and official instructions/equipment. Exact movement; raw provider GIF retained.','nativeHD':False})
write(media/'exercisedb-mapping.json',mapping);video['clips']=list(vs.values());guide['clips']=list(gs.values());write(videoPath,video);write(guidePath,guide)
write(root/'third_party/exercisedb/program-mapping-review.json',{'date':'2026-11-10','pins':review,'rejected':{'u0cNiij':'Metadata says low glute bridge on floor but visible GIF is supported reverse plank; not mapped to lying glute bridge.','6YUfHPL':'Metadata says bodyweight squat but visible GIF is standing quadriceps stretch with foot on bench; not mapped.','plank':'Only weighted/twisting/other variants located; no exact unweighted forearm plank pinned.'},'fallback':'Two unmatched preset guides omit imagery and retain instructions/actions. Forearm Plank uses separately attributed real Pexels footage; no substitute ExerciseDB motion.','license':'ExerciseDB OSS non-commercial prototype with existing AscendAPI credit, source180px not nativeHD; no AI interpolation.'})
print(f'Imported {len(pins)} exact program motions; {len(mapping)} total mappings. Three unmatched program motions deliberately left static.')
