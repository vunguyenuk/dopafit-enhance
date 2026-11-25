"""Editable Blender 4.0 scene and offline renders for the native onboarding control.
Run: Blender --background --python scripts/blender/build-onboarding-plates.py -- --preview
All dimensions in metres. Visual plates are illustrative 2kg-per-side increments,
not a density/mass certification. A 50mm sleeve passes through 50.8mm bores.
"""
import bpy, math, sys, json
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2]; OUT=ROOT/'output/blender-plates';OUT.mkdir(parents=True,exist_ok=True)
preview='--preview' in sys.argv
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
scene=bpy.context.scene;scene.unit_settings.system='METRIC';scene.render.engine='CYCLES'
scene.cycles.samples=24 if preview else 48;scene.cycles.use_denoising=True
scene.cycles.max_bounces=5;scene.cycles.transparent_max_bounces=8
scene.render.resolution_x=1080;scene.render.resolution_y=800;scene.render.resolution_percentage=60 if preview else 100
scene.render.film_transparent=True;scene.render.image_settings.file_format='PNG';scene.render.image_settings.color_mode='RGBA'
scene.world.color=(.035,.035,.035)
scene.view_settings.view_transform='Standard'

def material(name,color,metal=0,rough=.4,emit=0):
 m=bpy.data.materials.new(name);m.use_nodes=True;p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*color,1);p.inputs['Metallic'].default_value=metal;p.inputs['Roughness'].default_value=rough
 if emit:p.inputs['Emission Color'].default_value=(*color,1);p.inputs['Emission Strength'].default_value=emit
 return m
rubber=material('Charcoal rubber — molded texture',(.008,.010,.011),0,.6)
nodes=rubber.node_tree.nodes;links=rubber.node_tree.links;p=nodes.get('Principled BSDF');noise=nodes.new('ShaderNodeTexNoise');noise.inputs['Scale'].default_value=320;noise.inputs['Detail'].default_value=2
bump=nodes.new('ShaderNodeBump');bump.inputs['Strength'].default_value=.15;bump.inputs['Distance'].default_value=.00045;links.new(noise.outputs['Fac'],bump.inputs['Height']);links.new(bump.outputs['Normal'],p.inputs['Normal'])
steel=material('Brushed chrome sleeve',(.48,.51,.53),.92,.22)
steelDark=material('Graphite powder-coated rack',(.045,.052,.057),.75,.32)
black=material('Recesses',(.005,.006,.007),.2,.47)
lime=material('Dopafit lime edge',(.46,.91,.047),.05,.4,.65)
ghostMat=material('Ghost lime',(.36,.58,.08),.1,.5,.5)
greyGhost=material('Unloaded neutral guide',(.065,.08,.08),.1,.5,.1)
# Ghost geometry is an overlay guide, kept dim without specular lighting.
for m,c in [(greyGhost,(.07,.11,.018)),(ghostMat,(.46,.91,.047))]:
 n=m.node_tree.nodes;n.clear();out=n.new('ShaderNodeOutputMaterial');e=n.new('ShaderNodeEmission');e.inputs['Color'].default_value=(*c,1);e.inputs['Strength'].default_value=.6;m.node_tree.links.new(e.outputs[0],out.inputs['Surface'])


def finish(o,name,mat,bevel=0):
 o.name=name;o.data.materials.append(mat)
 if bevel:
  b=o.modifiers.new('Machined edge radius','BEVEL');b.width=bevel;b.segments=3
 if o.type=='MESH':
  for poly in o.data.polygons:poly.use_smooth=True
 return o

def cyl(name,radius,depth,loc,mat,axis='X',vertices=96):
 bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=radius,depth=depth,location=loc)
 o=bpy.context.object
 if axis=='X':o.rotation_euler[1]=math.pi/2
 elif axis=='Y':o.rotation_euler[0]=math.pi/2
 return finish(o,name,mat,.001)

def box(name,loc,scale,mat,bevel=.008):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=bpy.context.object;o.scale=scale;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);return finish(o,name,mat,bevel)

def lathe(name,x,profile,mat):
 seg=128;verts=[];faces=[]
 for dx,r in profile:
  for i in range(seg):
   a=i*math.tau/seg;verts.append((x+dx*1.44,math.cos(a)*r,math.sin(a)*r))
 for j in range(len(profile)):
  for i in range(seg):
   a=j*seg+i;b=j*seg+(i+1)%seg;c=((j+1)%len(profile))*seg+(i+1)%seg;d=((j+1)%len(profile))*seg+i;faces.append((a,b,c,d))
 mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new(name,mesh);scene.collection.objects.link(o);return finish(o,name,mat)

def torus(name,x,r,tube,mat):
 bpy.ops.mesh.primitive_torus_add(major_segments=128,minor_segments=12,location=(x,0,0),major_radius=r,minor_radius=tube,rotation=(0,math.pi/2,0));return finish(bpy.context.object,name,mat)

# One continuous steel shaft, a larger hollow-looking sleeve, and integral flange.
cyl('Continuous bar shaft, through all bores',.014,1.125,(.0975,0,0),steel)
cyl('50mm loadable sleeve',.025,.41,(-.255,0,0),steel)
cyl('End-cap bevel',.030,.014,(-.465,0,0),steel)
cyl('Fixed inner flange',.038,.019,(-.04,0,0),steel)
# Fine circumferential turning marks (not floating/disconnected bar segments).
for i in range(45):torus('Lathed sleeve machining',-.43+i*.0075,.0251,.00024,steelDark)
# Rack holes are actual booleans through the upright.
rack=box('Rack upright',(.39,.075,.015),(.07,.065,.64),steelDark,.006)
for i in range(9):
 z=-.265+i*.067
 cut=cyl('temporary drill',.009,.13,(.39,.075,z),black,'Y',32)
 bpy.context.view_layer.objects.active=rack;mod=rack.modifiers.new('Through hole','BOOLEAN');mod.object=cut;mod.operation='DIFFERENCE';bpy.ops.object.modifier_apply(modifier=mod.name);bpy.data.objects.remove(cut,do_unlink=True)
box('Rack J-cup back',(.385,-.012,-.014),(.092,.04,.065),steelDark,.01)
box('Rack J-cup shelf',(.34,-.017,-.026),(.12,.05,.018),steelDark,.004)
# Bumper cross-section has real continuous thickness and a central through-hole.
profile=[(-.0125,.0254),(-.0125,.047),(-.010,.058),(-.010,.19),(-.008,.215),(-.004,.225),(.004,.225),(.010,.216),(.0125,.195),(.0125,.17),(.0105,.166),(.0105,.065),(.009,.045),(.0125,.038),(.0125,.0254)]
plates=[];edges=[];ghosts=[]
for i in range(6):
 x=-.065-i*.038
 plate=lathe(f'Plate {i+1} — annular rubber',x,profile,rubber)
 bore=lathe(f'Plate {i+1} — steel bore',x,[(-.0127,.0254),(-.0127,.034),(.0127,.034),(.0127,.0254)],steel)
 groove=torus(f'Plate {i+1} — molded front groove',x+.0126,.174,.0009,black)
 edge=lathe(f'Plate {i+1} — active lime outer band',x,[(-.009,.2255),(.004,.2255),(.004,.2262),(-.009,.2262)],lime)
 plates.append([plate,bore,groove]);edges.append(edge)
 # Dashes lie on the same actual cylinder plane as the future plate.
 group=[]
 for j in range(36):
  a0=j*math.tau/36;a1=a0+math.tau/36*.48
  curve=bpy.data.curves.new('Ghost dash','CURVE');curve.dimensions='3D';curve.bevel_depth=.0008;curve.bevel_resolution=2
  poly=curve.splines.new('POLY');poly.points.add(4)
  for k,pt in enumerate(poly.points):
   a=a0+(a1-a0)*k/4;pt.co=(x-.0125,.225*math.cos(a),.225*math.sin(a),1)
  o=bpy.data.objects.new(f'Ghost slot {i+1}',curve);scene.collection.objects.link(o);o.data.materials.append(greyGhost);group.append(o)
 ghosts.append(group)
# Orthographic camera sees the disc thickness and end-face without perspective distortion.
bpy.ops.object.camera_add(location=(1.8,-6,.35));camera=bpy.context.object;target=Vector((0,0,.005));camera.rotation_euler=(target-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.type='ORTHO';camera.data.ortho_scale=1.08;scene.camera=camera

def area(name,loc,power,size,color):
 bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.name=name;o.data.energy=power;o.data.shape='DISK';o.data.size=size;o.data.color=color;o.rotation_euler=(Vector((-.15,0,0))-o.location).to_track_quat('-Z','Y').to_euler()
area('Softbox key',(-1.0,-2,2.8),115,2.5,(.9,.94,1))
area('Top strip reflection',(1,1,2),160,1.8,(1,.98,.94))
area('Soft front fill',(0,-3,.5),35,2,(.86,.92,1))
area('Lime edge separation',(-.5,.5,.3),9,.45,(.71,.96,.24))

def state(n,loaded):
 scene['total_slots']=n;scene['loaded_per_side']=loaded;scene['added_kg_total']=loaded*4
 for i in range(6):
  for o in plates[i]:o.hide_render=i>=loaded;o.hide_viewport=i>=loaded
  edges[i].hide_render=not(i==loaded-1);edges[i].hide_viewport=edges[i].hide_render
  for o in ghosts[i]:
   o.hide_render=not(loaded<=i<n);o.hide_viewport=o.hide_render;o.data.materials[0]=ghostMat if i==loaded else greyGhost
state(6,2);bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'onboarding-plates.blend'))
if preview:
 scene.render.filepath=str(OUT/'preview.png');bpy.ops.render.render(write_still=True)
else:
 for n in [3,5,6]:
  for loaded in range(n+1):
   state(n,loaded);scene.render.filepath=str(OUT/f'plates-{n}-{loaded}.png');bpy.ops.render.render(write_still=True)
 (OUT/'geometry.json').write_text(json.dumps({'blender':bpy.app.version_string,'units':'metres','outsideDiameter':.45,'boreDiameter':.0508,'sleeveDiameter':.05,'sleeveLength':.41,'sleeveLeftEnd':-.465,'sleeveChange':'Shortened170mm from original580mm sleeve; plate/rack positions unchanged; camera centered and tightened to1.08 for taller stage','plateThickness':.036,'pitch':.038,'allStates':17,'render':'1080x800 transparent Cycles48samples','weightSemantics':'Each slot adds2kgper side=4kg total; visual geometry not mass/density certification','model':'onboarding-plates.blend'},indent=2)+'\n')
