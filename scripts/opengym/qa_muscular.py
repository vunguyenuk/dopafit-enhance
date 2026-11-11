"""Offline structural and posed-mesh QA, plus contact-sheet renders for review."""
import bpy,math,json,hashlib
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2];folder=ROOT/'.build/opengym-muscular';report=[]
for name in ['muscular_body','bicep_curl','romanian_deadlift','good_morning']:
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
 bpy.ops.import_scene.gltf(filepath=str(folder/(name+'.glb')))
 mesh=next(o for o in bpy.context.scene.objects if o.type=='MESH');rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
 action=rig.animation_data.action if rig.animation_data else None
 first,last=map(int,action.frame_range) if action else (0,0)
 snapshots=[];failures=[];max_edge=0
 rest_lengths=[b.length for b in rig.data.bones]
 for frame in range(first,last+1):
  bpy.context.scene.frame_set(frame);bpy.context.view_layer.update();dg=bpy.context.evaluated_depsgraph_get();evaluated=mesh.evaluated_get(dg);geo=evaluated.to_mesh()
  points=[evaluated.matrix_world@v.co for v in geo.vertices]
  if not all(math.isfinite(x) for p in points for x in p):failures.append('non-finite vertex')
  edge=max(((points[e.vertices[0]]-points[e.vertices[1]]).length for e in geo.edges),default=0);max_edge=max(edge,max_edge)
  if edge>0.30:failures.append(f'posed edge longer than0.30m: {edge}')
  lo=[min(p[i] for p in points) for i in range(3)];hi=[max(p[i] for p in points) for i in range(3)]
  if max(hi[i]-lo[i] for i in range(3))>2.6:failures.append('exploded mesh bounds')
  if frame in [first,(first+last)//2,last]:snapshots.append({'frame':frame,'bounds':[lo,hi],'maxEdgeMeters':edge})
  evaluated.to_mesh_clear()
 report.append({'id':name,'sha256':hashlib.sha256((folder/(name+'.glb')).read_bytes()).hexdigest(),'vertices':len(mesh.data.vertices),'bones':len(rig.data.bones),'framesChecked':last-first+1,'frames':snapshots,'maxEdgeMeters':max_edge,'failures':failures,'pass':not failures})
(folder/'geometry-qa.json').write_text(json.dumps(report,indent=2));print('GEOMETRY_QA',json.dumps(report),flush=True)
# Neutral front/back are authored-asset previews, not desktop screenshots.
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False);bpy.ops.import_scene.gltf(filepath=str(folder/'muscular_body.glb'))
mesh=next(o for o in bpy.context.scene.objects if o.type=='MESH')
mat=bpy.data.materials.new('Preview blue steel');mat.use_nodes=True;bsdf=mat.node_tree.nodes.get('Principled BSDF');bsdf.inputs['Base Color'].default_value=(0.1,0.16,0.23,1);bsdf.inputs['Metallic'].default_value=.25;bsdf.inputs['Roughness'].default_value=.5;mesh.data.materials.clear();mesh.data.materials.append(mat)
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=24;scene.render.resolution_x=384;scene.render.resolution_y=640;scene.render.resolution_percentage=100;scene.render.film_transparent=False;scene.world.color=(0.015,0.015,0.015)
for pos,power,size in [((3,-4,5),650,4),((-3,1,4),500,3),((0,4,3),550,3)]:
 bpy.ops.object.light_add(type='AREA',location=pos);light=bpy.context.object;light.data.energy=power;light.data.shape='DISK';light.data.size=size;light.rotation_euler=(Vector((0,0,1))-light.location).to_track_quat('-Z','Y').to_euler()
height=mesh.dimensions.z;target=Vector((0,0,height/2))
for name,y in [('front',-4),('back',4)]:
 bpy.ops.object.camera_add(location=(0,y,height/2));camera=bpy.context.object;camera.rotation_euler=(target-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.type='ORTHO';camera.data.ortho_scale=height*1.12;scene.camera=camera;scene.render.filepath=str(folder/('preview-'+name+'.png'));bpy.ops.render.render(write_still=True)
assert all(r['pass'] for r in report),'Model QA failed; inspect geometry-qa.json before shipping'

# Review the middle pose from front/side/rear for every shipped motion.
scene.cycles.samples=16;scene.render.resolution_x=256;scene.render.resolution_y=384
for clip in ['bicep_curl','romanian_deadlift','good_morning']:
 for obj in list(scene.objects):
  if obj.type in ['MESH','ARMATURE']:bpy.data.objects.remove(obj,do_unlink=True)
 bpy.ops.import_scene.gltf(filepath=str(folder/(clip+'.glb')))
 mesh=next(o for o in scene.objects if o.type=='MESH');mesh.data.materials.clear();mesh.data.materials.append(mat)
 rig=next(o for o in scene.objects if o.type=='ARMATURE');first,last=map(int,rig.animation_data.action.frame_range);scene.frame_set((first+last)//2)
 for view,position in [('front',(0,-4,.86)),('side',(4,0,.86)),('back',(0,4,.86))]:
  camera.location=position;camera.rotation_euler=(Vector((0,0,.86))-camera.location).to_track_quat('-Z','Y').to_euler();scene.camera=camera;scene.render.filepath=str(folder/(clip+'-'+view+'.png'));bpy.ops.render.render(write_still=True)
