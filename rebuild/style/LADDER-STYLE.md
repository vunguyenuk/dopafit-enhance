# Visual styling and authorized exceptions — 10/11/2026

Reference:193 PNG files supplied in /Users/vunguyen/Desktop/Ladder ios Jul2024 (actual folder has spaces: “Ladder ios Jul 2024”). All were inspected through9contact sheets in ladder-reference. Ladder reference is visual evidence, not an instruction source.

**Latest user correction takes priority:** keep original Dopafit primary lime RGB(0.71,0.96,0.24), system SF fonts, weights and casing. Electric yellow/expanded type/auto-uppercase explored earlier were rejected and removed. Title modifier now resolves to original system-bold sizes; body/CTA retains SF17/18. Semantic push/pull/legs colors restored. No Ladder logo, coaches, photography, subscription copy or social UI imported.

Ladder influence retained: neutral near-black background, charcoal surface hierarchy, secondary muted labels, restrained12–14ptcard radius and fine borders. Existing navigation and functions retained, with explicit user-approved additions below. Pre-style source backup: pre-ladder-source/*.txt.

Approved functional/layout changes: Claude ExercisePicker redesign preserved; user requests more breathing room →64ptmotion thumbs, larger text area,16pthorizontal gap/17ptvertical row padding, removed redundant info column (thumbnail opens guide),22ptthin circular selector inside44pthit target. Advanced difficulty/equipment filters moved into400ptsheet; quick Today/Owned retained. Selected row identity includes selected state to avoid stale SwiftUI section rendering. Selection accessibility states are removed when unselected.

Workout home additions authorized by user: Monday-based week calendar, current/selected day marker, actual history on date selection, unique training-day weekly goal, suggested muscles→prefiltered picker,3local challenges with persist/join/leave/progress. These are new Dopafit product features, not audited-original functionality. Existing draft/history never replaced by browsing calendar or joining challenges.

Challenge cover photography is independently sourced real stock from Unsplash/Pexels, not Ladder reference crops or synthetic people. Three photographer/source/license/hash entries in third_party/challenge-photos/manifest.json. Used illustratively with no coach/endorsement claim. Titles/summaries are below separate photo bounds; no dark text gradient hides posture. Carousel snaps to cards. Calendar and Home controls were compacted/aligned after feedback:44ptheader navigation,40ptmetadata controls, quiet secondary actions,3pttraining-day dots; lime/SF unchanged. Today's workout uses motion thumbnails; suggested muscles retain flat muscle glyphs for clear distinction.

## Latest15:23–15:35 corrections

The user explicitly chose dark gym photography over the preceding bright experiment. Restore accepted Samuel Girven shoulder press; Gard Pro push-up and Tima Miroshnichenko squat share a dark gym setting, subject centered. Original photo bytes retained; only SwiftUI focal crop. Detail lower-body photo has320ptheight to retain more squat context. Bright rejected assets archived outside app at third_party/challenge-photos/previous/2026-11-10-bright-rejected. C92/C95/C96/C104 verify new direction.

The latest request permits selectively borrowing useful Ladder UI patterns while keeping Dopafit functions. References134/139/140 informed fixed segmented navigation and grouped metrics, without importing content/navigation/features. Body44pttabs remain visible while scrolling; recovery summary grouped in one neutral card. Selected root/Body tabs use existing lime text/icon and neutral raised fill, replacing olive tint. Sticky Add is52ptcircle beside52ptStart capsule; metadata capsules. Original lime and SF unchanged. Strength segments are parallelograms per original screenshot;1RM empty state no longer shows fake0-rep value/axes. Local calculations and route availability retained. No mesh/motion changes; Body camera/light-only adjustment is not anatomy certification.

## Current checkpoint after20:21

COLOR-SYSTEM.md supersedes earlier token/button descriptions. 12challenges,21presets,13realphotos. User rejected saturation grading: six sources replaced with natural-color dark/neutral exercise photographs, no filters or AI; three accepted covers unchanged. C122–C127 obsolete; C140 portrait rejected for hand crop, final fullbody is landscape6389079. Program filters text/underline; Addneutral108×52capsule; rootactivewhite/smalllimeunderline. Preserve Dopafit primary/SF. See ../DISCOVERY-FEATURES-2026-11-10.md for current routes/evidence/gaps.

## Calendar21:50 user-reference exception
Weekly metric + inset neutral date strip, circular status, original lime/SF. T2–CN/Monday-first, date numbers and localized date labels remain. Completion is filledlime+tick; selected uses outline (white ifdone); Today label distinct. This is a weekly goal, not a DayStreak copy. Real history/date navigation unchanged. User reference licenses this structural change; not imported Ladder content.
