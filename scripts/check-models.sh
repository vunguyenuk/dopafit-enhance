#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
export DEVELOPER_DIR="${DOPAFIT_XCODE:-/Users/vunguyen/Desktop/Xcode-beta.app}/Contents/Developer"
mkdir -p .build rebuild
xcrun swiftc -parse-as-library DopafitRebuild/Models.swift DopafitRebuild/ExerciseLibraryFilter.swift DopafitRebuild/WorkoutDiscoveryModels.swift DopafitRebuild/WorkoutProgramModels.swift DopafitRebuild/DailyCheckinModels.swift tests/ModelChecks.swift -o .build/ModelChecks > rebuild/model-build.log 2>&1
.build/ModelChecks | tee rebuild/model-checks.log
