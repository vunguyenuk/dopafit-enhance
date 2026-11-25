"""Render a physical leaf turning around its top binding; reverse frames for decreasing days."""
import bpy,math,json
from pathlib import Path
from mathutils import Matrix,Vector
ROOT=Path(__file__).resolve().parents[2]; OUT=ROOT/'output/blender-calendar/flip'; OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'output/blender-calendar/calendar.blend'))
scene=bpy.context.scene;scene.render.resolution_x=400;scene.render.resolution_y=400;scene.cycles.samples=24
front=bpy.data.objects['Calendar face'];digit=bpy.data.objects['Weekly session count'];front.hide_render=True;digit.hide_render=True
# A thin, flexible-looking page sits on top of the charcoal base. Header/rings remain fixed.
page=front.copy();page.data=front.data.copy();scene.collection.objects.link(page);page.name='Turning leaf';page.hide_render=False
page.scale.y=.15;page.scale.z=.79;page.location.y=-.40;page.location.z=-.33
text=digit.copy();text.data=digit.data.copy();scene.collection.objects.link(text);text.hide_render=False;text.location.y=-.45
bpy.context.view_layer.update()
pivot=Vector((0,-.21,.85));rest_page=page.matrix_world.copy();rest_text=text.matrix_world.copy()
base=digit.copy();base.data=digit.data.copy();scene.collection.objects.link(base);base.hide_render=False
front.hide_render=False
# Film includes a small upward margin only during the leaf turn. Camera stays unchanged.
frames=16
for number in range(2,6):
 base.data.body=str(number+1);text.data.body=str(number)
 for f in range(frames):
  t=f/(frames-1);e=1-(1-t)**2
  angle=-math.pi*e
  rot=Matrix.Translation(pivot)@Matrix.Rotation(angle,4,'X')@Matrix.Translation(-pivot)
  page.matrix_world=rot@rest_page;text.matrix_world=rot@rest_text
  # The page finishes behind the binding/back, rather than hovering above the calendar.
  page.hide_render=text.hide_render=(t>.78)
  scene.render.filepath=str(OUT/f'calendar-flip-{number}-{f:02d}.png');bpy.ops.render.render(write_still=True)
(OUT/'manifest.json').write_text(json.dumps({'generator':'scripts/blender/build-calendar-flip.py','transitions':[[n,n+1] for n in range(2,6)],'frames':frames,'size':400,'duration':.42,'decreasing':'reverse same physical sequence','reduceMotion':'static selected digit','note':'authored raster sequence, not runtime mesh or measured display FPS'},indent=2))
