"""Retarget the pinned OpenGym3D v1 rotation clips to the baked muscular rig.
Translations stay on the new rest skeleton; old limb lengths are never copied.
"""
import bpy,json,sys,math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];out=ROOT/'.build/opengym-muscular'
original=ROOT/'.build/opengym-original';original.mkdir(exist_ok=True)
for name in ['bicep_curl','romanian_deadlift','good_morning']:
 assert (original/(name+'.glb')).exists(),'Run python3 scripts/prepare_opengym_assets.py first'
source_blend=ROOT/'third_party/opengym3d/workfiles/muscular_source.blend'
if (out/'muscular_source.blend').exists():source_blend=out/'muscular_source.blend'
out.mkdir(exist_ok=True)
report=[]
for name in ['bicep_curl','romanian_deadlift','good_morning']:
 bpy.ops.wm.open_mainfile(filepath=str(source_blend))
 target=bpy.data.objects['OpenGymMuscularRig'];mesh=bpy.data.objects['OpenGymMuscularHuman'];before=set(bpy.data.objects)
 bpy.ops.import_scene.gltf(filepath=str(original/(name+'.glb')))
 imported=[obj for obj in bpy.data.objects if obj not in before]
 source=next(obj for obj in imported if obj.type=='ARMATURE')
 action=source.animation_data.action
 first,last=[int(v) for v in action.frame_range];bpy.context.scene.frame_start=first;bpy.context.scene.frame_end=last
 scale=mesh.dimensions.z/max(0.01,next(obj for obj in imported if obj.type=='MESH').dimensions.z)
 for bone in target.pose.bones:bone.rotation_mode='QUATERNION';bone.location=(0,0,0);bone.scale=(1,1,1)
 for frame in range(first,last+1):
  bpy.context.scene.frame_set(frame)
  for bone in target.pose.bones:
   if bone.name not in source.pose.bones:continue
   old=source.pose.bones[bone.name];bone.rotation_quaternion=old.matrix_basis.to_quaternion()
   bone.keyframe_insert(data_path='rotation_quaternion',frame=frame)
   if bone.name=='root':bone.location=old.location*scale;bone.keyframe_insert(data_path='location',frame=frame)
  bpy.context.view_layer.update()
  assert all(math.isfinite(v) for bone in target.pose.bones for row in bone.matrix for v in row)
 for obj in imported:bpy.data.objects.remove(obj,do_unlink=True)
 bpy.ops.object.select_all(action='DESELECT');mesh.select_set(True);target.select_set(True);bpy.context.view_layer.objects.active=target
 bpy.context.scene.frame_set(first)
 bpy.ops.export_scene.gltf(filepath=str(out/(name+'.glb')),export_format='GLB',use_selection=True,export_animations=True,export_force_sampling=True,export_morph=False,export_apply=False)
 report.append({'id':name,'frames':[first,last],'bones':len(target.pose.bones),'translations':'new skeleton except scaled root','finiteTransforms':True})
(out/'retarget-report.json').write_text(json.dumps(report,indent=2))
print('RETARGET_DONE',report,flush=True)
