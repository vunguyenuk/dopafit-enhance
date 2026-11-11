// Dopafit adapter. The pinned upstream stays untouched and separately attributed.
import * as THREE from 'three';
import {ExerciseScene} from '../../third_party/exercise-animations/upstream/src/engine/scene';
import {defaultRecipe} from '../../third_party/exercise-animations/upstream/src/engine/recipe';
import {loadMuscleAtlas} from '../../third_party/exercise-animations/upstream/src/highlighting/atlas';
import {muscleGroups} from '../../third_party/exercise-animations/upstream/src/highlighting/groups';
import {getExercise} from '../../third_party/exercise-animations/upstream/src/data/exercises';
let scene:ExerciseScene|undefined,version=0,speed=1,angle=0,phase=0,last=0,pulse=true,failed=false;
let heat:Record<string,number>={},heatSignature='',atlas:any;
const labels:Record<string,string>={biceps:'Tay trước',triceps:'Tay sau',deltoids:'Vai',chest:'Ngực',back:'Lưng',lats:'Lưng',abs:'Bụng',glutes:'Mông',quads:'Đùi trước',hamstrings:'Đùi sau',calves:'Bắp chân'};
function applyHeat(){if(!scene?.human.mesh||!atlas)return;const a=scene.human.mesh.geometry.getAttribute('highlightAmount') as THREE.BufferAttribute;for(let i=0;i<a.count;i++){let value=0;for(let k=0;k<muscleGroups.length;k++)value=Math.max(value,(heat[labels[muscleGroups[k]]]??0)*atlas.data[i*muscleGroups.length+k]/255);a.array[i]=Math.min(1,value);}a.needsUpdate=true;}
const send=(s:string)=>window.webkit?.messageHandlers?.opengym?.postMessage(s);
const views=['front','side','back','three-quarter'] as const;
const pulseUniform={value:1};
function fit(){
 if(!scene)return;
 scene.setView(views[angle%4]);
 const bounds=new THREE.Box3();
 for(let i=0;i<17;i++){scene.update(i/17);scene.human.mesh!.computeBoundingBox();bounds.union(new THREE.Box3().setFromObject(scene.human.group));for(const object of scene.equipmentObjects)if(object.visible)bounds.union(new THREE.Box3().setFromObject(object));}
 const center=bounds.getCenter(new THREE.Vector3()),sphere=bounds.getBoundingSphere(new THREE.Sphere());
 const fov=Math.atan(Math.tan(THREE.MathUtils.degToRad(scene.camera.fov/2))*Math.min(1,scene.camera.aspect));
 const direction=scene.camera.position.clone().sub(scene.controls.target).normalize();
 scene.controls.target.copy(center);scene.camera.position.copy(center).addScaledVector(direction,sphere.radius/Math.sin(fov)*1.08);scene.controls.update();
}
window.openGymLoad=async(id:string)=>{
 const current=++version;failed=false;scene?.dispose();scene=undefined;phase=0;last=0;
 try{
  const exercise=getExercise(id),recipe=defaultRecipe(exercise);recipe.background='transparent';recipe.view=views[angle%4];
  const instance=new ExerciseScene(document.body,exercise,recipe,false);scene=instance;
  instance.renderer.setPixelRatio(Math.min(devicePixelRatio,1.5));instance.renderer.shadowMap.enabled=false;
  instance.renderer.setClearColor('#17191c',1);
  instance.renderer.domElement.addEventListener('webglcontextlost',e=>{e.preventDefault();failed=true;send('error:Graphics context lost');});
  instance.renderer.debug.onShaderError=()=>{failed=true;send('error:Muscle shader failed');};
  await instance.ready;atlas=await loadMuscleAtlas();if(current!==version){instance.dispose();return;}
  // Decorate the upstream material hook rather than mutating its geometry/rig.
  const material=instance.human.material,original=material.onBeforeCompile;
  material.onBeforeCompile=function(shader,renderer){original.call(this,shader,renderer);shader.uniforms.dopaPulse=pulseUniform;shader.fragmentShader='uniform float dopaPulse;\n'+shader.fragmentShader;shader.fragmentShader=shader.fragmentShader.replace('formOrange,vFormHighlight','formOrange,vFormHighlight*dopaPulse');};
  material.customProgramCacheKey=()=> 'dopafit-form-pulse-v1';material.needsUpdate=true;
  applyHeat();fit();instance.render(phase);if(failed)return;send('ready');
  instance.renderer.setAnimationLoop(now=>{
   const delta=last ? Math.min(.05,(now-last)/1000):0;last=now;
   if(document.hidden||failed||speed<=0)return;
   phase=(phase+delta*speed/recipe.duration)%1;
   pulseUniform.value=pulse ? .72+.28*(.5-.5*Math.cos(phase*Math.PI*2)):1;
   try{instance.render(phase);}catch(error){failed=true;send('error:'+String(error));}
  });
 }catch(error){failed=true;send('error:'+String(error));}
};
window.openGymUpdate=(value:number,newAngle:number,newHeat:Record<string,number>,allowPulse:boolean)=>{
 speed=Math.max(0,Math.min(2,value));pulse=allowPulse!==false;pulseUniform.value=pulse ? pulseUniform.value:1;
 const signature=JSON.stringify(newHeat??{});if(signature!==heatSignature){heatSignature=signature;heat=newHeat??{};applyHeat();}
 if(angle!==newAngle){angle=newAngle;if(scene?.human.mesh){try{fit();scene.render(phase);}catch(error){failed=true;send('error:'+String(error));}}}
};
addEventListener('resize',()=>{if(scene?.human.mesh&&!failed){try{scene.resize();fit();scene.render(phase);}catch(error){failed=true;send('error:'+String(error));}}});
addEventListener('pagehide',()=>{version++;scene?.dispose();scene=undefined;});
