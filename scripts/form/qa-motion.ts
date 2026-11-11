import {writeFileSync} from 'node:fs';
import * as THREE from 'three';
import {ExerciseScene} from '../../third_party/exercise-animations/upstream/src/engine/scene';
import {AnatomicalHuman} from '../../third_party/exercise-animations/upstream/src/character/human';
import {exercises} from '../../third_party/exercise-animations/upstream/src/data/exercises';
import {defaultRecipe} from '../../third_party/exercise-animations/upstream/src/engine/recipe';
import {createBarbell,createBench,createDumbbell,createRack} from '../../third_party/exercise-animations/upstream/src/engine/models';
import {analyzeMotion} from '../../third_party/exercise-animations/upstream/src/physics/dynamics';
const results=[];
for(const exercise of exercises){
 const human=new AnatomicalHuman();await human.ready;
 const scene:any=Object.create(ExerciseScene.prototype);scene.exercise=exercise;scene.recipe=defaultRecipe(exercise);scene.human=human;
 scene.dumbbells=[createDumbbell(),createDumbbell()];scene.barbell=createBarbell();scene.bench=createBench();scene.rack=createRack();scene.scene=new THREE.Scene();
 scene.scene.add(human.group,...scene.dumbbells,scene.barbell,scene.bench,scene.rack);
 scene.dumbbells.forEach((d:any,i:number)=>{d.name=i?'right-dumbbell':'left-dumbbell';d.visible=exercise.equipment.includes('dumbbells')&&!(exercise.motion==='goblet-squat'&&i===1);});
 if(exercise.motion==='goblet-squat'){scene.dumbbells[0].name='goblet-dumbbell';scene.dumbbells[0].traverse((o:any)=>{if(o.name==='right-head')o.userData.contactRole='goblet-head';});}
 scene.barbell.visible=exercise.equipment.includes('barbell');scene.bench.visible=exercise.equipment.includes('incline-bench');scene.rack.visible=exercise.equipment.includes('rack');
 scene.barbell.traverse((o:any)=>{if(o.name==='shaft')o.userData.upperBackSupport=exercise.motion==='back-squat';});
 human.setGrip(1);human.setGripRadius(exercise.equipment.includes('barbell')?.017:.018);
 const failures:any[]=[],v=new THREE.Vector3();let minY=Infinity,maxY=-Infinity,maxEdge=0,maxGripGap=0;
 const mesh=human.mesh!,positions=mesh.geometry.getAttribute('position'),index=mesh.geometry.index!;
 for(let i=0;i<=32;i++){
  const phase=i/32,pose=scene.update(phase),grips=scene.checkGrips(),contacts=scene.checkContacts();
  const dynamics=analyzeMotion(exercise,phase,1,{duration:scene.recipe.duration,profile:'controlled',loadKg:scene.recipe.loadKg},pose);
  const bad=contacts.filter((c:any)=>!c.allowed),loose=grips.filter((g:any)=>!g.valid);
  if(bad.length||loose.length||!dynamics.supported)failures.push({phase,contacts:bad,grips:loose,supported:dynamics.supported});
  for(let k=0;k<positions.count;k++){mesh.getVertexPosition(k,v);if(!Number.isFinite(v.lengthSq()))throw Error('Non-finite skinning');minY=Math.min(minY,v.y);maxY=Math.max(maxY,v.y);}
 }
 results.push({id:exercise.id,samples:33,minY,maxY,failures});human.dispose();console.log(exercise.id,failures.length?'FAIL':'PASS');
}
writeFileSync('rebuild/verification/form-motion-qa.json',JSON.stringify({upstream:'be16cb22c4ceb4ad134894250062fd0782410233',scope:'CPU deformation/contact/grip/balance at default recipe, 33 phases per exercise. Not GPU/performance or complete clinical form verification.',results},null,2));
if(results.some(r=>r.failures.length))process.exitCode=1;
