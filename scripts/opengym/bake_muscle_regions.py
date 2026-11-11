#!/usr/bin/env python3
"""Bake shared soft muscle masks into body GLB attributes for both renderers.
Masks are approximations derived from MakeHuman skin territories, not clinical
anatomy segmentations. Prop meshes receive no mask and cannot flash.
"""
import json,struct,math,sys
from pathlib import Path
NAMES=['Bụng','Mông','Đùi sau','Đùi trước','Lưng dưới','Ngực','Tay sau','Tay trước','Vai','Lưng','Bắp chân','Cơ thang','Cơ dạng hông','Cơ khép hông','Cẳng tay','Cổ']
def smooth(a,b,x):
 t=max(0,min(1,(x-a)/(b-a)));return t*t*(3-2*t)
def band(x,a,b,edge=.035):return smooth(a-edge,a,x)*(1-smooth(b,b+edge,x))
def regions(p,n,b,height):
 x,y,z=p;y=y/height*1.8;x=x/height*1.8;z=z/height*1.8
 front=smooth(-.025,.025,z);back=1-front;r={}
 if b.startswith('neck'):r['Cổ']=band(y,1.48,1.59)
 elif b in ['shoulder01','upperarm01']:r['Vai']=1
 elif b=='upperarm02':r.update({'Tay trước':front,'Tay sau':back})
 elif b.startswith('lowerarm'):r['Cẳng tay']=1
 elif b.startswith('lowerleg'):r['Bắp chân']=1
 elif b.startswith('upperleg'):
  glute=back*band(y,.82,1.0);r.update({'Mông':glute,'Đùi trước':front*(1-glute),'Đùi sau':back*(1-glute),'Cơ dạng hông':smooth(.13,.19,abs(x))*band(y,.48,.94),'Cơ khép hông':(1-smooth(.09,.145,abs(x)))*band(y,.48,.94)})
 elif b.startswith(('spine','pelvis','breast','clavicle')):
  r.update({'Ngực':front*band(y,1.24,1.46),'Bụng':front*band(y,.98,1.24),'Mông':back*band(y,.82,1.0),'Lưng dưới':back*band(y,.98,1.14),'Lưng':back*band(y,1.10,1.38),'Cơ thang':back*band(y,1.38,1.54)})
 return r

def bake(path):
 data=path.read_bytes();length=struct.unpack_from('<I',data,12)[0];g=json.loads(data[20:20+length]);binary=bytearray(data[28+length:]);types={5121:('B',1),5123:('H',2),5125:('I',4),5126:('f',4)}
 def values(index,components):
  a=g['accessors'][index];v=g['bufferViews'][a['bufferView']];fmt,width=types[a['componentType']];offset=v.get('byteOffset',0)+a.get('byteOffset',0);stride=v.get('byteStride',width*components)
  return [struct.unpack_from('<'+fmt*components,binary,offset+i*stride) for i in range(a['count'])]
 body_count=0;counts=[0]*16
 for node in g['nodes']:
  if 'skin' not in node or 'mesh' not in node:continue
  joints=g['skins'][node['skin']]['joints'];bones=[g['nodes'][j].get('name','').split('.')[0] for j in joints]
  for primitive in g['meshes'][node['mesh']]['primitives']:
   a=primitive['attributes'];p=values(a['POSITION'],3);norm=values(a['NORMAL'],3);j=values(a['JOINTS_0'],4);w=values(a['WEIGHTS_0'],4);height=max(v[1] for v in p);masks=[]
   for i,point in enumerate(p):
    result=[0.0]*16
    for joint,weight in zip(j[i],w[i]):
     if weight<=0:continue
     for name,value in regions(point,norm[i],bones[joint],height).items():result[NAMES.index(name)]+=weight*value
    result=[max(0,min(1,x)) for x in result];masks.append(result)
    for k,v in enumerate(result):counts[k]+=v>.15
   for slot in range(4):
    if '_MUSCLE_'+str(slot) in a:
     existing=g['accessors'][a['_MUSCLE_'+str(slot)]];view=g['bufferViews'][existing['bufferView']]
     assert existing['count']==len(masks) and existing['componentType']==5126
     offset=view.get('byteOffset',0)+existing.get('byteOffset',0)
     for i,mask in enumerate(masks):struct.pack_into('<4f',binary,offset+i*16,*mask[slot*4:slot*4+4])
     continue
    while len(binary)%4:binary.append(0)
    offset=len(binary)
    for mask in masks:binary.extend(struct.pack('<4f',*mask[slot*4:slot*4+4]))
    view=len(g['bufferViews']);g['bufferViews'].append({'buffer':0,'byteOffset':offset,'byteLength':len(masks)*16,'target':34962})
    accessor=len(g['accessors']);g['accessors'].append({'bufferView':view,'componentType':5126,'count':len(masks),'type':'VEC4'});a['_MUSCLE_'+str(slot)]=accessor
   body_count+=1
 g.setdefault('extras',{})['openGymMuscleNames']=NAMES;g['extras']['openGymMuscleMaskVersion']=1;g['buffers'][0]['byteLength']=len(binary)
 js=json.dumps(g,separators=(',',':'),ensure_ascii=True).encode()
 while len(js)%4:js+=b' '
 while len(binary)%4:binary.append(0)
 final=struct.pack('<III',0x46546c67,2,12+8+len(js)+8+len(binary))+struct.pack('<II',len(js),0x4e4f534a)+js+struct.pack('<II',len(binary),0x004e4942)+binary;path.write_bytes(final)
 assert body_count>=1 and all(n>2 for n in counts),(path.name,counts)
 return {'file':path.name,'skinnedPrimitives':body_count,'verticesAbove15Percent':dict(zip(NAMES,counts))}
if __name__=='__main__':
 folder=Path(sys.argv[1]) if len(sys.argv)>1 else Path('.build/opengym-refined');reports=[bake(p) for p in sorted(folder.glob('*.glb'))];(folder/'muscle-mask-report.json').write_text(json.dumps(reports,ensure_ascii=False,indent=2)+'\n');print('Baked masks:',len(reports),'GLBs')
