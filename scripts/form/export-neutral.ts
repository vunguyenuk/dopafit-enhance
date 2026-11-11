import {writeFileSync,readFileSync} from 'node:fs';
import * as THREE from 'three';
import {AnatomicalHuman} from '../../third_party/exercise-animations/upstream/src/character/human';
import {reviewPose} from '../../third_party/exercise-animations/upstream/src/character/review-poses';
import atlasMeta from '../../third_party/exercise-animations/upstream/src/highlighting/generated/atlas.json';
const human=new AnatomicalHuman();await human.ready;human.update(reviewPose('neutral'));
const geometry=human.mesh!.geometry,p=geometry.getAttribute('position'),positions=new Float32Array(p.count*3),point=new THREE.Vector3();
for(let i=0;i<p.count;i++){point.fromBufferAttribute(p,i);human.mesh!.applyBoneTransform(i,point);point.toArray(positions,i*3);}
const native=new THREE.BufferGeometry();native.setAttribute('position',new THREE.BufferAttribute(positions,3));native.setIndex(geometry.index!.clone());native.computeVertexNormals();
const names=['Bụng','Mông','Đùi sau','Đùi trước','Lưng dưới','Ngực','Tay sau','Tay trước','Vai','Lưng','Bắp chân','Cơ thang','Cơ dạng hông','Cơ khép hông','Cẳng tay','Cổ'];
const direct:{[key:string]:string[]}={'Bụng':['abs'],'Mông':['glutes'],'Đùi sau':['hamstrings'],'Đùi trước':['quads'],'Ngực':['chest'],'Tay sau':['triceps'],'Tay trước':['biceps'],'Vai':['deltoids'],'Lưng':['back','lats'],'Bắp chân':['calves']};
const atlas=new Uint8Array(readFileSync('third_party/exercise-animations/upstream/src/highlighting/generated/atlas.bin'));
const masks=Array.from({length:4},()=>new Float32Array(p.count*4));
function band(v:number,lo:number,hi:number,fade=.035){return Math.max(0,Math.min(1,(v-lo)/fade,(hi-v)/fade));}
for(let i=0;i<p.count;i++)for(let k=0;k<16;k++){
 let amount=0;for(const id of direct[names[k]]??[]){amount=Math.max(amount,atlas[i*11+atlasMeta.groups.indexOf(id)]/255);}
 // Six extra Dopafit labels have no upstream atlas. These remain approximate,
 // explicitly tracked regions, never aliases to an unrelated full muscle.
 const x=Math.abs(positions[i*3]),y=positions[i*3+1],z=positions[i*3+2];
 if(k===4&&z<-.035)amount=band(y,1.0,1.23)*band(x,0,.16,.02);
 if(k===11&&z<0)amount=band(y,1.40,1.59)*band(x,0,.22,.02);
 if(k===12)amount=band(y,.85,1.02)*band(x,.15,.25,.025);
 if(k===13)amount=band(y,.53,.84)*band(x,.01,.12,.02);
 if(k===14)amount=band(y,.91,1.14)*band(x,.23,.39,.025);
 if(k===15)amount=band(y,1.51,1.63)*band(x,0,.09,.015);
 masks[Math.floor(k/4)][i*4+k%4]=amount;
}
const chunks:Buffer[]=[],views:any[]=[],accessors:any[]=[];let offset=0;
function add(array:TypedArray,type:string,componentType:number){const bytes=Buffer.from(array.buffer,array.byteOffset,array.byteLength);const index=views.length;views.push({buffer:0,byteOffset:offset,byteLength:bytes.length});chunks.push(bytes);offset+=bytes.length;const pad=(4-offset%4)%4;if(pad){chunks.push(Buffer.alloc(pad));offset+=pad;}const a:any={bufferView:index,componentType,count:array.length/({VEC3:3,VEC4:4,SCALAR:1}[type]!),type};if(type==='VEC3'&&accessors.length===0){a.min=[0,1,2].map(c=>Math.min(...Array.from({length:p.count},(_,i)=>array[i*3+c])));a.max=[0,1,2].map(c=>Math.max(...Array.from({length:p.count},(_,i)=>array[i*3+c])));}return accessors.push(a)-1;}
const attrs:any={POSITION:add(positions,'VEC3',5126),NORMAL:add(native.getAttribute('normal').array,'VEC3',5126)};
for(let k=0;k<4;k++)attrs['_MUSCLE_'+k]=add(masks[k],'VEC4',5126);
const indices=add(new Uint32Array(geometry.index!.array),'SCALAR',5125);
const root={asset:{version:'2.0',generator:'Dopafit Form neutral snapshot'},extras:{openGymMuscleNames:names,formStyle:true,approximateExtraRegions:names.filter(n=>!direct[n])},buffers:[{byteLength:offset}],bufferViews:views,accessors,meshes:[{primitives:[{attributes:attrs,indices}]}],nodes:[{mesh:0}],scenes:[{nodes:[0]}],scene:0};
const json=Buffer.from(JSON.stringify(root)),jp=Buffer.concat([json,Buffer.alloc((4-json.length%4)%4,32)]),bin=Buffer.concat(chunks),out=Buffer.alloc(12+8+jp.length+8+bin.length);out.writeUInt32LE(0x46546c67,0);out.writeUInt32LE(2,4);out.writeUInt32LE(out.length,8);out.writeUInt32LE(jp.length,12);out.writeUInt32LE(0x4e4f534a,16);jp.copy(out,20);out.writeUInt32LE(bin.length,20+jp.length);out.writeUInt32LE(0x004e4942,24+jp.length);bin.copy(out,28+jp.length);writeFileSync('DopafitRebuild/Form3D/neutral.glb',out);console.log(`Form neutral: ${p.count} vertices / ${geometry.index!.count/3} triangles / ${out.length} bytes`);human.dispose();
