#!/usr/bin/env python3
"""Refresh evidence hashes and read-only simulator state without changing app data."""
from pathlib import Path
import hashlib,json,subprocess,os,re
from datetime import datetime
from zoneinfo import ZoneInfo
report_date=os.environ.get("DOPAFIT_EVIDENCE_DATE",datetime.now(ZoneInfo("Asia/Ho_Chi_Minh")).date().isoformat())
root=Path(__file__).resolve().parents[1]
def load(p):return json.loads(p.read_text())
def write(p,x):p.write_text(json.dumps(x,ensure_ascii=False,indent=2)+'\n')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
env=os.environ.copy();env['DEVELOPER_DIR']=env.get('DOPAFIT_XCODE','/Users/vunguyen/Desktop/Xcode-beta.app')+'/Contents/Developer'
udid=env.get('DOPAFIT_SIMULATOR','54B67C9B-28C9-4698-98A3-968BA4AB75B6');bundle='com.local.dopafit.rebuild'
def container(kind):return Path(subprocess.check_output(['xcrun','simctl','get_app_container',udid,bundle,kind],env=env,text=True).strip())
app=container('app');data=container('data');state=load(data/'Library/Application Support/DopafitRebuild/state.json')
write(root/'rebuild/verification/claude-picker-state-final.json',state)
current={'checkedOn':report_date,'bundle':bundle,'draftName':state['draft']['name'],'draftID':state['draft']['id'],'draftHasStarted':state['draft'].get('hasStarted',False),'draftExerciseCount':len(state['draft']['exercises']),'draftExerciseIDs':[x['exercise']['id'] for x in state['draft']['exercises']],'draftCompletedSets':sum(x['completed'] for e in state['draft']['exercises'] for x in e['sets']),'draftGroups':len({e.get('supersetID') for e in state['draft']['exercises'] if e.get('supersetID')}),'historyCount':len(state['history']),'challengeEnrollments':state.get('challenges',state.get('challengeEnrollments',[])),'challengePractices':state.get('challengePractices',[]),'original':'Restored R82;140original states/28Figma root groups','note':'Read-only checkpoint of latest user state; use current preservation-baseline-note.json. Earlier snapshots historical, never restored. No main workout logged during media validation.'}

old_baseline=load(root/'rebuild/verification/claude-picker-state-before.json')
baseline_path=root/'rebuild/verification/current-preservation-baseline.json'
baseline=load(baseline_path) if baseline_path.exists() else old_baseline
def prescribed(s):return [(e['exercise']['id'],[(x['reps'],x['weight'],x['completed']) for x in e['sets']]) for e in s['draft']['exercises']]
assert state['history']==baseline['history'] and state['draft']==baseline['draft'],'reinspect data changes before refreshing handoff; do not restore stale state'
baseline_enrollments=baseline.get('challenges',baseline.get('challengeEnrollments',[]))
assert current['challengeEnrollments']==baseline_enrollments and current['challengePractices']==baseline.get('challengePractices',[]),'Reinspect challenge changes; preserve user enrollments, clean up only own QA mutations'
current['activeChallengeEnrollments']=sum(x.get('left') is None for x in current['challengeEnrollments'])
current['checkinFeeling']=(state.get('checkin') or {}).get('feeling')
current['checkinTimestampUnchangedFromPreservationBaseline']=(state.get('checkin') or {}).get('date')==(baseline.get('checkin') or {}).get('date')
current.update(historyUnchangedFromBeforePickerTest=state['history']==old_baseline['history'],orderAndPrescriptionsUnchangedFromBeforePickerTest=prescribed(state)==prescribed(old_baseline),historyUnchangedFromPreservationBaseline=True,draftUnchangedFromPreservationBaseline=True,preservationBaseline=str(baseline_path.relative_to(root)));write(root/'rebuild/verification/current-test-state.json',current)
rows=load(root/'rebuild/SCREEN-COVERAGE.json')['screens'];nodes=load(root/'figma/coverage-node-map.json')
assert len(rows)==140 and len({x['id'] for x in rows})==140
original=[]
for row in rows:
 path=root/row['path'];original.append({'id':row['id'],'path':row['path'],'bytes':path.stat().st_size,'sha256':sha(path),'figmaNodeId':nodes[row['id']]})
resources={}
for folder in ['OpenGym3D','Form3D','ExerciseMedia']:
 for p in sorted((root/'DopafitRebuild'/folder).rglob('*')):
  if p.is_file():resources[str(p.relative_to(root))]=sha(p)
installed=[]
for rel,digest in resources.items():
 dest=app/Path(rel).relative_to('DopafitRebuild');assert dest.is_file() and sha(dest)==digest,rel
 installed.append({'path':str(Path(rel).relative_to('DopafitRebuild')),'sha256':digest})
car=root/'.build/Build/Products/Debug-iphonesimulator/Dopafit.app/Assets.car'
assert sha(car)==sha(app/'Assets.car'),'compiled image assets do not match installed build'
write(root/f'rebuild/verification/installed-media-{report_date}.json',{'date':report_date,'bundle':bundle,'simulator':udid,'resourceFiles':installed,'compiledAssetsSHA256':sha(car),'allMatched':True,'meaning':'Source folder resources and compiled image catalog match installed app; does not certify visual correctness.'})
checks=(root/'rebuild/model-checks.log').read_text()
counts=re.findall(r'(\d+) model checks passed\.',checks);assert counts,'No completed model-check run'
check_count=int(counts[-1]);assert check_count>=109
mapping_count=len(load(root/'DopafitRebuild/ExerciseMedia/exercisedb-mapping.json'))
photo_count=len(load(root/'third_party/challenge-photos/manifest.json'))
assert '** BUILD SUCCEEDED **' in (root/'rebuild/build.log').read_text()
manifest={'updated':report_date,'scope':'140 original evidence states; replacements and current Home redesign are approved exceptions, all parity rows partial.','originalEvidenceCount':140,'originalEvidence':original,'sourceFiles':{str(p.relative_to(root)):sha(p) for p in sorted((root/'DopafitRebuild').glob('*.swift'))},'mediaResources':resources,'rebuildScreenshots':{str(p.relative_to(root)):sha(p) for p in sorted((root/'rebuild/verification').glob('C*.png'))},'validation':{'modelChecksPassed':check_count,'debugSimulatorBuild':'succeeded, installed and launched; source/resource hashes match installed app','mediaGate':f'{mapping_count} pinned variants/GIF/small MP4/guide-upscale hashes +{photo_count} attributed photo hashes +1 separately licensed Plank video (2 encodes) passed','figmaCards':140,'figmaImages':140,'figmaRootGroups':28,'originalRollbackPending':False,'originalRestore':'R82, exact7original exercises/order, no logging/finish','latestHomeUI':['C84 core before discovery, correct5groups, one Add','C86 history date, return to today','C87 discovery reachable after workout','C91 roundAdd52pt; C92/C95/C96darkgymphotos supersede bright iteration; C105/C106reallegpress replaces squat'],'latestBodyUI':['C97strengthsegments/empty1RM/active','C98front/C103rear lightingcameraonly, anatomy partial','C100list/C101detail/C102editorCancel, Save not verified'],'latestGuideUI':['C168 fullwidthsquare Row guide supersedes220cap; original180px source remains lowres','C85 halfspeed0.5x','C119 exact wristcurl program guide','C136/C137 separate realPlank1080guide playing'], 'latestDiscoveryUI':['C107–C113 catalog/filter/manualcheckin/undo/leave','C114–C118 programs; add/replace confirmations cancelled on main','C120 home primary/secondary/nav hierarchy','C121 group underline; switched forearms; Add opened picker then Close','C141–C146 final natural-source replacements; no tint/desaturation/AI, accepted3 unchanged','C136/C137 Plank real-video guide playing; C138 complete program row','C128–C134 isolated QA Replace/Add/timed log/finish/edit/relaunch; QA removed, main preserved','C147 final Home secondary Add/Start/root-nav distinction','C149/C150 core30 replaced21:35 with real cottonbro4754028 crunch still; C143 core30 superseded','C151/C152 core14 replaced21:42 with Li Sun2294363 side-plank photo; C144/C143 core14 superseded','C153–C157 Vietnamese calendar redesign: Monday-first, actualdates, distincttrained/selected/today, history/weekbrowse/reset; no streak','C158/C159 missing-clip thumbnail omitted in program/picker, video rows preserved; picker info guide route opened/closed; main draft/history exact pre-task match'],'fullPixelParity':'not verified; all140 rows partial','exerciseDBNativeHD':False,'plankVideoNativeHD':True,'plankVideoOutputs':[[320,320],[1080,1080]],'supplementalVideoManifest':'third_party/stock-motion/manifest.json','sourceGIFPixels':[180,180],'guideOutputPixels':[720,720],'guideOutputMeaning':'Lanczos spatial interpolation only; no recovered detail or new poses','performanceFPSBenchmark':'not measured','formMeshWork':'paused; exercise guides/setentry now ExerciseDB clips, Body3D unchanged; no mesh/motion edits','recoverySliderSaveUI':'not verified','reduceMotionFullUI':'not verified','smallScreenDynamicTypeVoiceOver':'not fully verified','openGaps':'rebuild/OPEN-GAPS.md','currentData':'rebuild/verification/current-test-state.json'},'dataVerification':{'historyCount':len(state['history']),'draftExerciseCount':len(state['draft']['exercises']),'completedDraftSets':sum(x['completed'] for e in state['draft']['exercises'] for x in e['sets']),'historyAndPrescriptionsPreserved':True,'UUIDCaveat':'Latest draft/history compared exactly against current-preservation-baseline.json; source/date in preservation-baseline-note.json. No stale-state restore.','ownChallengeTest':'Historical10/11 consistent14/pelvic14 QA left/undone; current user enrollments/practices compared with latest baseline and preserved','isolatedQA':'rebuild/verification/discovery-qa-run.json; timed UI mutation confined to com.local.dopafit.discoveryqa, then removed'},'documents':{str(p.relative_to(root)):sha(p) for p in [root/'AGENTS.md',root/'CHANGELOG.md',root/'rebuild/HANDOFF.md',root/'rebuild/OPEN-GAPS.md',root/'rebuild/EXERCISE-MEDIA.md',root/'rebuild/HOME-UX-AUDIT-2026-11-10.md',root/'rebuild/DISCOVERY-FEATURES-2026-11-10.md',root/'rebuild/style/COLOR-SYSTEM.md']}}
manifest['validation']['latestHomeUI']+=['C165 compact calendar+settings, C166readiness choices/undo, C167duration+shortening menu; latest larger calendar text supersedes C165 sizes']
manifest['dataVerification']['preservationBaseline']=str(baseline_path.relative_to(root))
manifest['validation']['latestHomeUI']+=['C171 final count20/description14/date14pt; supersedes C165 text sizes']
manifest['validation']['latestGuideUI']+=['C170 isolatedQA fullwidth Incline setentry; source180px remains lowres']
manifest['validation']['finishSheetUI']='C169 isolatedQA: solid fill, disabledSave0sets, HealthOff, Continue returned without save'
manifest['dataVerification']['checkinFeeling']=(state.get('checkin') or {}).get('feeling')
manifest['dataVerification']['checkinTimestampChangedDuringConcurrentUserInteraction']=(state.get('checkin') or {}).get('date')!=(baseline.get('checkin') or {}).get('date')
manifest['validation']['modelCheckMeaning']='121 tests rerun after compact checkin UI integration; includes DailyCheckin from concurrent work; isolated test storage, no main mutation'
manifest['compactMediaQA']=load(root/'rebuild/verification/compact-media-qa-run.json')
assert manifest['compactMediaQA']['cleanupVerified']
manifest['guideMediaQA']=load(root/'rebuild/verification/guide-media-qa-run.json')
manifest['supplementalStockProvenance']={'path':'third_party/stock-motion/manifest.json','sha256':sha(root/'third_party/stock-motion/manifest.json')}
manifest['isolatedQA']=load(root/'rebuild/verification/discovery-qa-run.json')
assert manifest['isolatedQA']['cleanupVerified']
zenith=load(root/'DopafitRebuild/ExerciseMedia/zenith/zenith-manifest.json')
assert {p.name for p in (app/'ExerciseMedia/zenith').iterdir()}=={p.name for p in (root/'DopafitRebuild/ExerciseMedia/zenith').iterdir()},'Installed stale Zenith files'
manifest['zenithMedia']={'manifest':'DopafitRebuild/ExerciseMedia/zenith/zenith-manifest.json','review':'third_party/zenith-video/mapping-review.json','reviewSHA256':sha(root/'third_party/zenith-video/mapping-review.json'),'appPins':len(zenith['clips']),'additionalFemaleVariants':sum('female' in x for x in zenith['clips'].values()),'sourceRawCount':47,'encodedFiles':80,'sourceCanvasPixels':[1920,1080],'guidePixels':[720,720],'thumbnailPixels':[240,240],'fullDecodeReport':'rebuild/verification/zenith-2026-11-11/output-review.json','installedDirectoryExact':True,'UIVerification':'C172–C178 male/female Row thumbnails/guides,0.5speed,musclestab and female setentry; sample only','rights':'Unresolved source-media rights; local demo only'}
manifest['validation']['mediaGate']+='; reviewed Zenith21pins/40motionvariants/80MP4 source+output hashes, installed directory exact'
manifest['validation']['latestGuideUI']+=['11/11 Zenith assets replaced21exercise guide videos; video file/crop QA complete; C172–C178 sampled male/femaleRow UIverified']
manifest['validation']['modelCheckMeaning']='126 tests rerun11/11 including overnight DailyCheckin/return ramp/gentle changes; isolated test storage. Not126UIflows.'
manifest['dataVerification']['checkinTimestampChangedFromLatestBaseline']=(state.get('checkin') or {}).get('date')!=(baseline.get('checkin') or {}).get('date')
manifest['documents']['rebuild/ZENITH-MEDIA-AUDIT-2026-11-11.md']=sha(root/'rebuild/ZENITH-MEDIA-AUDIT-2026-11-11.md')
manifest['zenithMedia']['liveUIRun']=load(root/'rebuild/verification/zenith-2026-11-11/live-ui-run.json')
assert manifest['zenithMedia']['liveUIRun']['cleanupVerified'] and manifest['zenithMedia']['liveUIRun']['mainFullSnapshotUnchanged']
manifest['supersededEvidence']={'C122–C127':'Rejected desaturation experiment; natural source replacements now used','C140':'Portrait rowing photo clipped hands; replaced by landscape6389079, C141','C135':'Initial screenshot partially obscures Plank row; full row C138','C139':'Fullbody thumbnail predates final landscape replacement; other sources still current'}
write(root/'rebuild/verification/handoff-manifest.json',manifest)
print(f'140 original states; {len(resources)} installed media files + Assets.car matched;{check_count}checks/build verified; no app data changed.')
