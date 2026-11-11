// Exercise the same Three.js loader/skinning path without a browser or GPU.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../..');
const moduleRoot=pathToFileURL(root+'/.build/opengym-viewer-tools/node_modules/three/');
const THREE=await import(new URL('build/three.module.js',moduleRoot));
const {GLTFLoader}=await import(new URL('examples/jsm/loaders/GLTFLoader.js',moduleRoot));
const assert=(value,message)=>{if(!value)throw Error(message);};
const results=[];
for(const name of ['bicep_curl','romanian_deadlift','good_morning']){
 const bytes=fs.readFileSync(root+'/DopafitRebuild/OpenGym3D/models/'+name+'.glb');
 const gltf=await new Promise((resolve,reject)=>new GLTFLoader().parse(bytes.buffer.slice(bytes.byteOffset,bytes.byteOffset+bytes.byteLength),'',resolve,reject));
 assert(gltf.animations.length===1,name+': clip count');
 const names=gltf.parser.json.extras.openGymMuscleNames;
 assert(names.length===16,name+': mask schema');
 const bodies=[],props=[];
 gltf.scene.traverse(mesh=>{if(mesh.isSkinnedMesh)bodies.push(mesh);else if(mesh.isMesh)props.push(mesh);});
 assert(bodies.length>0&&props.length>0,name+': body and implements');
 for(const mesh of bodies){
  const masks=[0,1,2,3].map(i=>mesh.geometry.getAttribute('_muscle_'+i));
  assert(masks.every(Boolean),name+': loader custom attributes');
  for(let k=0;k<16;k++)assert(masks[Math.floor(k/4)].array.some((v,i)=>i%4===k%4&&v>.15),name+': empty '+names[k]);
 }
 for(const mesh of props)assert(!mesh.geometry.getAttribute('_muscle_0'),name+': implement must not glow');
 const mixer=new THREE.AnimationMixer(gltf.scene),clip=gltf.animations[0];mixer.clipAction(clip).play();
 let pointsChecked=0;
 for(const phase of [0,.25,.5,.75,.999]){
  mixer.setTime(clip.duration*phase);gltf.scene.updateMatrixWorld(true);
  for(const mesh of bodies){
   mesh.skeleton.update();const positions=mesh.geometry.getAttribute('position');
   for(let i=0;i<positions.count;i++){
    const p=mesh.applyBoneTransform(i,new THREE.Vector3().fromBufferAttribute(positions,i));
    assert(Number.isFinite(p.x)&&Number.isFinite(p.y)&&Number.isFinite(p.z),name+': non-finite skin');pointsChecked++;
   }
  }
 }
 results.push({name,clip:clip.name,duration:clip.duration,skinnedMeshes:bodies.length,implementPrimitives:props.length,pointsChecked,pass:true});
}
const output=JSON.stringify({engine:THREE.REVISION,scope:'CPU loader/skinning only; no GPU shader or native UI validation',models:results},null,2)+'\n';
fs.writeFileSync(root+'/rebuild/verification/three-runtime-qa.json',output);console.log(output);
