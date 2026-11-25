"""Deterministic calendar illustration: one scene, five actual digits for days2…6."""
import bpy, math, json
from mathutils import Vector
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'output/blender-calendar';OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=32
scene.render.resolution_x=600;scene.render.resolution_y=600;scene.render.resolution_percentage=100
scene.render.film_transparent=True;scene.render.image_settings.file_format='PNG';scene.render.image_settings.color_mode='RGBA'
scene.world.color=(.12,.12,.12)
scene.view_settings.view_transform='Standard'
def mat(name,color,metal=0,rough=.3):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True;p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*color,1);p.inputs['Metallic'].default_value=metal;p.inputs['Roughness'].default_value=rough;return m
rubber=mat('Neutral charcoal',(0.035,.042,.047),.15,.29);lime=mat('Dopafit lime',(.462,.911,.047),.05,.32);silver=mat('Silver rings',(.68,.72,.76),.85,.23);white=mat('White numeral',(.92,.95,.97),.25,.24);back=mat('Back leaf',(.018,.023,.026),.2,.33)
def block(name,loc,scale,material,bevel):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=bpy.context.object;o.name=name;o.dimensions=scale;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);o.data.materials.append(material);m=o.modifiers.new('Soft calendar corners','BEVEL');m.width=bevel;m.segments=8;o.modifiers.new('Normals','WEIGHTED_NORMAL');return o
block('Calendar back',(0,.08,-.07),(2.5,.34,2.75),back,.23)
block('Calendar face',(0,-.13,-.06),(2.45,.22,2.62),rubber,.22)
block('Lime binding header',(0,-.14,1.05),(2.49,.27,.59),lime,.18)
for x in [-.72,0,.72]:
 bpy.ops.mesh.primitive_torus_add(major_radius=.235,minor_radius=.057,major_segments=64,minor_segments=16,location=(x,-.02,1.39),rotation=(0,math.pi/2,0));o=bpy.context.object;o.name='Silver binding ring';o.data.materials.append(silver)
font=None
for path in ['/System/Library/Fonts/SFNS.ttf','/System/Library/Fonts/SFNSDisplay.ttf']:
 if Path(path).exists():
  try:font=bpy.data.fonts.load(path);break
  except:pass
bpy.ops.object.text_add(location=(0,-.265,-.11),rotation=(math.pi/2,0,0));digit=bpy.context.object;digit.name='Weekly session count';digit.data.align_x='CENTER';digit.data.align_y='CENTER';digit.data.size=1.6;digit.data.extrude=.042;digit.data.bevel_depth=.012;digit.data.bevel_resolution=4;digit.data.materials.append(white)
if font:digit.data.font=font
for name,loc,energy,size in [('Key',(-3,-5,6),280,4),('Fill',(5,-2,3),180,3),('Rim',(0,3,4),380,3)]:
 bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.name=name;o.data.energy=energy;o.data.shape='DISK';o.data.size=size;o.rotation_euler=(Vector((0,0,.3))-o.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(4,-10,4.5));camera=bpy.context.object;camera.rotation_euler=(Vector((0,0,.16))-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.type='ORTHO';camera.data.ortho_scale=4.0;scene.camera=camera
for number in range(2,7):
 digit.data.body=str(number);scene.render.filepath=str(OUT/f'calendar-{number}.png');bpy.ops.render.render(write_still=True)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'calendar.blend'))
(OUT/'manifest.json').write_text(json.dumps({'generator':str(Path(__file__).relative_to(ROOT)),'states':[2,3,4,5,6],'blender':bpy.app.version_string,'font':font.filepath if font else 'Bfont','purpose':'Weekly frequency selection, not dates or completed sessions','render':'600px transparent Cycles32'},indent=2))
