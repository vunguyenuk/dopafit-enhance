# Exercise media — current local prototype, 10/11/2026

## Latest11/11 — reviewed Zenith demo overlay
21reviewed apppins +19additionalfemale variants,40motionvariants/80MP4.1920×1080source canvas;720guide/240thumb derived with whole-clip bounds and padding, retained source timing. Raw25+22files and hashes retained. No inferred/native-HD claim about old180px fallback clips. Details/acceptance/rejection and QA in ZENITH-MEDIA-AUDIT-2026-11-11.md. Resolution priority remains separate realPlank → reviewed Zenith (preferfemale whereavailable) → existing exact ExerciseDB. Body3D unchanged.
Unilateral Row now uses misnamed source bent-over-row under correct dumbbell-row ID. Actual bilateralRow/RDL/standingpress keep old exactclip. Reversefly andglutebridge rejected. New32library coverage28withmedia/32, presets8/9 (includingseparatePlank); full exactlibrary stillmissing4. Do not reinstate stale24clip outputs. No public release/license-clearance claim.

## Latest22:31–23:00 policy — supersedes historical renderer priority/cap below

27 library +6 preset pins=33;5library unmapped,2preset unmapped. A6wtbuL standing overhead dumbbell press is pinned to dumbbell-shoulder-press, official response at third_party/exercisedb/guide-details/A6wtbuL.json. Reviewed bent-elbow and overhead frames; source180GIF, nativeMP4 repeats source poses, guide720Lanczos+0.35unsharp. No fuzzy/seated substitute.
ExerciseDetail set-entry and ExerciseGuide now show exact local guide videos, replacing exercise3D renderers. Preserve Body anatomy resources; no mesh rework. Missing guide has no static/body image or fake speed/angle controls. All list callers including ExerciseThumb omit media slots without bundled MP4. Per user22:47 video fills width in a square, aspect-fit;220ptcap/C161–C164 are obsolete. This makes exercise larger, cannot recover source detail; HD/FPS claims remain invalid.

27 of32catalog exercises have pinned ExerciseDB GIF+MP4. Mapping is in DopafitRebuild/ExerciseMedia/exercisedb-mapping.json, with source response/provenance in third_party/exercisedb. Never choose fuzzy first-match at runtime: standing landmine T-Bar is not chest-supported Machine T Bar; Trap Bar Shrug is not Barbell Shrug; one-arm bench Row is not two-arm Row. C0MA9bC was visually verified as the bench-supported unilateral Row. Five library variants remain unmapped. Standing shoulder press now uses exact A6wtbuL clip. Missing clips have no image/model placeholder.

Native player: ExerciseLoopVideo, AVQueuePlayer+AVPlayerLooper, muted, aspect-fit, pauses outside active tab/scene/visible thumbnail. Reduce Motion pauses decorative list clips. Guide motion remains intentional. All33 MP4 files are local for offline use; remote fallback only for pinned known GIF URLs. GIF cache validates multiframe data/status/host, deduplicates requests, uses atomic writes and bounded frame-image cache. Original decoder reduced thumbnail frames to120px; now uses up to240px fallback and native video preserves source pixels.

**Quality limit:** source GIFs are180×180px. They contain discrete original poses and often ghost endpoint figures. MP4 uses CFR30 with repeated original frames, CRF12 and no upscale, optical flow, invented anatomy or claim ofHD. This reduces main-thread image animation work but cannot add missing image detail or true motion samples. HD/video source is required for a truly crisp full-width guide. scripts/exercisedb/encode-previews.py reproduces clips; verification/exercise-video-qa.json records hashes/resolution/duration; exercisedb-gif-qa.json verifies multiple decoded/distinct frames. These are not a measured FPS benchmark.

Licensing: official ExerciseDB OSS docs supplied by user (https://oss.exercisedb.dev/docs), saved OpenAPI info.description explicitly allows personal/prototype/non-commercial use, requires attribution to AscendAPI, and excludes monetized/commercial use without a paid RapidAPI plan. Credit added in Settings → Về Dopafit. Bundle is a local non-commercial prototype. Keep this limitation separate from Form's project-code license gap. Do not publish until rights/source availability is resolved. No original Dopafit private video is claimed.

UI checks C65–C68 on earlier compact design: add2→9draft then remove exactly the two new UUIDs through menus→7original draft rows unchanged;2history preserved. C71–C72 verify roomier picker, circular thin tick and filter panel, selections survive filter/details. More recent MP4/home list checks are recorded in the latest CHANGELOG.

## Blur audit and current guide policy

User screenshot14:42 exposed large-guide blur. ffprobe confirms Row C0MA9bC is180×180,12frames over3s (4actualframes/s). Converted MP4 retains these original poses at CFR30; it cannot recover lost detail or true30fps motion. Guide no longer prioritizes this preview over an exact existing Form/OpenGym renderer:9matched renderers can use native GPU resolution, with angles preserved. No mesh/motion was changed (Form work remains paused). Other mapped low-resolution previews are capped at220pt in a shorter≤300pt media area instead of stretching across the full screen; see C83. This is a display mitigation, **not a resolved HD-media gap**. Thumbnail clips stay small. No sharpen/upscale/AI interpolation is presented as recovered source detail.

A researched HD GitHub video mirror was rejected: its own README admits uncertain footage provenance; MIT metadata is not permission for that footage. Do not import it. The official provider's HD product needs a separate authenticated plan/source. Do not purchase or invent access. See verification/media-blur-audit.json for source dimensions/frames and unresolved criteria.

Final guide spatial improvement: scripts/exercisedb/encode-guide-previews.py generates26guide-only720px Lanczos4x +gentle unsharp0.35 outputs,3,302,155bytes. Source geometry/poses/timing retained, no temporal/AI interpolation. After review of before/after720frame, boundaries look slightly clearer; this is a visual judgment, not restored anatomical detail. C83 current guide, C85 halfspeed. Thumbnail path does NOT use these larger clips.

## Preset media addition, latest10/11 checkpoint

Library remains32definitions/26pins.9preset-onlydefinitions added in WorkoutProgramModels.swift;6exactmotions (deadbuginy3m5y,crunchTFqbd8t,pushupI4hDWkc,wristcurl2dImyQ8,reversewristcurlBLCvwr2,farmercarryqPEzJjA) bring total32pinned GIF/smallMP4/guide-upscale.32entries in video/guideQA.2presetmotions stayunmapped: lyingglutebridge and bodyweightsquat. Forearm plank now uses separate Pexels footage below. Metadata u0cNiij shows reverseplank,6YUfHPL shows foot-on-benchquadstretch; rejected despite labels. program-mapping-review.json and program-details/ archive providerresponses, including rejects. import-program-media.py reuses pinned bundledGIF withreviewSHA and archivedresponse; no /tmp dependency.

109 model checks include seconds validation/log/save/edit/CSV. C128–C134 isolated UI QA verified timed0validation,30second finish/0volume,40second history edit/relaunch, and Add/Replace preservation. No performance benchmark or full ReduceMotion/size/lifecycle pass. Two unmapped preset guides omit media and retain instructions/actions. Form/model work remains paused.

## Real forearm Plank video — latest20:21 continuation

ShotPot/Pexels4117854 is filmed unweighted forearm hold, not an anatomical animation. Reviewed source at1/4/7seconds; athlete uses a prosthetic leg, not a leg-raise exercise. Rejected weighted ExerciseDB VBAWRPG, Pexels up-down31035751, mislabeled pushup6388429 and wger static illustration layers.

Source2160×3840/25fps retained outside app in third_party/stock-motion. Same4seconds starting1s, crop2160square(x0,y1300) removes unused ceiling; downsample320thumbnail and1080guide. Original25fps/100frames, no AI, color grading or temporal interpolation. Guide is genuine high-resolution source downsample, unlike old180→720 ExerciseDB upscales. Does not make the rest of the library HD. Native AVQueueLooper/scene/visibility handling reused; guide speed menu supported. Source/author/Pexelslicense/sha/probes/outputs in third_party/stock-motion/manifest.json and Settings About credit. C136/C137 show different playing frames; C138 program row. No coach endorsement.

Photo direction20:21: natural source colors only; all render desaturation removed, six sources replaced, three accepted covers unchanged. 13photo manifest remains authoritative. C122–C127 grading experiment obsolete; no AI photography/editing.

Latest21:35 cover-only update: core30 now uses a still extracted at3s from real cottonbro/Pexels4754028 crunch footage. Natural source colors retained; JPEG1600×844 downsample from4K, not AI or color grading. Original video/hash/derivation retained in photo manifest and sources/. Old ShotPot4047104 cover archived. Plank video unchanged.

Latest21:42 cover-only: core14 uses Li Sun/Pexels2294363 side-plank photograph, downloaded1600px JPEG unchanged, natural colors/noAI. Previous Peggy_Marco image archived; this is illustrative stock, not a new mapped exercise or guide.

## Thumbnail policy22:30, supersedes static fallback descriptions
User requests hiding exercise imagery when there is no actual exercise clip. hasMotionThumbnail checks bundled MP4; all three list callers omit image space when false. ExerciseMotionThumbnail no longer renders muscle glyph or asynchronous GIF fallback. Video rows retain native playback/ReduceMotion/lifecycle behavior. Picker no-video rows retain guide via info44pt; workout/program rows retain row guide action. Muscle suggestions/filter/body and existing guide renderers are unchanged. No new media was added;6unmapped library variants and2unmapped preset definitions remain media gaps.

Latest11/11 07:18:C172–C178 live samples confirmed male/femaleRow thumb/guide and female setentry,0.5speed andmuscles tab. IsolatedQA removed, mainfullstatepreserved.4library+1preset remainmissing, some180pxfallback; not all21clips UIcertified.
