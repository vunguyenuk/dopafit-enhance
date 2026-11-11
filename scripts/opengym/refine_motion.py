"""Repair the local OpenGym-derived model in a candidate folder, never in-place.
Blender4.0+; measured foot anchors, anatomical arm IK, closed grips and implements.
Procedural dumbbell/barbell shapes follow the MIT upstream construction approach.
"""
import bpy,bmesh,math,json,sys
from mathutils import Vector,Quaternion,Matrix
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'.build/opengym-refined';OUT.mkdir(exist_ok=True)
CLIPS=sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else ['muscular_body','bicep_curl','romanian_deadlift','good_morning']
REPORT=json.loads((OUT/'refinement-report.json').read_text()) if (OUT/'refinement-report.json').exists() else []
REPORT=[r for r in REPORT if r['id'] not in CLIPS]
def aim(rig,name,direction):
 b=rig.pose.bones[name];delta=(b.tail-b.head).normalized().rotation_difference(direction.normalized());m=(delta@b.matrix.to_quaternion()).to_matrix().to_4x4();m.translation=b.head;b.matrix=m;bpy.context.view_layer.update()
def global_rotation(rig,name,q):
 b=rig.pose.bones[name];m=q.to_matrix().to_4x4();m.translation=b.head;b.matrix=m;bpy.context.view_layer.update()
def solve_chain(rig,upper,lower,target,pole):
 hip=rig.pose.bones[upper[0]].head.copy();l1=sum(rig.data.bones[n].length for n in upper);l2=sum(rig.data.bones[n].length for n in lower)
 axis=target-hip;d=axis.length;axis.normalize();distance=min(l1+l2-1e-5,max(abs(l1-l2)+1e-5,d));a=(l1*l1-l2*l2+distance*distance)/(2*distance);height=math.sqrt(max(0,l1*l1-a*a))
 outward=pole-axis*pole.dot(axis)
 if outward.length<1e-5:outward=Vector((1,0,0)).cross(axis)
 knee=hip+axis*a+outward.normalized()*height
 for n in upper:aim(rig,n,knee-hip)
 for n in lower:aim(rig,n,target-knee)
 return (rig.pose.bones[lower[-1]].tail-target).length

def smooth_surface(mesh):
 # Weld exporter seam duplicates before smoothing; retain the rig's deform layer.
 bm=bmesh.new();bm.from_mesh(mesh.data);bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=1e-6);bm.to_mesh(mesh.data);bm.free();mesh.data.update()
 vg=mesh.vertex_groups.new(name='SurfaceRefinement')
 for v in mesh.data.vertices:
  x,y,z=v.co
  # Refine the visible pec contour and shoulder transition without reshaping
  # joints, eyes, hands, groin or legs. These are art corrections, not anatomy data.
  band=max(0,min(1,(z-1.18)/.07,(1.47-z)/.07));side=max(0,min(1,(abs(x)-.015)/.05,(.31-abs(x))/.07));front=max(0,min(1,(-y-.055)/.04));weight=band*side*front
  if weight>0:vg.add([v.index],weight,'REPLACE')
 mod=mesh.modifiers.new('Pectoral surface continuity','SMOOTH');mod.vertex_group=vg.name;mod.factor=.45;mod.iterations=5
 bpy.context.view_layer.objects.active=mesh
 while mesh.modifiers[0]!=mod:bpy.ops.object.modifier_move_up(modifier=mod.name)
 bpy.ops.object.modifier_apply(modifier=mod.name)
 mesh.vertex_groups.remove(mesh.vertex_groups['SurfaceRefinement'])
 for p in mesh.data.polygons:p.use_smooth=True
 # Imported loop normals must follow the repaired surface rather than the old
 # shape; otherwise a smooth mesh still renders with false grooves.
 if mesh.data.has_custom_normals:
  bpy.context.view_layer.objects.active=mesh
  try:bpy.ops.mesh.customdata_custom_splitnormals_clear()
  except RuntimeError:pass

def material(name,color,metal=0,rough=.65):
 m=bpy.data.materials.new(name);m.use_nodes=True;b=m.node_tree.nodes.get('Principled BSDF');b.inputs['Base Color'].default_value=(*color,1);b.inputs['Metallic'].default_value=metal;b.inputs['Roughness'].default_value=rough;return m

def cylinder(name,radius,length,x,mat):
 bpy.ops.mesh.primitive_cylinder_add(vertices=24,radius=radius,depth=length,rotation=(0,math.pi/2,0),location=(x,0,0));o=bpy.context.object;o.name=name;bpy.ops.object.transform_apply(location=False,rotation=True,scale=False);o.data.materials.append(mat);return o

def implement(name,kind):
 steel=material('Steel',(.22,.25,.28),.75,.3);iron=material('Iron',(.055,.06,.07),.4,.55)
 if kind=='dumbbell':spec=[(.014,.16,0,steel),(.057,.055,-.10,iron),(.057,.055,.10,iron)]
 else:spec=[(.014,1.5,0,steel),(.16,.055,-.64,iron),(.16,.055,.64,iron)]
 parts=[cylinder(name+str(i),r,l,x,m) for i,(r,l,x,m) in enumerate(spec)];bpy.ops.object.select_all(action='DESELECT')
 for o in parts:o.select_set(True)
 bpy.context.view_layer.objects.active=parts[0];bpy.ops.object.join();o=bpy.context.object;o.name=name;return o

def palm_center(rig,side):
 # The wrist bone tail is the HEEL of the palm, not the grip point. Use
 # metacarpophalangeal heads so implements sit inside the actual fingers.
 points=[rig.pose.bones[f'finger{i}-1{side}'].head for i in range(2,6)]
 center=sum(points,Vector())/4
 fore=(rig.pose.bones['wrist'+side].tail-rig.pose.bones['wrist'+side].head).normalized()
 across=rig.pose.bones['finger2-1'+side].head-rig.pose.bones['finger5-1'+side].head
 normal=(across.cross(fore) if side=='.L' else fore.cross(across)).normalized()
 return center+normal*.012

def orient_palm(rig,side,desired):
 wrist=rig.pose.bones['wrist'+side];fore=(wrist.tail-wrist.head).normalized()
 across=rig.pose.bones['finger2-1'+side].head-rig.pose.bones['finger5-1'+side].head
 normal=(across.cross(fore) if side=='.L' else fore.cross(across)).normalized()
 desired=desired-fore*desired.dot(fore)
 if desired.length<1e-5:return
 desired.normalize();angle=math.atan2(fore.dot(normal.cross(desired)),normal.dot(desired))
 global_rotation(rig,'wrist'+side,Quaternion(fore,angle)@wrist.matrix.to_quaternion())

def close_grip(rig,side,center,axis):
 # Parent-first bends use the measured direction that brings the fingertip
 # toward the implement. This prevents left/right sign assumptions.
 for finger in range(1,6):
  sign_key=f'grip-finger{finger}{side}'
  root=rig.pose.bones.get(f'finger{finger}-1{side}')
  if root and sign_key not in grip_signs:
   direction=root.tail-root.head;grip_signs[sign_key]=min([-1,1],key=lambda sign:(root.head+Quaternion(axis,math.radians(sign*60))@direction-center).length)
  for seg,deg in [(1,45 if finger==1 else 75),(2,60 if finger==1 else 95),(3,30 if finger==1 else 65)]:
   n=f'finger{finger}-{seg}{side}';b=rig.pose.bones.get(n)
   if not b:continue
   direction=b.tail-b.head
   # Choose curl direction once per finger joint. Re-deciding from almost equal
   # distances every frame made a finger flip to its opposite bend mid-rep.
   sign=grip_signs[sign_key]
   q=Quaternion(axis,math.radians(sign*deg))@b.matrix.to_quaternion();global_rotation(rig,n,q)

def export(name,mesh,rig,props,animated):
 bpy.ops.object.select_all(action='DESELECT')
 for obj in [mesh,rig]+props:obj.select_set(True)
 bpy.context.view_layer.objects.active=rig
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True,export_animations=animated,export_nla_strips=True,export_force_sampling=True,export_apply=False,export_morph=False)

for clip in CLIPS:
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
 for old_action in list(bpy.data.actions):
  if old_action.users==0:bpy.data.actions.remove(old_action)
 bpy.ops.import_scene.gltf(filepath=str(ROOT/'third_party/opengym3d/workfiles/retargeted-v1'/(clip+'.glb')))
 mesh=next(o for o in bpy.context.scene.objects if o.type=='MESH');rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE');bpy.context.view_layer.objects.active=mesh;mesh.select_set(True)
 smooth_surface(mesh);mesh.data.materials.clear();mesh.data.materials.append(material('Athletic body',(.12,.16,.21),.1,.7));mesh.name='OpenGymMuscularHuman'
 if clip=='muscular_body':
  export(clip,mesh,rig,[],False);bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'refined_source.blend'));continue
 action=rig.animation_data.action;first,last=map(int,action.frame_range);scene=bpy.context.scene;scene.frame_start=first;scene.frame_end=last
 original={}
 for f in range(first,last+1):
  scene.frame_set(f);original[f]={b.name:(b.rotation_quaternion.copy(),b.location.copy(),b.scale.copy()) for b in rig.pose.bones}
 scene.frame_set(first);bpy.context.view_layer.update();ankles={side:rig.pose.bones['foot'+side].head.copy() for side in ['.L','.R']};feet={side:rig.pose.bones['foot'+side].matrix.to_quaternion().copy() for side in ankles}
 rest_torso=rig.data.bones['neck01'].head_local-rig.data.bones['root'].head_local
 rig.animation_data_clear();rig.animation_data_create();rig.animation_data.action=bpy.data.actions.new(clip+' corrected')
 props=[implement('Dumbbell.L','dumbbell'),implement('Dumbbell.R','dumbbell')] if clip=='bicep_curl' else [implement('Barbell','barbell')]
 errors=[];grip_errors=[];grip_signs={}
 for f in range(first,last+1):
  scene.frame_set(f)
  for b in rig.pose.bones:b.rotation_mode='QUATERNION';b.rotation_quaternion,b.location,b.scale=original[f][b.name]
  bpy.context.view_layer.update()
  if clip in ['romanian_deadlift','good_morning']:
   # The retargeted v1 distributed forward flexion through the lumbar chain,
   # producing a visibly rounded back. Keep the rest spine's natural curve
   # as one hinged torso; retain the measured hip-to-neck inclination.
   torso=rig.pose.bones['neck01'].head-rig.pose.bones['root'].head
   hinge=rest_torso.normalized().rotation_difference(torso.normalized())
   global_rotation(rig,'root',hinge@rig.data.bones['root'].matrix_local.to_quaternion())
   root_pose=rig.pose.bones['root'];matrix=root_pose.matrix.copy();matrix.translation.z-=.006;root_pose.matrix=matrix;bpy.context.view_layer.update()
   for b in rig.pose.bones:
    if b.name.startswith(('spine','neck')) or b.name=='head':
     b.rotation_quaternion=Quaternion();bpy.context.view_layer.update()
  for side in ankles:
   errors.append(solve_chain(rig,['upperleg01'+side,'upperleg02'+side],['lowerleg01'+side,'lowerleg02'+side],ankles[side],Vector((0,-1,0))))
   global_rotation(rig,'foot'+side,feet[side])
   # Toe local rotations stay at the measured initial frame as feet remain planted.
   for b in rig.pose.bones:
    if b.name.startswith('toe') and b.name.endswith(side):b.rotation_quaternion=original[first][b.name][0]
  bpy.context.view_layer.update()
  if clip=='good_morning':
   chest=rig.pose.bones['spine01'].matrix.to_quaternion();bar=rig.pose.bones['neck01'].head+chest@Vector((0,.052,-.045))
   props[0].location=bar;props[0].rotation_mode='QUATERNION';props[0].rotation_quaternion=chest
   for side,sign in [('.L',1),('.R',-1)]:
    grip=bar+chest@Vector((sign*.34,0,0));target=grip-chest@Vector((0,0,.11))
    for _ in range(5):
     solve_chain(rig,['upperarm01'+side,'upperarm02'+side],['lowerarm01'+side,'lowerarm02'+side],target,chest@Vector((sign*.65,.5,-.4)))
     aim(rig,'wrist'+side,chest@Vector((0,0,1)));orient_palm(rig,side,chest@Vector((0,-1,0)));target=rig.pose.bones['wrist'+side].head+grip-palm_center(rig,side)
    close_grip(rig,side,grip,chest@Vector((1,0,0)));grip_errors.append((palm_center(rig,side)-grip).length)
  else:
   if clip=='romanian_deadlift':
    # Hanging arms carry the bar vertically; they must not inherit torso bend.
    for side in ankles:
     for n in ['upperarm01','upperarm02','lowerarm01','lowerarm02']:
      aim(rig,n+side,Vector((0,0,-1)))
   if clip=='bicep_curl':
    # Keep separate dumbbells apart rather than intersecting at the top.
    for side,sign in [('.L',1),('.R',-1)]:
     target=rig.pose.bones['wrist'+side].head.copy();target.x=sign*.205
     solve_chain(rig,['upperarm01'+side,'upperarm02'+side],['lowerarm01'+side,'lowerarm02'+side],target,Vector((0,.5,-1)))
   for side in ankles:
    fore=rig.pose.bones['lowerarm02'+side].tail-rig.pose.bones['lowerarm01'+side].head;aim(rig,'wrist'+side,fore)
    desired=Vector((0,fore.normalized().z,-fore.normalized().y)) if clip=='bicep_curl' else Vector((0,1,0))
    orient_palm(rig,side,desired);center=palm_center(rig,side);close_grip(rig,side,center,Vector((1,0,0)))
   wrists=[palm_center(rig,side) for side in ['.L','.R']]
   if clip=='bicep_curl':
    for obj,point in zip(props,wrists):obj.location=point
   else:props[0].location=(wrists[0]+wrists[1])/2
  for b in rig.pose.bones:
   b.keyframe_insert(data_path='rotation_quaternion',frame=f);b.keyframe_insert(data_path='location',frame=f)
  for obj in props:obj.keyframe_insert(data_path='location',frame=f);obj.keyframe_insert(data_path='rotation_quaternion',frame=f)
 for act in [rig.animation_data.action]+[o.animation_data.action for o in props]:
  for fc in act.fcurves:
   for k in fc.keyframe_points:k.interpolation='LINEAR'
 # A single shared NLA track merges body and props into ONE exercise clip.
 # Exporting every orphan action made the old viewer mix two skeleton motions.
 for obj in [rig]+props:
  ad=obj.animation_data;act=ad.action
  for track in list(ad.nla_tracks):ad.nla_tracks.remove(track)
  ad.action=None;track=ad.nla_tracks.new();track.name=clip;strip=track.strips.new(clip,first,act);strip.action_frame_start=first;strip.action_frame_end=last
 for old_action in list(bpy.data.actions):
  if old_action.users==0:bpy.data.actions.remove(old_action)
 scene.frame_set(first);export(clip,mesh,rig,props,True)
 REPORT.append({'id':clip,'frames':[first,last],'maxAnkleTargetErrorMeters':max(errors),'maxGripTargetErrorMeters':max(grip_errors,default=0),'props':len(props),'fixes':['planted feet','wrist follows forearm','closed fingers','implements','softened pec surface/custom normals reset']})
(OUT/'refinement-report.json').write_text(json.dumps(REPORT,indent=2));print('REFINEMENT_DONE',REPORT)
