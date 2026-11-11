"""Build a CC0 muscular MakeHuman mesh using the OpenGym3D human-generation stack.
Run in Blender 4.5 with MPFB 2.0.16 extracted under .build/mpfb-2.0.16.
Upstream MIT helper code is used for helper stripping; no upstream main() runs.
"""
import bpy,bmesh,sys,os,importlib.util,json,math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
# Create an ephemeral extension repository; never save Blender preferences.
repo=ROOT/'.build/mpfb-repository';repo.mkdir(exist_ok=True)
link=repo/'mpfb'
if not link.exists():link.symlink_to(ROOT/'.build/mpfb-2.0.16',target_is_directory=True)
bpy.context.preferences.extensions.repos.new(name='Dopafit asset build',module='dopafit_local',custom_directory=str(repo))
import addon_utils,importlib
module='bl_ext.dopafit_local.mpfb'
addon_utils.enable(module,default_set=True)
HumanService=importlib.import_module(module+'.services.humanservice').HumanService
TargetService=importlib.import_module(module+'.services.targetservice').TargetService
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
macro=TargetService.get_default_macro_info_dict();macro.update(gender=1.0,muscle=1.0,weight=0.55,age=0.5,height=0.5,proportions=0.5,cupsize=0.0)
mesh=HumanService.create_human(macro_detail_dict=macro)
print('ACTUAL_MACROS',TargetService.get_macro_info_dict_from_basemesh(mesh),flush=True)
# Explicit anatomical detail targets: visible pecs, deltoids, arms, legs and abs.
# Moderate values avoid extreme bodybuilder bulges or joint intersections.
details={'torso/torso-muscle-pectoral-incr':0.65,'torso/torso-muscle-dorsi-incr':0.55,'stomach/stomach-tone-incr':1.0}
for side in ['l','r']:
 details.update({f'arms/{side}-upperarm-shoulder-muscle-incr':0.55,f'arms/{side}-upperarm-muscle-incr':0.55,f'arms/{side}-lowerarm-muscle-incr':0.35,f'legs/{side}-upperleg-muscle-incr':0.45,f'legs/{side}-lowerleg-muscle-incr':0.45})
for target,weight in details.items():TargetService.load_target(mesh,str(ROOT/'.build/mpfb-2.0.16/data/targets'/(target+'.target.gz')),weight=weight)

# Bake actual macro targets before glTF export; exporting zero-valued Basis was
# the reason the old pack looked like a default mannequin.
bpy.context.view_layer.objects.active=mesh;mesh.select_set(True)
# shape_key_remove(all=True, apply_mix=True) bakes the evaluated shape correctly.
bpy.ops.object.shape_key_remove(all=True,apply_mix=True)
rig=HumanService.add_builtin_rig(mesh,'default')
# OpenGym3D strip_helpers() logic (MIT), kept explicit to avoid running its CLI.
kill={group.index for group in mesh.vertex_groups if group.name in ('HelperGeometry','JointCubes','eye.L','eye.R')}
doomed=[v.index for v in mesh.data.vertices if any(g.group in kill for g in v.groups)]
bm=bmesh.new();bm.from_mesh(mesh.data);bm.verts.ensure_lookup_table()
bmesh.ops.delete(bm,geom=[bm.verts[i] for i in doomed],context='VERTS');bm.to_mesh(mesh.data);bm.free()
for modifier in list(mesh.modifiers):
 if modifier.type=='MASK':mesh.modifiers.remove(modifier)
for poly in mesh.data.polygons:poly.use_smooth=True
mesh.name='OpenGymMuscularHuman';rig.name='OpenGymMuscularRig'
mat=bpy.data.materials.new('Athletic body');mat.diffuse_color=(0.16,0.21,0.27,1);mesh.data.materials.clear();mesh.data.materials.append(mat)
out=ROOT/'.build/opengym-muscular';out.mkdir(exist_ok=True)
# Preserve neutral-rest mesh and the original MakeHuman skin weights.
def export(name):
 bpy.ops.object.select_all(action='DESELECT');mesh.select_set(True);rig.select_set(True);bpy.context.view_layer.objects.active=rig
 bpy.ops.export_scene.gltf(filepath=str(out/name),export_format='GLB',use_selection=True,export_animations=False,export_apply=False,export_morph=False)
export('muscular_body.glb')
bpy.ops.wm.save_as_mainfile(filepath=str(out/'muscular_source.blend'))
(out/'generation.json').write_text(json.dumps({'generator':'MPFB2','version':'2.0.16','macro':macro,'detailTargets':details,'vertices':len(mesh.data.vertices),'polygons':len(mesh.data.polygons),'bones':len(rig.data.bones)},indent=2))
print('MUSCULAR_EXPORT_DONE',len(mesh.data.vertices),len(rig.data.bones),flush=True)
