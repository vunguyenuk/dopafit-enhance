#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
export DEVELOPER_DIR="${DOPAFIT_XCODE:-/Users/vunguyen/Desktop/Xcode-beta.app}/Contents/Developer"
mkdir -p .build/v2-progress-tests
python3 - <<'PY'
from pathlib import Path
s=Path('DopafitV2/DopafitV2/OnboardingChoices.swift').read_text()
Path('.build/v2-progress-tests/ProfileChoices.swift').write_text(s[:s.index('struct OnboardingPage')])
PY
xcrun swiftc -parse-as-library DopafitV2/DopafitV2/Models.swift DopafitV2/DopafitV2/Catalog.swift DopafitV2/DopafitV2/Analytics.swift .build/v2-progress-tests/ProfileChoices.swift tests/V2ProgressChecks.swift -o .build/v2-progress-tests/checks > .build/v2-progress-tests/build.log 2>&1
.build/v2-progress-tests/checks
