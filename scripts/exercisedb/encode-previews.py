#!/usr/bin/env python3
"""Native-video previews at source resolution, preserving original motion/timing.
30fps repeats original poses; never optical-flow/AI invented limb frames.
"""
from pathlib import Path
import subprocess,json,hashlib,concurrent.futures
root=Path(__file__).resolve().parents[2]
sources=sorted((root/'DopafitRebuild/ExerciseMedia/gifs').glob('*.gif'))
def encode(source):
 out=root/'DopafitRebuild/ExerciseMedia/videos'/(source.stem+'.mp4')
 subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(source),'-an','-vf','fps=30,scale=trunc(iw/2)*2:trunc(ih/2)*2','-c:v','libx264','-preset','fast','-crf','12','-pix_fmt','yuv420p','-movflags','+faststart',str(out)],check=True)
 probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(out)]));s=probe['streams'][0]
 return {'id':source.stem,'sourceSHA256':hashlib.sha256(source.read_bytes()).hexdigest(),'videoSHA256':hashlib.sha256(out.read_bytes()).hexdigest(),'width':s['width'],'height':s['height'],'fps':s['avg_frame_rate'],'seconds':float(probe['format']['duration']),'source':'GIF, original poses. CFR duplicates frames, no interpolated anatomy.'}
results=list(concurrent.futures.ThreadPoolExecutor(max_workers=3).map(encode,sources))
(root/'rebuild/verification/exercise-video-qa.json').write_text(json.dumps({'date':'2026-11-10','clips':results,'limitation':'Free upstream GIFs are 180px; MP4 removes main-thread GIF decoding but cannot create missing resolution or source motion frames.'},indent=2)+'\n')
print('Encoded',len(results),'local native previews')
