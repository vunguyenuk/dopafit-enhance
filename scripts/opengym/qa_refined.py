"""Validate exported candidate motions and render multi-angle keyframes."""
import bpy,math,json,hashlib
from mathutils import Vector
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];folder=ROOT/'.build/opengym-refined';reports=[]
for clip in ['muscular_body','bicep_curl','romanian_deadlift','good_morning']:
 for old in list(bpy.data.objects):bpy.data.objects.remove(old,do_unlink=True)
 bpy.ops.import_scene.gltf(filepath=str(folder/(clip+'.glb')))
 meshes=[o for o in bpy.context.scene.objects if o.type=='MESH'];mesh=max(meshes,key=lambda o:len(o.data.vertices));rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE');props=[o for o in meshes if o.name.startswith(('Dumbbell','Barbell'))]
 action=rig.animation_data.action if rig.animation_data else None;first,last=map(int,action.frame_range) if action else (0,0)
 bpy.context.scene.frame_set(first);bpy.context.view_layer.update();anchors={s:(rig.matrix_world@rig.pose.bones['foot'+s].head).copy() for s in ['.L','.R']}
 failures=[];max_edge=0;min_floor=0;max_drift=0;max_grip=0;max_finger=0;first_points=None;last_points=None;previous_points=None;max_step=0
 for f in range(first,last+1):
  bpy.context.scene.frame_set(f);bpy.context.view_layer.update();evaluated=mesh.evaluated_get(bpy.context.evaluated_depsgraph_get());geo=evaluated.to_mesh();pts=[evaluated.matrix_world@v.co for v in geo.vertices]
  assert all(math.isfinite(x) for p in pts for x in p),'non-finite vertices'
  if first_points is None:first_points=pts
  if previous_points is not None:max_step=max(max_step,max((p-q).length for p,q in zip(pts,previous_points)))
  previous_points=pts;last_points=pts
  edge=max((pts[e.vertices[0]]-pts[e.vertices[1]]).length for e in geo.edges);max_edge=max(max_edge,edge);floor=min(p.z for p in pts);min_floor=min(min_floor,floor)
  if edge>.30:failures.append(f'frame{f}:edge>{edge}')
  if max(max(p[i] for p in pts)-min(p[i] for p in pts) for i in range(3))>2.6:failures.append(f'frame{f}:bounds exploded')
  if clip!='muscular_body':
   drift=max(((rig.matrix_world@rig.pose.bones['foot'+s].head)-anchors[s]).length for s in anchors);max_drift=max(max_drift,drift)
   for side in ['.L','.R']:
    fore=(rig.pose.bones['wrist'+side].tail-rig.pose.bones['wrist'+side].head).normalized()
    across=rig.pose.bones['finger2-1'+side].head-rig.pose.bones['finger5-1'+side].head
    normal=(across.cross(fore) if side=='.L' else fore.cross(across)).normalized()
    hand=rig.matrix_world@(sum((rig.pose.bones[f'finger{i}-1{side}'].head for i in range(2,6)),Vector())/4+normal*.012)
    if clip=='bicep_curl':obj=next(o for o in props if side in o.name);error=(hand-obj.matrix_world.translation).length
    else:
     obj=props[0];axis=(obj.matrix_world.to_3x3()@Vector((1,0,0))).normalized();v=hand-obj.matrix_world.translation;error=(v-axis*v.dot(axis)).length
    max_grip=max(max_grip,error)
    axis=(obj.matrix_world.to_3x3()@Vector((1,0,0))).normalized()
    for digit in range(2,6):
     tip=rig.matrix_world@rig.pose.bones[f'finger{digit}-3{side}'].tail
     offset=tip-obj.matrix_world.translation;max_finger=max(max_finger,(offset-axis*offset.dot(axis)).length)
  evaluated.to_mesh_clear()
 if clip!='muscular_body' and max_drift>.002:failures.append('foot anchor drift>2mm')
 if clip!='muscular_body' and min_floor<-.015:failures.append('body penetrates floor>15mm')
 if max_grip>.025:failures.append('grip detached>25mm')
 if max_finger>.06:failures.append('fingertips open/detached>60mm from handle axis')
 seam=max((p-q).length for p,q in zip(first_points,last_points))
 if seam>.005:failures.append('loop seam>5mm')
 if max_step>.10:failures.append('vertex step>100mm/frame')
 report={'id':clip,'sha256':hashlib.sha256((folder/(clip+'.glb')).read_bytes()).hexdigest(),'framesChecked':last-first+1,'vertices':len(mesh.data.vertices),'maxEdgeMeters':max_edge,'lowestBodyZMeters':min_floor,'maxFootDriftMeters':max_drift,'maxGripDistanceMeters':max_grip,'gripReference':'MCP palm center +12mm palm normal; wrist tail is not grip center','maxFingertipToHandleAxisMeters':max_finger,'loopSeamMeters':seam,'maxFrameStepMeters':max_step,'props':len(props),'meshObjects':[o.name for o in meshes],'failures':failures,'pass':not failures};reports.append(report);print('QA',report,flush=True)
 # Render first/mid/last from front/side/back for inspection, not app screenshots.
 scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=16;scene.render.resolution_x=320;scene.render.resolution_y=540;scene.render.resolution_percentage=100;scene.world.color=(.015,.015,.015)
 for pos,power,size in [((3,-4,5),650,4),((-3,1,4),400,3),((0,4,3),450,3)]:
  bpy.ops.object.light_add(type='AREA',location=pos);light=bpy.context.object;light.data.energy=power;light.data.size=size;light.rotation_euler=(Vector((0,0,1))-light.location).to_track_quat('-Z','Y').to_euler()
 bpy.ops.object.camera_add();camera=bpy.context.object;camera.data.type='ORTHO';camera.data.ortho_scale=1.95;scene.camera=camera
 for f in sorted(set([first,(first+last)//2,last])):
  scene.frame_set(f)
  for view,pos in [('front',(0,-4,.86)),('side',(4,0,.86)),('back',(0,4,.86))]:
   camera.location=pos;camera.rotation_euler=(Vector((0,0,.86))-camera.location).to_track_quat('-Z','Y').to_euler();scene.render.filepath=str(folder/(f'{clip}-{f}-{view}.png'));bpy.ops.render.render(write_still=True)
(folder/'geometry-qa.json').write_text(json.dumps(reports,indent=2)+'\n');assert all(r['pass'] for r in reports),'Inspect geometry-qa.json; do not ship failed candidates'
