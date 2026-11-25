"""Two aligned transparent layers for a real lid-lift animation, local Blender scene."""
import bpy, math, json, hashlib
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'output/blender-pro-gift';OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
s=bpy.context.scene;s.render.engine='CYCLES';s.cycles.samples=32;s.cycles.use_denoising=True
s.render.resolution_x=640;s.render.resolution_y=640;s.render.resolution_percentage=100
s.render.film_transparent=True;s.render.image_settings.color_mode='RGBA';s.render.image_settings.file_format='PNG'
s.world.color=(.12,.12,.12);s.view_settings.view_transform='AgX'
def mat(name,c,metal=0):
 m=bpy.data.materials.new(name);m.diffuse_color=(*c,1);m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*c,1);p.inputs['Metallic'].default_value=metal;p.inputs['Roughness'].default_value=.28
 return m
black=mat('Graphite gift box',(.026,.031,.035),.35)
inside=mat('Dark interior',(.008,.011,.012))
lime=mat('Lime satin ribbon',(.46,.91,.047),.28)
groups={'base':[],'lid':[]}
def box(name,loc,scale,m,group):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=bpy.context.object;o.name=name;o.scale=scale
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);o.data.materials.append(m)
 b=o.modifiers.new('Soft edge','BEVEL');b.width=.035;b.segments=4
 o.modifiers.new('Weighted normals','WEIGHTED_NORMAL');groups[group].append(o);return o
# Open topped base, visible when the lid rises.
box('Base floor',(0,0,.12),(1.75,1.75,.24),black,'base')
for x in [-.82,.82]:box('Box side',(x,0,.82),(.11,1.75,1.4),black,'base')
for y in [-.82,.82]:box('Box wall',(0,y,.82),(1.55,.11,1.4),black,'base')
box('Interior bottom',(0,0,.25),(1.52,1.52,.06),inside,'base')
for y in [-.885,.885]:box('Vertical front ribbon',(0,y,.8),(.29,.025,1.5),lime,'base')
for x in [-.885,.885]:box('Vertical side ribbon',(x,0,.8),(.025,.29,1.5),lime,'base')
box('Bevelled lid',(0,0,1.58),(1.94,1.94,.28),black,'lid')
box('Lid ribbon X',(0,0,1.733),(1.95,.30,.026),lime,'lid')
box('Lid ribbon Y',(0,0,1.75),(.30,1.95,.026),lime,'lid')
for y in [-.98,.98]:box('Lid ribbon fold',(0,y,1.59),(.30,.025,.27),lime,'lid')
for x in [-.98,.98]:box('Lid side fold',(x,0,1.59),(.025,.30,.27),lime,'lid')
# Wide ribbon strips bent into two loops; each travels out and returns to the knot.
for side in [-1,1]:
 verts=[]
 for i in range(65):
  t=i/64*2*math.pi
  x=side*(.1+.69*(1-math.cos(t))/2);y=.06*math.sin(t);z=1.83+.36*math.sin(t/2)+.10*math.sin(t)
  for offset in [-.09,.09]:verts.append((x,y+offset,z))
 faces=[(2*i,2*i+1,2*i+3,2*i+2) for i in range(64)]
 mesh=bpy.data.meshes.new('Satin loop');mesh.from_pydata(verts,[],faces);mesh.update()
 o=bpy.data.objects.new('Bow loop',mesh);s.collection.objects.link(o);o.data.materials.append(lime)
 solid=o.modifiers.new('Ribbon thickness','SOLIDIFY');solid.thickness=.014
 bevel=o.modifiers.new('Ribbon edge','BEVEL');bevel.width=.012;bevel.segments=3
 for p in o.data.polygons:p.use_smooth=True
 groups['lid'].append(o)
box('Bow knot',(0,0,1.87),(.25,.27,.20),lime,'lid')
def aim(o,p):o.rotation_euler=(Vector(p)-o.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(4,-6,4.5));cam=bpy.context.object;aim(cam,(0,0,1.05));cam.data.type='ORTHO';cam.data.ortho_scale=3.65;s.camera=cam
for loc,power,size in [((0,-4,6),550,4),((4,1,5),700,3),((-3,1,3),350,3)]:
 bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.data.energy=power;o.data.shape='DISK';o.data.size=size;aim(o,(0,0,1))
records=[]
for group in ['base','lid']:
 for key,objects in groups.items():
  for o in objects:o.hide_render=key!=group
 s.render.filepath=str(OUT/f'pro-gift-{group}.png');bpy.ops.render.render(write_still=True)
 records.append({'name':f'pro-gift-{group}','sha256':hashlib.sha256(Path(s.render.filepath).read_bytes()).hexdigest()})
for objects in groups.values():
 for o in objects:o.hide_render=False
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'pro-gift.blend'))
(OUT/'manifest.json').write_text(json.dumps({'generator':'scripts/blender/build-pro-gift.py','render':'640x640 RGBA, Cycles32, aligned base/lid layers','assets':records},indent=2))
