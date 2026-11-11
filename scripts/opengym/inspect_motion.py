"""Inspect shipped geometry and motion without modifying the app bundle."""
import bpy,bmesh,json,math
from pathlib import Path
root=Path(__file__).resolve().parents[2];out=root/'.build/opengym-refined';out.mkdir(exist_ok=True);report=[]
for name in ['muscular_body','bicep_curl','romanian_deadlift','good_morning']:
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
 bpy.ops.import_scene.gltf(filepath=str(root/'DopafitRebuild/OpenGym3D/models'/(name+'.glb')))
 mesh=next(o for o in bpy.context.scene.objects if o.type=='MESH');rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
 bm=bmesh.new();bm.from_mesh(mesh.data)
 boundary=[e for e in bm.edges if e.is_boundary];components=[];remaining=set(boundary)
 while remaining:
  stack=[remaining.pop()];edges=[];verts=set()
  while stack:
   e=stack.pop();edges.append(e);verts.update(e.verts)
   for v in e.verts:
    for nxt in v.link_edges:
     if nxt in remaining:remaining.remove(nxt);stack.append(nxt)
  components.append({'edges':len(edges),'center':[sum(v.co[i] for v in verts)/len(verts) for i in range(3)]})
 first,last=map(int,rig.animation_data.action.frame_range) if rig.animation_data else (0,0);poses=[]
 for f in sorted(set([first,(first+last)//2,last])):
  bpy.context.scene.frame_set(f);bpy.context.view_layer.update()
  poses.append({'frame':f,'bones':{b.name:{'head':list(rig.matrix_world@b.head),'tail':list(rig.matrix_world@b.tail),'rotation':list(b.rotation_quaternion)} for b in rig.pose.bones if b.name in ['wrist.L','wrist.R','foot.L','foot.R','toe1-1.L','lowerarm02.L','upperarm02.L','root']}})
 report.append({'id':name,'verts':len(mesh.data.vertices),'boundaryComponents':components,'degenerateFaces':sum(p.area<1e-12 for p in mesh.data.polygons),'poses':poses})
 bm.free()
(out/'inspection.json').write_text(json.dumps(report,indent=2));print('INSPECTION_DONE',[(r['id'],r['verts'],[(x['edges'],[round(v,3) for v in x['center']]) for x in r['boundaryComponents']]) for r in report])
