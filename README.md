# Dopafit Rebuild

A SwiftUI rebuild of Dopafit, a gym app, plus a long list of things we added on top.

The original question was simple: what would it take for a workout app to actually stick with the people who usually give up on the gym? Beginners who don't know what a cable machine is for. People coming back after a month off. People who walk in tired, sore, or with twenty minutes to spare, and find the plan doesn't care. This project is where we've been answering that question in code.

Fair warning before you dig in: this is a working prototype, not a shipping product. Read the "What this isn't" section before you show it to anyone.

The app's interface is in Vietnamese (English is partial), so the on-screen labels are given in brackets below.

## What the app does

The core idea is that **today's workout should bend to today**. On the Workout tab (*Buổi tập*) you get a plan for the day, and a few ways to change it without starting over:

- **"How are you today?"** (*Hôm nay bạn thế nào?*) One tap. *Tired* drops a set and takes about 10% off the weights. *Something hurts* asks where (neck, shoulder, elbow, wrist, lower back, knee) and swaps or lightens the exercises that load that spot. *Short on time* trims the session to 15, 20, 30 or 45 minutes. Every change can be undone, and the rows that changed are highlighted in lime so you can see what moved.
- **A one-line reason.** Under the workout name there's a short note explaining the plan, like "Back and chest recovered · weights held". No black-box progression.
- **Machine taken?** (*Máy đang có người*) Open the ⋯ menu on any exercise and swap it for a same-muscle alternative, preferring different equipment, in one tap.
- **Missed a session?** If yesterday was a planned training day and you skipped it, Home asks whether you want the full session today or a 20-minute version.
- **Coming back after a break.** Two weeks or more off and the weights drop to about 75%, then climb back over two weeks instead of throwing you straight in at your old numbers.

And for the people the gym tends to lose:

- **Beginners** get video for most exercises, a "set up before you start" card for machines and benches, a short list of common mistakes, starting weights estimated from onboarding, and a three-session warm-up period. The Body tab shows real numbers from the first logged workout instead of a locked screen.
- **Home workouts.** Add an "At home" (*Ở nhà*) location (dumbbells up to 20 kg, bands, bodyweight) and the generator swaps anything you can't do for something you can.
- **Gentle mode** (*Chế độ nhẹ nhàng*) for older lifters or anyone low on energy: at most five exercises, two sets each, longer rest, no barbells.
- **Text size** (*Cỡ chữ*: Vừa, Lớn, Rất lớn) applies across the whole app.
- **Female demo videos** are used automatically when the profile is set to female and a female version exists.

The rest is the usual gym-app furniture: set logging with timers and RIR, supersets, a plate calculator, exercise history, weekly set goals by muscle group, recovery, a training log with a calendar, challenges, programs by muscle group, kg/lb, and CSV export.

## Getting started

You need the Xcode beta that ships the iOS 27 simulator. Nothing else: no CocoaPods, no packages to install.

1. Open `Dopafit.xcodeproj`.
2. Pick the **Dopafit** scheme and an **iPhone 18 Pro Max** simulator.
3. Hit Run.

Or from the terminal:

```sh
./scripts/run-simulator.sh   # build, install and launch (keeps your saved data)
./scripts/check-models.sh    # run the model checks
```

Both scripts look for Xcode at `/Users/vunguyen/Desktop/Xcode-beta.app`. Point them elsewhere with `DOPAFIT_XCODE`, and pick a different simulator with `DOPAFIT_SIMULATOR` (a UDID). They don't touch your global `xcode-select`.

A few launch arguments are handy when testing:

| Argument | What it does |
|---|---|
| `--demo` | Skips onboarding and drops you into the four tabs with sample history |
| `--audit-setup` | Starts at the profile/setup part of onboarding |
| `--audit-post-setup` | Opens the plan summary, commitment and Pro screens |

Run without arguments to use whatever state is already saved. Settings also has a **Review setup** (*Xem lại thiết lập*) entry.

**Adding a Swift file?** Run `python3 scripts/generate_project.py` afterwards, or Xcode won't see it.

## How the code is laid out

Everything lives in `DopafitRebuild/`. The main files:

| File | What's in it |
|---|---|
| `Models.swift` | Sets, sessions, plans, gyms, history, saving to disk, and the workout generator |
| `DailyCheckinModels.swift` | The "how are you today" rules, the return-from-break ramp, missed sessions, the busy-machine swap |
| `Design.swift` | Colors, fonts (including the text-size scale), buttons, cards, sheets |
| `WorkoutViews.swift` | Home, the active workout, set entry, timers, swaps, supersets |
| `HomeCheckinViews.swift` | The check-in, pain and time sheets, the reason line, the missed-session card |
| `WorkoutDiscoveryViews.swift` | Week calendar, muscle suggestions, challenges |
| `WorkoutProgramViews.swift` | Programs by muscle group |
| `ExerciseLibrary.swift` | The exercise picker and its filters |
| `ExerciseGuide.swift`, `ExerciseSetupTips.swift` | Exercise guide, setup tips and common mistakes |
| `ExerciseDBMedia.swift`, `ExerciseLoopVideo.swift` | Which video to show for which exercise, and the looping player |
| `BodyAndGoalsViews.swift` | Body tab (results, recovery) and Goals tab |
| `ProgressViews.swift`, `MetricDetailView.swift` | Log, session detail, charts |
| `SettingsViews.swift` | Plan settings, gyms, profile, export, reminders |
| `OnboardingView.swift`, `SetupOnboardingView.swift`, `PostSetupFlow.swift` | Onboarding from welcome to the Pro screen |

Model checks live in `tests/ModelChecks.swift`. They cover the rules (progression, check-ins, undo, deload, gentle mode and so on), not the UI.

## Data

App state is saved as JSON under Application Support (`DopafitRebuild/state.json`) inside the app sandbox, written atomically after every meaningful change. Reinstalling a build keeps your data. Weights are stored in kg; the UI can show lb. New fields are optional so older saved files keep loading.

## Media, and where it came from

Exercise video comes from three places, picked in this order:

1. **A real-person plank video** from Pexels.
2. **3D demo clips for 21 exercises** (19 with a female version) from [free-exercise-db-with-videos](https://github.com/buzops9/exercisedb). Cropped to square and compressed by `scripts/build-zenith-media.py`.
3. **ExerciseDB clips** for the rest. These are low resolution (180 px).

Exercises with no correct video are hidden from the library, programs and generated workouts, but kept in your history.

Photos on the challenge and program cards are real stock photos from Unsplash and Pexels, used unedited. Sources, photographers and hashes are listed in `third_party/challenge-photos/manifest.json`.

> ⚠️ **The 3D demo clips are not licensed.** The repo they came from is MIT for code and text, but its author says he bought the videos from an Instagram ad and doesn't know who made them. We're using them for a demo only. Buy a proper license, or replace them, before this goes anywhere public. The raw 1080p downloads in `third_party/zenith-video/raw*` shouldn't be pushed to a public repo either.

`third_party/exercise-animations/upstream/` is a separate clone of [blwsk/exercise-animations](https://github.com/blwsk/exercise-animations) and is ignored by git. See `third_party/exercise-animations/UPSTREAM.md` for how to fetch it again.

## What this isn't

- **It's not the original Dopafit.** We don't have its source, backend, video library or algorithms. Screens were rebuilt from screenshots of the original app (they're in [Figma](https://www.figma.com/design/2lNpfPEq2wVnGk07bVLghz/Dopafit?node-id=1-24)), and a lot has changed since on purpose.
- **The training logic is ours.** Workout generation, progression, recovery, calorie estimates and the pain rules are simple local rules written for this project. The joint-load mapping behind "something hurts" is a best guess and should be reviewed by someone with a physio or coaching background.
- **It's not medical advice.** The pain option only swaps or lightens exercises. Sharp pain, numbness or swelling means stop and see a doctor, and the app says so.
- **Some things just aren't built:** real sign-in, subscriptions, cloud sync, Apple Watch, and writing workouts to Apple Health (the app only reads height and weight).

## If you're picking this up

Start with [AGENTS.md](AGENTS.md), then the top of [CHANGELOG.md](CHANGELOG.md). After that, [rebuild/HANDOFF.md](rebuild/HANDOFF.md), [rebuild/SCREEN-COVERAGE.md](rebuild/SCREEN-COVERAGE.md) and [rebuild/OPEN-GAPS.md](rebuild/OPEN-GAPS.md). The changelog is the honest record. Every entry says what changed, how it was checked and what's still unverified. Please keep it that way.

The research behind the product decisions is in [research/2026-11-09/REPORT.md](research/2026-11-09/REPORT.md), covering the US market, competitors and why people quit. The original-app audits are under `rebuild/`.

The older Vietnamese README is kept at `rebuild/archive/README-vi-2026-11-11.md`.
