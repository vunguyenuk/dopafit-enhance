# Zenith media audit — 11/11/2026

User completed25primary+22female downloads. This report distinguishes downloaded files, reviewed exercise mappings, generated outputs and UI verification.

## Imported outputs

-47rawsources: all1920×1080;29.97/30fps;5.23–6.64seconds.
-21app exercise pins;19additionalfemale variants;40motionvariants;80MP4.
-720squareguide/240squarethumbnail; originaltiming, no AIframe/interpolation.
-All80decoded fully;40variant samples contain distinct poses.6outputcontact sheets visually inspected.
-Installedfolder has exactly80MP4+manifest, no rejected/stale files.
-126modelchecks andDebugbuild passed. Live UI sample completed after unlock: C172–C178, details below.

## Mapping review

| App ID | Source metadata | Additional female | Note |
|---|---|---|---|
| tbar | Lever T-Bar Row | Yes | Standing straddled lever T-Bar row on foot platform, without chest pad; not chest-supported Machine T Bar. |
| incline | Barbell Incline Bench Press | Yes | Three source timestamps reviewed for exercise, equipment and body position. |
| closebench | Barbell Close Grip Bench Press | No | Three source timestamps reviewed for exercise, equipment and body position. |
| tricep | Cable Rope Triceps Pushdown | Yes | Three source timestamps reviewed for exercise, equipment and body position. |
| squat | Barbell Back Squat | Yes | Three source timestamps reviewed for exercise, equipment and body position. |
| adductor | Lever Seated Hip Adduction | Yes | Three source timestamps reviewed for exercise, equipment and body position. |
| arnold | Dumbbell Arnold Press | Yes | Seated Arnold press with palms turning from inward/front-of-chest to outward overhead; 12-frame sequence reviewed. |
| machinefly | Lever Seated Reverse Fly | Yes | Three source timestamps reviewed for exercise, equipment and body position. |
| frontraise | Cable One Arm Front Raise | Yes | Three source timestamps reviewed for exercise, equipment and body position. |
| dumbbell-row | Dumbbell Bent-Over Row | Yes | Bench-supported unilateral dumbbell row; one hand and same-side knee support bench. Source filename/metadata mislabelled two-arm bent-over row. |
| dumbbell-skullcrusher | Dumbbell Lying Triceps Extension | Yes | Three source timestamps reviewed for exercise, equipment and body position. |
| ez-curl | EZ Bar Biceps Curl | Yes | Three source timestamps reviewed for exercise, equipment and body position. |
| dumbbell-curl | Dumbbell Biceps Curl | Yes | Three source timestamps reviewed for exercise, equipment and body position. |
| dumbbell-shrug | Dumbbell Shrug | Yes | Three source timestamps reviewed for exercise, equipment and body position. |
| incline-dumbbell-curl | Dumbbell Incline Biceps Curl | Yes | Three source timestamps reviewed for exercise, equipment and body position. |
| dumbbell-lateral-raise | Dumbbell Lateral Raise | Yes | Three source timestamps reviewed for exercise, equipment and body position. |
| goblet-squat | Dumbbell Goblet Squat | Yes | Three source timestamps reviewed for exercise, equipment and body position. |
| discovery-crunch | Floor Crunch | No; base female | Three source timestamps reviewed for exercise, equipment and body position. |
| discovery-pushup | Push-Up | Yes | Three source timestamps reviewed for exercise, equipment and body position. |
| discovery-wristcurl | Dumbbell Over Bench Wrist Curl | Yes | Three source timestamps reviewed for exercise, equipment and body position. |
| discovery-bodysquat | Squat | Yes | Three source timestamps reviewed for exercise, equipment and body position. |

## Excluded candidates

| Candidate | Reason |
|---|---|
| discovery-glutebridge | Source shows forearm-plank hip raise, not supine glute bridge. |
| reversefly | Source uses bilateral cable reverse fly; catalog is single-arm cable reverse fly. |
| dumbbell-shoulder-press | Source is seated shoulder press; current approved catalog guide is standing overhead dumbbell press A6wtbuL. Keep existing exact standing clip. |
| rdl | Source specifically straight-leg deadlift, not verified as Romanian deadlift with knee flexion; keep existing pinned RDL. |

## Remaining media gaps

4library IDs without motion:facepull,shrug(trapbar),reversefly(singlearm),bandface. Onepreset missing:discovery-glutebridge. Bodyweightsquat now has reviewed motion. ExistingPexelsPlank stays separate. ExerciseDB33pins kept as fallback; never count overlaypins as extraexercises.

## Evidence and current data

Source probes/screens:verification/zenith-2026-11-11/source-probe.json and sources-1…7.jpg. Outputreview.json and outputs-1…6.jpg contain sampled poses. Source mappings/rejections:third_party/zenith-video/mapping-review.json. Runtimebundlemanifest:ExerciseMedia/zenith/zenith-manifest.json.
Main7draft/notstarted/0logged/2history, planNam/checkinPain preserved exactly against11/11main-state-before.json. Do not restore older snapshots.
Media origin/license remains unresolved as recorded by existing project; localdemo use only, no publication.
Full anatomy/biomechanics, UIrenderFPS, allprofiles/accessibility remain unverified.

## Live UI completion07:18
C172mainHome thumbnails; C173maleRowfullwidthguide; C1740.5speed/changedpose. C175femaleQAHome; C176femaleRowguide; C177muscles tab preservesguide andchangedpose; C178femaleRowsetentry afterQAstart. Separate com.local.dopafit.zenithqa had0loggedsets/0history, then removed. Main fullstate remains exact; planNam, checkinPain,7notstarteddraft/2history. See verification/zenith-2026-11-11/live-ui-run.json and integration.json. These are sampledroutes, not all21UIvideos or measuredFPS.
