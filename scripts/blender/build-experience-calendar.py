"""Reuse the accepted weekly calendar scene for experience duration badges."""
import bpy, math, json, hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'output/blender-experience-calendar';OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'output/blender-calendar/calendar.blend'))
scene=bpy.context.scene;scene.render.resolution_x=600;scene.render.resolution_y=600;scene.cycles.samples=32
scene.camera.data.ortho_scale=3.35
header=bpy.data.objects['Lime binding header'];digit=bpy.data.objects['Weekly session count']
neutral=bpy.data.materials['Neutral charcoal'];lime=bpy.data.materials['Dopafit lime'];white=bpy.data.materials['White numeral']
for material,strength in [(white,.65),(lime,.18)]:
 shader=material.node_tree.nodes.get('Principled BSDF')
 shader.inputs['Emission Color'].default_value=shader.inputs['Base Color'].default_value
 shader.inputs['Emission Strength'].default_value=strength
# Same framing, metal rings, bevelled page and light rig; only the face text/header state change.
digit.data.size=.85;digit.location.z=.11
month=digit.copy();month.data=digit.data.copy();scene.collection.objects.link(month)
month.name='Experience unit';month.data.body='tháng';month.data.size=.36;month.data.extrude=.009;month.data.bevel_depth=.004;month.location.z=-.56
records=[]
for key,value in [('new','<6'),('experienced','6–24'),('advanced','24+')]:
 digit.data.body=value;digit.data.size=.86 if key=='experienced' else 1.1
 for selected in [False,True]:
  header.data.materials[0]=lime if selected else neutral
  digit.data.materials[0]=lime if selected else white
  name=f'experience-calendar-{key}'+('-selected' if selected else '')
  scene.render.filepath=str(OUT/(name+'.png'));bpy.ops.render.render(write_still=True)
  records.append({'name':name,'value':value,'unit':'tháng','selected':selected,'sha256':hashlib.sha256((OUT/(name+'.png')).read_bytes()).hexdigest()})
(OUT/'manifest.json').write_text(json.dumps({'sourceScene':'output/blender-calendar/calendar.blend','generator':'scripts/blender/build-experience-calendar.py','render':'600px RGBA Cycles32; SF font, same camera direction/light rig; tighter3.35 framing and brighter numeral materials','assets':records},ensure_ascii=False,indent=2))
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'experience-calendar.blend'))
