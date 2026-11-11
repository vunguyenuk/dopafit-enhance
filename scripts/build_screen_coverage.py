#!/usr/bin/env python3
"""Portable, conservative parity ledger. Explicit evidence, never screenshot-count parity."""
import json,copy
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
inv=json.loads((ROOT/'figma/complete-inventory.json').read_text())
verified=json.loads((ROOT/'figma/published-verification.json').read_text())
nodes={x['name'][:3]:x['id'] for x in verified['cards']}
def spec(source,area,gaps,ui='Chưa retest UI bản mới',evidence=()):
 return dict(source_files=['DopafitRebuild/'+s+'.swift' for s in source.split(',')],area=area,open_gap_ids=gaps.split(','),implementation='partial',ui_verification=ui,rebuild_evidence=list(evidence),pixel_parity='Chưa xác nhận cùng viewport')
rows={}
def assign(ids,value):
 for sid in ids.split(): rows[sid]=copy.deepcopy(value)
r=lambda prefix,a,b:' '.join(f'{prefix}{i:02}' for i in range(a,b+1))
assign(r('R',1,18),spec('OnboardingView','Onboarding narrative','G01,G02,G07'))
assign(r('R',19,37),spec('SetupOnboardingView','Onboarding thiết lập','G01,G06,G07','Đã đi nhánh nhập tay ở lượt trước; chưa mọi nhánh'))
assign('R38',spec('SetupOnboardingView','Lưu / xác thực','G01,G05','Đã thử demo; SSO thật chưa có'))
assign('R39 R40 R41',spec('PostSetupFlow','Plan / cam kết / Pro','G01,G02,G05,G07','Đã thử plan→giữ 2 giây→Pro→demo; checkout chưa có'))
assign('D01 D57 R49 R62',spec('WorkoutViews,Models','Workout home / plan','G01,G03,G04,G10','Đã mở Home; plan mới gốc R62 khác mẫu đã quan sát R50, chưa đủ nguyên nhân'))
assign('D02 D58',spec('WorkoutViews','Menu bài / buổi','G01,G08','Đã có menu; chưa bấm đủ mọi tác vụ'))
assign('D03 D52',spec('ProgressViews','Exercise history','G01,G09','History có dữ liệu đã mở dạng push; empty chưa retest bản mới', ['rebuild/verification/C09-metric-year.png']))
assign('D04 D05 R42 R43 R63',spec('ExerciseGuide','Guide / anatomy / equipment','G01,G02,G03','Đã bấm 3 tab; guide giữ khi đổi tab; video/góc thật chưa có',['rebuild/verification/C01-guide-muscles.png','rebuild/verification/C02-guide-equipment.png']))
assign('D06',spec('WorkoutViews','Thời lượng','G01,G04','Đã thử điều khiển duration ở lượt trước; chưa mọi option'))
assign('D07 R45',spec('SettingsViews','Chọn / quản lý gym','G01,G03','Đã thử rename/type rồi khôi phục; xóa gym cuối disabled; model kiểm ràng buộc'))
assign('D08 D09 D10 R44',spec('SettingsViews,Models','Plan settings / split','G01,G04','Đã đổi experience beginner và sinh upper; chưa đủ split/PPL/variability'))
assign('D11 D12',spec('SettingsViews,Models','Equipment / nấc tạ','G01,G03','Có điều khiển; thiếu preset/thư viện đầy đủ'))
assign('D13 D42',spec('BodyAndGoalsViews','Body results / benchmark','G01,G04,G06','C97: fixed tabs, lime selected/neutral fill, strength parallelograms and honest1RM empty; original engine/Health still partial',['rebuild/verification/C97-body-results-lime-active.png']))
assign('D14 D40 D41 R64 R65',spec('BodyAndGoalsViews,Models','Recovery / phương pháp / front-back','G01,G02,G04,G11','C98/C103 front-back after lighting/camera-only change; groupedmetrics/fixedtabs, help open/close. Mesh/masks/anatomy not certified; Form work paused',['rebuild/verification/C98-body-recovery-front-lighting.png','rebuild/verification/C103-body-recovery-rear-verified.png']))
assign('R66',spec('BodyAndGoalsViews','Danh sách hồi phục','G01,G02,G04,G11','C100 current10primary+6secondary list; C101chestdetail opened/closed; editorsecondary still unknown',['rebuild/verification/C100-body-muscle-list.png','rebuild/verification/C101-muscle-detail.png']))
assign('R67',spec('BodyAndGoalsViews,Models','Chỉnh hồi phục','G01,G04,G11','C102 editor opened, Save disabled, Close cancelled without changes. Save after value change not verified',['rebuild/verification/C102-recovery-editor.png']))
assign('D15 D38 D39',spec('BodyAndGoalsViews,Models','Weekly goals','G01,G04','Đã mở nhóm đẩy, target/còn lại khớp contributions local; kéo/chân còn giả định',['rebuild/verification/C07-goals-expanded.png']))
assign('D16 D37 R46 R59',spec('ProgressViews','Journal calendar / sessions','G01,G09','Đã mở hai buổi/reopen, lịch tuần-tháng toggle theoR71; ngày trống không đổi; tháng khác chưa xác minh'))
assign('D17 D18 D19 D20 D21 D23 D25 D27 D28 D29 D30 R50 R51 R52',spec('WorkoutViews,Models','Active workout / set entry / RIR','G01,G08,G10','Đã tap-through vòng Incline765 và Row720 ở lượt trước; chưa mọi keyboard/bodyweight/timed state'))
assign('D22 D26',spec('WorkoutViews,Models','Rest settings / timer','G01,G08,G12','Đã pause/resume lượt trước; main/warmup riêng đạt model, cần UI test'))
assign('D24 D55',spec('DopafitApp,Models,WorkoutViews','Resume / background','G01,G08','Đã restart giữ history/draft; chưa timer nền/notification tới hạn'))
assign('D31 D32 D33',spec('WorkoutViews,Models','Swap / filter / sort / scope','G01,G03,G04,G12','UI Tập nhiều nhất→Incline/Row; dumbbell row+Tạđòn→empty, +Cặp tạđơn→Row; chưa mọi tổ hợp'))
assign('D34 R53',spec('WorkoutViews,Models','Finish confirmation','G01,G08','Đã xác nhận lưu Incline765 và Row720 ở lượt trước'))
assign('D35 R54',spec('ProgressViews,Models','Summary','G01,G09','Đã xem summary765/720; saved edit720→600→720',['rebuild/verification/C03-saved-edit-600.png']))
assign('D36 R58',spec('ProgressViews','Streak unlock','G01,G09,G10','Đã qua streak entry; dữ liệu nhiều tuần chưa kiểm'))
assign('D43 R47',spec('SettingsViews','Settings / Pro / export','G01,G05,G06,G10','Export local/empty disabled; dịch vụ thật chưa có'))
assign('D44 R48',spec('SettingsViews','Language','G01,G10','Đã đổi English; chưa dịch đầy đủ toàn bộ màn'))
assign('D45 D46 D47',spec('ProgressViews,MetricDetailView','Report / period','G01,G09','Có report/filter và ngày thật; thiếu nhiều trạng thái chart gốc'))
assign('D48',spec('SettingsViews','Health profile','G01,G06','Profile persist được model kiểm; chưa Health write thật'))
assign('D49',spec('ProgressViews','Saved-session menu','G01,G09','Đã thêm ellipsis ngay Journal và editor giờ/phút; save/reopen/cancel đã thử; menu style/share còn partial'))
assign('D50 R60',spec('ProgressViews,SavedSetEditor','Saved session / edit / add','G01,G09,G12','Đã edit12→10→12/reopen720; chọn thêmRow rồi Cancel giữ1bài720kg; Save bài mới chưa UI test',['rebuild/verification/C03-saved-edit-600.png']))
assign('D51 R55',spec('ProgressViews','Saved exercise menu','G01,G09','Đã mở menu→History push; RIR và preference entries có; chưa mọi nhánh'))
assign('D53 D54 D56',spec('ProgressViews,MetricDetailView','Trends / metric / explanation','G01,G09,G12','Đã History→Trends→1RM, bốn kỳ, đổi tab giữ metric; chạm điểm chưa xác nhận',['rebuild/verification/C09-metric-year.png']))
assign('R56 R57 R61',spec('ProgressViews,Models','Saved RIR','G01,G09','Đã sửa/reopen/relaunch giữ RIR3; model bounds/persistence đạt'))
assign('R68 R69',spec('BodyAndGoalsViews,Models','Recovery secondary muscle list','G01,G02,G04,G11','Đã mở và cuộn sáu cơ phụ; thumbnail crop đúng vùng ở mốcC11; asset hiện đã đổi sang model mới; cơ phụ editor chưa xác minh',['rebuild/verification/C11-secondary-muscles.png']))
assign('R70',spec('ProgressViews,SavedDurationEditor,Models','Saved workout duration wheels','G01,G09','Đã chọn1phút Save, mở lại1phút; chọn2phút rồi đóng vẫn1phút; zero disabled; model validation/reload đạt',['rebuild/verification/C12-saved-duration-one-minute.png']))
assign('R71',spec('ProgressViews','Journal expanded month calendar','G01,G09','Đã mở rộng35ô và thu gọn; ngày trống không đổi filter; chuyển tháng chưa xác minh',['rebuild/verification/C14-expanded-month-calendar.png']))
assign('R72',spec('WorkoutViews,Models','Discard active workout confirmation','G01,G08','Original X→dialog→Tập tiếp giữ buổi đã quan sát; simulator X→Tập tiếp giữ timer/6set; discard có4model checks, không bấm Bỏ trên draft hiện có',['rebuild/verification/C33-discard-confirmation.png']))
assign('R73',spec('WorkoutViews,Models','Active superset menu','G01,G08','Đã mở menu gốc và simulator, một mục Ghép superset/circuit; chưa xác minh các ngữ cảnh khác',['rebuild/verification/C37-active-superset-menu.png']))
assign('R74',spec('WorkoutViews,Models','Active superset selection','G01,G08','Original thấy0bài Lưu xám; simulator0bài Lưu disabled, selection cùng trang có timer/Hủy',['rebuild/verification/C38-superset-empty.png']))
assign('R75',spec('WorkoutViews,Models','Active superset selection','G01,G08','Original chọn1bài Lưu xám; simulator1bài Lưu disabled, chưa lưu dữ liệu',['rebuild/verification/C39-superset-one-selected.png']))
assign('R76',spec('WorkoutViews,Models','Active superset selection','G01,G08','Original chọn2bài Lưu lime rồi Hủy; simulator2bài Lưu enabled rồi Hủy, timer/6set giữ; Lượt sau quan sát Save/reorder trong tool, R77chờảnh/rollback; circuit/undo chưa kiểm.5model checks grouping/reorder/reload đạt',['rebuild/verification/C40-superset-two-selected.png']))
assign('R77',spec('WorkoutViews,Models','Superset saved and reordered','G01,G08','Original Save Row1+Shoulder3 → nhóm đầu,2vòng; đã chụp lại và khôi phục tạiR82. Rebuild helper/model đạt; positive UI Save đang kiểm'))
assign('R78',spec('WorkoutViews,Models','Superset group actions','G01,G08','Original menu có Ghi mọi bài/Nhân đôi/Tách; chỉ Tách đã thực thi. Rebuild thêm3tác vụ,7modelchecks mới; confirmation/duplicate placement/reset semantics còn local chưa đối chiếu'))
assign('R79 R82',spec('WorkoutViews,Models','Detach group and preserve order','G01,G08','Original Tách giữ order; R82 xác nhận đủ7bài ban đầu không nhóm. Rebuild detach giữ order/set/persist, model đạt; UI đang kiểm'))
assign('R80',spec('ExerciseGuide','Guide video ready after anatomy placeholder','G01,G02,G03','Ảnh lưu là video Shoulder sau tải, không phải cặp anatomy thấy trước đó trong tool. Bài này chưa có animation thay thế; dùng body highlight, copy3đoạn original chưa nhập đủ'))
assign('R81',spec('WorkoutViews,Models','Superset unequal set counts','G01,G08','Original2+4set hiện Superset·4vòng; rebuild đổi header dùng max setcount. Round execution/warmup/0set chưa xác minh'))
# Latest evidence overrides superseded snapshots without treating replacement media as parity.
for sid,row in rows.items():
 if any(Path(f).stem in ['WorkoutViews','ExerciseGuide','BodyAndGoalsViews','SetupOnboardingView','OnboardingView'] for f in row['source_files']):
  row['source_files'] += ['DopafitRebuild/OpenGymBody.swift','DopafitRebuild/OpenGymAnimationView.swift']
  row['asset_override']='User-authorized replacement, not original media:27/32 library +6preset pinned ExerciseDB GIF/native MP4 at180px; exercise guides/setentry use clips, no Form/OpenGym fallback. Form rework paused. See EXERCISE-MEDIA.md; no HD/FPS/full anatomy claim.'
 row['style_override']='User-approved Ladder neutral surfaces/corners only. Preserve original Dopafit lime RGB(.71,.96,.24) and SF typography/case.'
 if sid in ['D01','D57','R49','R62']:
  row['source_files']+=['DopafitRebuild/WorkoutDiscoveryViews.swift','DopafitRebuild/WorkoutDiscoveryModels.swift','DopafitRebuild/WorkoutProgramViews.swift','DopafitRebuild/WorkoutProgramModels.swift','DopafitRebuild/ExerciseDBMedia.swift','DopafitRebuild/ExerciseLoopVideo.swift']
  row['ui_verification']='Approved redesign: compact calendar/history, today exercise list before discovery, one labeled stickyAdd, dynamic groupcount/title/resume, recognizable challenge photos. C84currentorder, C86history; C153–C157 Vietnamese Monday-first status-strip calendar/history/futureempty/returntoday; User22:30 missing-clip thumbnails omitted (C158program/C159picker); exercise content/actions retained. Latest C120 secondaryAdd108pt/nav hierarchy, C121 underline group filter, natural-color source replacements (C122–C127 grading rejected); C136–C138 real Plank video; C128–C134 isolated Add/Replace/timed QA, C105/C106 accepted legpress. 12 local challenges/21 presets documented separately in DISCOVERY-FEATURES-2026-11-10.md; not original-layout parity or full behavior certification.'
  row['rebuild_evidence']+=['rebuild/verification/C73-calendar-history-two-sessions.png','rebuild/verification/C74-calendar-future-empty.png','rebuild/verification/C78-workout-seven-motion-thumbnails.png','rebuild/verification/C79-compact-calendar.png','rebuild/verification/C80-challenge-visible-movement.png','rebuild/verification/C81-challenge-upper-shoulder-press.png','rebuild/verification/C84-home-core-before-discovery.png','rebuild/verification/C86-compact-calendar-history.png','rebuild/verification/C87-discovery-after-workout.png','rebuild/verification/C88-challenge-squat-visible.png','rebuild/verification/C91-home-round-add.png','rebuild/verification/C92-dark-challenge-shelf.png','rebuild/verification/C95-dark-challenges-upper-lower.png','rebuild/verification/C96-dark-lower-card.png','rebuild/verification/C104-dark-squat-detail-full-context.png','rebuild/verification/C105-dark-legpress-detail.png','rebuild/verification/C106-dark-legpress-card.png','rebuild/verification/C120-home-button-hierarchy.png','rebuild/verification/C121-program-filter-hierarchy.png','rebuild/verification/C123-neutral-pelvic.png','rebuild/verification/C127-neutral-mobility.png','rebuild/verification/C153-vietnamese-calendar-home.png','rebuild/verification/C155-calendar-next-week-empty.png','rebuild/verification/C156-calendar-vietnamese-history-dates.png','rebuild/verification/C157-calendar-vietnamese-final-home.png']
 if sid in ['D31','D32','D33']:
  row['source_files']+=['DopafitRebuild/ExerciseLibrary.swift','DopafitRebuild/ExerciseLibraryFilter.swift','DopafitRebuild/ExerciseDBMedia.swift','DopafitRebuild/ExerciseLoopVideo.swift']
  row['ui_verification']='Approved new picker: token accent-fold search, combined filters, multi-selection kept through filters/detail; add2 then remove exact2 through UI restored7draft/2history at test checkpoint. C71 thin circle and C72 advanced filter. Full combinations/accessibility still open.'
  row['rebuild_evidence']+=['rebuild/verification/C71-lime-picker-thin-tick.png','rebuild/verification/C72-picker-filter-panel.png']
 if sid in ['R77','R78','R79','R81','R82']:
  row['ui_verification']+='; C49–C54 rebuild Save/menu/Cancel/duplicate/log copy/detach and own copy cleanup verified. Original Ghi/Nhân đôi not executed; local semantics remain. Original restore R82 published140states/28roots.'
 if sid=='R80':
  row['ui_verification']='Original shoulder video-ready screenshot preserved. Shoulder guide now pinned standingpress A6wtbuL,33totalpins; no exercise3D fallback. Original copy/media parity remains partial.'
 if row['area']=='Guide / anatomy / equipment':
  row['source_files']+=['DopafitRebuild/ExerciseDBMedia.swift','DopafitRebuild/ExerciseLoopVideo.swift']
  row['ui_verification']='Guide3tabs/history navigation earlier verified C01/C02. New pinned33ExerciseDB motions/local MP4, exact Incline guide seen C67; source180px not HD. Historical Form RDL GPU C60–C64 no longer current guide path. User22:47 now fullwidthsquare, earlier220cap superseded. C85half-speed historical; C162/C163 new clip-onlyguide/speed. Native-HD/FPS gap remains; no complete pixel/variant QA claim.'
 if sid in ['D01','D57','R49','R62']:
  row['ui_verification']+=' C171 final20/14pt readable calendar text; Latest22:51–22:54 compact calendar without nested strip and consolidated duration/gym/readiness menu; shortening under duration, same underlying checkin logic. C165–C167.'
  row['rebuild_evidence']+=['rebuild/verification/C165-compact-calendar-settings.png','rebuild/verification/C166-readiness-menu.png','rebuild/verification/C167-duration-shortcut-menu.png','rebuild/verification/C171-readable-compact-calendar-final.png']
 if row['area']=='Guide / anatomy / equipment':
  row['rebuild_evidence']+=['rebuild/verification/C168-full-width-row-guide.png']
 if row['area']=='Guide / anatomy / equipment' or sid=='R80':
  row['asset_override']='11/11:21reviewed Zenith overlaypins/40motionvariants from1080canvas;33ExerciseDB fallbackpins and separatePlank kept. Standingpress stays exactExerciseDB; unilateralRow mapped correctly. Notoriginalmedia, unresolvedrights localdemo only.'
  row['ui_verification']+=' Latest11/11source/crop/full80decode QA passed; C172–C178 liveRow male/female thumbnail/guide,setentry,0.5speed,musclestab verified; otherpins not allUItested. See ZENITH-MEDIA-AUDIT-2026-11-11.md; no completeparity claim.'
 if row['area']=='Guide / anatomy / equipment':
  row['rebuild_evidence']+=['rebuild/verification/C173-zenith-male-row-guide.png','rebuild/verification/C174-zenith-male-half-speed.png','rebuild/verification/C176-zenith-female-row-guide.png','rebuild/verification/C177-zenith-female-muscles-route.png','rebuild/verification/C178-zenith-female-set-entry.png']
 if sid in ['D01','D57','R49','R62']:
  row['rebuild_evidence']+=['rebuild/verification/C172-zenith-main-home-thumbnails.png','rebuild/verification/C175-zenith-female-qa-home.png']
 row['source_files']=list(dict.fromkeys(row['source_files']))
 row['rebuild_evidence']=list(dict.fromkeys(row['rebuild_evidence']))
assert set(rows)=={s['id'] for s in inv},(set(rows)-{s['id'] for s in inv},{s['id'] for s in inv}-set(rows))
output=[]
for s in inv:
 source_path=Path(s['path'])
 try: relative=str(source_path.relative_to(ROOT))
 except ValueError: relative=str(source_path)
 row={**s,'path':relative,'original_evidence':'Captured original app screenshot','figma_node_id':nodes[s['id']],'figma_url':f"https://www.figma.com/design/2lNpfPEq2wVnGk07bVLghz/Dopafit?node-id={nodes[s['id']].replace(':','-')}",**rows[s['id']]}
 assert (ROOT/relative).exists(),relative
 for f in row['source_files']+row['rebuild_evidence']: assert (ROOT/f).exists(),f
 output.append(row)
result={'updated':'2026-11-11','original_state_count':len(output),'meaning':'Evidence states, not unique screens or completed parity. All remain partial until closed with visual and behavioral evidence.','screens':output}
(ROOT/'rebuild/SCREEN-COVERAGE.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
lines=[f'# Đối chiếu {len(output)} trạng thái Dopafit gốc với rebuild','',f'Cập nhật11/11/2026. Nguồn:58ảnh D +{sum(r["id"].startswith("R") for r in output)}ảnh R từ app thật và Figma;{len(output)}card đã đọc lại, không trùng ID. Đây không phải số màn đã hoàn thành. Tất cả dòng hiện **partial**; chưa có chứng cứ pixel parity toàn bộ.','','Mỗi dòng có ảnh gốc, node Figma, file triển khai, chứng cứ UI và gap mở. JSON đi kèm giữ đầy đủ tên, mục đích, entry/exit, chính/phụ và dependencies từ inventory. Các đường dẫn là tương đối trong repo để chuyển tài khoản/máy được.','','| ID / màn gốc | Ảnh / Figma | Source hiện tại | Kiểm thử UI thực tế | Còn mở |','|---|---|---|---|---|']
for s in output:
 def esc(v):return str(v).replace('|','\\|').replace('\n',' ')
 sources='<br>'.join(f'[{Path(f).name}](../{f})' for f in s['source_files'])
 tests=esc(s['ui_verification'])
 if s['rebuild_evidence']:tests+='<br>'+' '.join(f'[C{i+1}]({Path(f).relative_to("rebuild")})' for i,f in enumerate(s['rebuild_evidence']))
 lines.append(f"| {s['id']} · {esc(s['name'])}<br>**partial** | [gốc](../{s['path']}) · [Figma]({s['figma_url']}) | {sources} | {tests} | {', '.join(s['open_gap_ids'])} |")
lines+=['','## Quy tắc cập nhật','','Chỉ thêm trạng thái đã thực sự quan sát; ảnh mới giữ ID mới, không thay ảnh bằng rebuild. Muốn đóng một dòng: đối chiếu ảnh cùng viewport, kiểm đủ chính/phụ/flow/disabled/cancel/persistence và ghi evidence. Build/model checks không thay thế UI. Các nhóm chưa quan sát nằm trong OPEN-GAPS.md, không biến thành màn đã audit.','']
(ROOT/'rebuild/SCREEN-COVERAGE.md').write_text('\n'.join(lines))
print(f'{len(output)} rows; all original paths, Figma IDs, source paths and evidence paths verified')
