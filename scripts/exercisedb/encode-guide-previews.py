#!/usr/bin/env python3
"""Guide-only spatial interpolation. Original poses/timing, no AI/optical flow.
Output720px is an upscale of180px input, never a claim of native HD.
List thumbnails continue using their small original-resolution MP4s.
"""
from pathlib import Path
import concurrent.futures,hashlib,json,subprocess,shutil
root=Path(__file__).resolve().parents[2]
ffmpeg=shutil.which('ffmpeg') or '/opt/homebrew/bin/ffmpeg'
ffprobe=shutil.which('ffprobe') or '/opt/homebrew/bin/ffprobe'
sources=sorted((root/'DopafitRebuild/ExerciseMedia/gifs').glob('*.gif'))
outdir=root/'DopafitRebuild/ExerciseMedia/guide-previews';outdir.mkdir(exist_ok=True)
def encode(src):
 out=outdir/(src.stem+'.mp4')
 subprocess.run([ffmpeg,'-hide_banner','-loglevel','error','-y','-i',str(src),'-vf','scale=720:720:flags=lanczos,unsharp=5:5:0.35:3:3:0,fps=30','-an','-c:v','libx264','-preset','fast','-crf','16','-pix_fmt','yuv420p','-movflags','+faststart',str(out)],check=True)
 probe=json.loads(subprocess.check_output([ffprobe,'-v','error','-show_entries','stream=width,height,avg_frame_rate,nb_frames:format=duration','-of','json',str(src)]))
 return {'id':src.stem,'sourceSHA256':hashlib.sha256(src.read_bytes()).hexdigest(),'source':probe,'outputSHA256':hashlib.sha256(out.read_bytes()).hexdigest(),'outputPixels':[720,720],'outputBytes':out.stat().st_size,'nativeHD':False}
rows=list(concurrent.futures.ThreadPoolExecutor(max_workers=3).map(encode,sources))
(root/'rebuild/verification/guide-upscale-qa.json').write_text(json.dumps({'date':'2026-11-10','filter':'Lanczos4x + unsharp0.35. No temporal interpolation.','limitation':'Sharper edge presentation only; cannot recover original180px detail. Output720 is not native HD.','clips':rows},indent=2)+'\n')
print(f'{len(rows)} guide-only spatial upscales; {sum(x["outputBytes"] for x in rows)} bytes. Native-HD claim:false')
