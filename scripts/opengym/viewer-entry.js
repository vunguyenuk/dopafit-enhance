import * as THREE from 'three';
import {GLTFLoader} from 'three/addons/loaders/GLTFLoader.js';
import {OrbitControls} from 'three/addons/controls/OrbitControls.js';
let renderer,scene,camera,controls,mixer,model,speed=1,angle=0,loadVersion=0,dirty=true,duration=1;
let heat={},heatSignature='',pulseAllowed=true,muscleMeshes=[];
let cameraAngle=null,cameraRadius=3;
const clock=new THREE.Clock(),pulseUniform={value:1};
const resting=new THREE.Color('#c0c3c1'),active=new THREE.Color('#ff752d');
function status(value){window.webkit?.messageHandlers?.opengym?.postMessage(value);}
function dispose(object){object.traverse(n=>{n.geometry?.dispose();for(const m of [].concat(n.material||[]))m.dispose();});}
function applyHeat(){
 for(const {mesh,names,masks,activation} of muscleMeshes){
  for(let i=0;i<activation.count;i++){
   let value=0;
   for(let k=0;k<names.length;k++)value=Math.max(value,(heat[names[k]]||0)*masks[Math.floor(k/4)].array[i*4+k%4]);
   activation.array[i]=Math.min(1,Math.max(0,value));
  }
  activation.needsUpdate=true;
 }
 dirty=true;
}
function prepareMuscles(gltf){
 muscleMeshes=[];
 const names=gltf.parser.json.extras?.openGymMuscleNames;
 if(!names||names.length!==16)throw Error('Missing muscle mask schema');
 gltf.scene.traverse(mesh=>{
  if(!mesh.isSkinnedMesh)return; // Implements cannot light up as muscles.
  const masks=[0,1,2,3].map(i=>mesh.geometry.getAttribute('_muscle_'+i));
  if(masks.some(a=>!a))throw Error('Missing muscle weights');
  const activation=new THREE.BufferAttribute(new Float32Array(mesh.geometry.attributes.position.count),1);
  mesh.geometry.setAttribute('activeMuscle',activation);
  for(const source of [].concat(mesh.material)){
   source.color.set('#c0c3c1');source.metalness=0;source.roughness=.66;
   source.onBeforeCompile=shader=>{
    shader.uniforms.uMusclePulse=pulseUniform;shader.uniforms.uRestColor={value:resting};shader.uniforms.uActiveColor={value:active};
    shader.vertexShader=shader.vertexShader.replace('#include <common>','#include <common>\nattribute float activeMuscle;\nvarying float vActiveMuscle;').replace('#include <begin_vertex>','#include <begin_vertex>\nvActiveMuscle=activeMuscle;');
    shader.fragmentShader=shader.fragmentShader.replace('#include <common>','#include <common>\nuniform float uMusclePulse;\nuniform vec3 uRestColor;\nuniform vec3 uActiveColor;\nvarying float vActiveMuscle;').replace('#include <color_fragment>','#include <color_fragment>\ndiffuseColor.rgb=mix(uRestColor,uActiveColor,clamp(vActiveMuscle*(0.78+0.22*uMusclePulse),0.0,1.0));').replace('#include <emissivemap_fragment>','#include <emissivemap_fragment>\ntotalEmissiveRadiance+=uActiveColor*vActiveMuscle*(0.01+0.04*uMusclePulse);');
   };
   source.customProgramCacheKey=()=> 'opengym-muscle-pulse-v1';source.needsUpdate=true;
  }
  muscleMeshes.push({mesh,names,masks,activation});
 });
 if(!muscleMeshes.length)throw Error('No skinned muscle model');
 applyHeat();
}
window.openGymLoad=function(base64){
 const version=++loadVersion;
 try{
  if(!renderer){
   renderer=new THREE.WebGLRenderer({antialias:true,alpha:true});renderer.setPixelRatio(Math.min(devicePixelRatio,1.5));document.body.appendChild(renderer.domElement);
   renderer.debug.onShaderError=()=>status('error:Muscle shader could not compile');
   renderer.domElement.addEventListener('webglcontextlost',event=>{event.preventDefault();status('error:Graphics context lost');});
   scene=new THREE.Scene();scene.add(new THREE.HemisphereLight(0xe6efff,0x526078,3));const light=new THREE.DirectionalLight(0xffffff,3);light.position.set(3,4,4);scene.add(light);
   const fill=new THREE.DirectionalLight(0xdce8ff,2.2);fill.position.set(-3,2,-4);scene.add(fill);renderer.toneMapping=THREE.ACESFilmicToneMapping;renderer.toneMappingExposure=1.25;
   camera=new THREE.PerspectiveCamera(36,1,.01,30);controls=new OrbitControls(camera,renderer.domElement);controls.enablePan=false;controls.enableDamping=true;controls.addEventListener('change',()=>{dirty=true;});
   const resize=()=>{renderer.setSize(innerWidth,innerHeight);camera.aspect=innerWidth/Math.max(1,innerHeight);camera.updateProjectionMatrix();dirty=true;};addEventListener('resize',resize);resize();
   document.addEventListener('visibilitychange',()=>{clock.getDelta();dirty=true;});
   renderer.setAnimationLoop(()=>{
    const delta=Math.min(clock.getDelta(),.05);if(document.hidden)return;
    if(mixer&&speed>0){mixer.update(delta*speed);dirty=true;}
    const phase=mixer ? (mixer.time%duration)/duration:0;
    pulseUniform.value=pulseAllowed&&speed>0 ? .5-.5*Math.cos(phase*Math.PI*2):1;
    controls.update();if(dirty){renderer.render(scene,camera);dirty=false;}
   });
  }
  const binary=atob(base64),bytes=new Uint8Array(binary.length);for(let i=0;i<binary.length;i++)bytes[i]=binary.charCodeAt(i);
  new GLTFLoader().parse(bytes.buffer,'',gltf=>{
   if(version!==loadVersion){dispose(gltf.scene);return;}
   // Mixing two clips on one skeleton caused the old gesture deformation.
   if(gltf.animations.length!==1){dispose(gltf.scene);status('error:Expected one synchronized exercise clip');return;}
   try{
    if(model){mixer?.stopAllAction();mixer?.uncacheRoot(model);scene.remove(model);dispose(model);}
    model=gltf.scene;prepareMuscles(gltf);scene.add(model);mixer=new THREE.AnimationMixer(model);const clip=gltf.animations[0];duration=Math.max(.01,clip.duration);mixer.clipAction(clip).setLoop(THREE.LoopRepeat).play();mixer.update(0);model.updateMatrixWorld(true);
    // Fit the entire motion, including implements approaching the camera at a
    // side angle. A first-frame height fit clipped Good Morning's near plate.
    const box=new THREE.Box3();
    for(let i=0;i<13;i++){
     mixer.setTime(duration*i/13);model.updateMatrixWorld(true);
     model.traverse(n=>{if(n.isSkinnedMesh){n.skeleton.update();n.computeBoundingBox();}});
     box.union(new THREE.Box3().setFromObject(model));
    }
    mixer.setTime(0);model.updateMatrixWorld(true);
    const center=box.getCenter(new THREE.Vector3()),sphere=box.getBoundingSphere(new THREE.Sphere());
    const halfFov=Math.atan(Math.tan(THREE.MathUtils.degToRad(camera.fov/2))*Math.min(1,camera.aspect));
    cameraRadius=sphere.radius/Math.sin(halfFov)*1.12;
    controls.target.copy(center);cameraAngle=null;window.openGymUpdate(speed,angle,heat,pulseAllowed);status('ready');
   }catch(error){status('error:'+String(error));}
  },error=>status('error:'+String(error)));
 }catch(error){status('error:'+String(error));}
};
window.openGymUpdate=function(value,newAngle,newHeat,allowPulse){
 speed=value;angle=newAngle;
 if(newHeat){const signature=JSON.stringify(newHeat);if(signature!==heatSignature){heatSignature=signature;heat=newHeat;applyHeat();}}
 if(typeof allowPulse==='boolean')pulseAllowed=allowPulse;
 if(camera&&controls&&cameraAngle!==angle){cameraAngle=angle;const a=angle*Math.PI/2;camera.position.set(controls.target.x+Math.sin(a)*cameraRadius,controls.target.y+.1,controls.target.z+Math.cos(a)*cameraRadius);controls.update();}
 dirty=true;
};
