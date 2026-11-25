"""Reference-audited gift motion. Existing Dopafit model/materials, real 3D poses."""
import bpy, math, json, hashlib
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'output/blender-pro-gift-motion';OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'output/blender-pro-gift/pro-gift.blend'))
s=bpy.context.scene
s.render.engine='CYCLES';s.cycles.samples=12;s.cycles.use_denoising=True
s.render.resolution_x=512;s.render.resolution_y=512;s.render.resolution_percentage=100
s.render.film_transparent=True;s.render.image_settings.color_mode='RGBA'
s.render.image_settings.file_format='PNG';s.render.image_settings.color_depth='8'
# Keep the existing mesh, satin ribbon, lights and three-quarter camera.
root=bpy.data.objects.new('Gift motion pivot',None);s.collection.objects.link(root)
lid=bpy.data.objects.new('Lid flight pivot',None);s.collection.objects.link(lid);lid.location=(0,0,1.58);lid.parent=root
lid_names=('Bevelled lid','Lid ribbon','Lid side','Bow')
for o in list(s.objects):
 if o.type!='MESH':continue
 is_lid=o.name.startswith(lid_names);o.parent=lid if is_lid else root
 if is_lid:o.location.z-=1.58
# A thin luminous seam lights the inside only after the explicit open.
m=bpy.data.materials.new('Warm lime interior glow');m.use_nodes=True
bs=m.node_tree.nodes.get('Principled BSDF');bs.inputs['Base Color'].default_value=(.7,1,.15,1);bs.inputs['Emission Color'].default_value=(.8,1,.25,1);bs.inputs['Emission Strength'].default_value=3
bpy.ops.mesh.primitive_plane_add(size=1.48,location=(0,0,1.46));core=bpy.context.object;core.name='Interior light';core.data.materials.append(m);core.parent=root
bpy.ops.object.light_add(type='POINT',location=(0,0,1.6));glow=bpy.context.object;glow.name='Unbox light';glow.data.color=(.78,1,.35);glow.data.shadow_soft_size=.5;glow.parent=root
cam=s.camera;cam.data.ortho_scale=4.1
# 24 fps matching the reference cadence. Grounded squash, overshoot,
# two irregular tremors, rightward lift and a stronger forward swell.
keys=[(0,(1,1,1),0,0,0),(0.18,(1.08,1.08,.78),0,0,0),
 (.34,(.97,.97,1.07),0,0,0),(.5,(1,1,.98),0,0,0),
 (.66,(1,1,1.02),0,-1.8,0),(.76,(1,1,.98),0,1.6,0),
 (.89,(1,1,1.015),0,-1.2,0),(1.03,(1,1,.99),0,.8,0),
 (1.18,(1,1,1),.04,0,0),(1.37,(1.02,1.02,1.025),.14,-7,4),
 (1.58,(1.09,1.09,1.09),.16,-8,6),(1.73,(1.16,1.16,1.16),.08,-5,3),
 (1.87,(1.02,1.02,.84),0,0,0),(2,(1,1,1),0,0,0)]
def key(t,scale,z,tilt,yaw):
 f=t*24;root.scale=scale;root.location=(0,0,z);root.rotation_euler=(0,math.radians(tilt),math.radians(yaw))
 for p in ['scale','location','rotation_euler']:root.keyframe_insert(data_path=p,frame=f)
for k in keys:key(*k)
records=[]
def render(kind,count):
 for f in range(count):
  s.frame_set(f);s.render.filepath=str(OUT/f'gift-{kind}-{f:02d}.png');bpy.ops.render.render(write_still=True)
  p=Path(s.render.filepath);records.append({'name':p.name,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
core.hide_render=True;glow.data.energy=0
render('idle',48)
# Triggered segment follows the reference rapid thrust→bright fan. No idle lid lift.
root.animation_data_clear();lid.animation_data_clear()
root.scale=(1,1,1);root.location=(0,0,0);root.rotation_euler=(0,0,0)
for t,scale,z,tilt,yaw in [(0,(1,1,1),0,0,0),(.12,(1.1,1.1,.78),0,-3,0),(.25,(1.14,1.14,1.12),.12,-8,4),(.42,(1.22,1.22,1.18),.05,-6,3),(.83,(1.22,1.22,1.18),0,-4,2)]:key(t,scale,z,tilt,yaw)
for t,loc,rot in [(0,(0,0,1.58),(0,0,0)),(.15,(0,0,1.58),(0,0,0)),(.28,(-.04,.03,1.88),(-8,-5,-3)),(.42,(-.23,.13,2.64),(-24,-12,-10)),(.64,(-.30,.12,2.55),(-30,-12,-14)),(.83,(-.32,.15,2.58),(-32,-13,-16))]:
 lid.location=loc;lid.rotation_euler=tuple(math.radians(x) for x in rot)
 for p in ['location','rotation_euler']:lid.keyframe_insert(data_path=p,frame=t*24)
core.hide_render=False
for t,energy in [(0,0),(.16,0),(.25,45),(.4,110),(.83,75)]:
 glow.data.energy=energy;glow.data.keyframe_insert(data_path='energy',frame=t*24)
# The luminous surface emerges at separation, without leaking through the closed lid.
for f,hidden in [(0,True),(4,True),(5,False)]:core.hide_render=hidden;core.keyframe_insert(data_path='hide_render',frame=f)
# Camera pulls back just enough for lid clearance; the reference's thrust remains in the model pose.
for f,scale in [(0,4.1),(5,4.1),(11,5.65),(20,5.65)]:cam.data.ortho_scale=scale;cam.data.keyframe_insert(data_path='ortho_scale',frame=f)
render('open',21)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'pro-gift-motion.blend'))
(OUT/'manifest.json').write_text(json.dumps({'reference':'rebuild/verification/v2-gift-reference-audit-2026-11-25/reference.mp4','referenceSha256':'113072a1aa19211da2cbcda1725f2b93013a4faf3b4aeed19f35138b06900fdb','sourceScene':'output/blender-pro-gift/pro-gift.blend','generator':'scripts/blender/build-pro-gift-motion.py','fps':24,'idleFrames':48,'openFrames':21,'canvas':[512,512],'render':'Cycles12+denoise,RGBA','adaptation':'Existing graphite/lime gift; reference squash/tremor/tilt/thrust/lid burst. No reference headphone or red palette imported. Loop turnaround authored to avoid auto-unbox.','frames':records},indent=2))
