#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
export DEVELOPER_DIR="${DOPAFIT_XCODE:-/Users/vunguyen/Desktop/Xcode-beta.app}/Contents/Developer"
mkdir -p .build/v2-onboarding-tests
python3 - <<'PY'
from pathlib import Path
source=Path('DopafitV2/DopafitV2/OnboardingChoices.swift').read_text()
Path('.build/v2-onboarding-tests/ProfileChoices.swift').write_text(source[:source.index('struct OnboardingPage')])
source=Path('DopafitV2/DopafitV2/Onboarding.swift').read_text()
def block(start):
    a=source.index(start); b=source.index('{',a); depth=1; i=b+1
    while depth:
        if source[i]=='{':depth+=1
        elif source[i]=='}':depth-=1
        i+=1
    return source[a:i]
route=block('    enum Step:')+'\n'+block('    private static func makeSteps(').replace('private static','static',1)
Path('.build/v2-onboarding-tests/Route.swift').write_text('import Foundation\nenum Route {\n'+route+'\n}\n')
PY
xcrun swiftc -parse-as-library DopafitV2/DopafitV2/Models.swift DopafitV2/DopafitV2/Catalog.swift DopafitV2/DopafitV2/Analytics.swift .build/v2-onboarding-tests/ProfileChoices.swift .build/v2-onboarding-tests/Route.swift tests/V2OnboardingChecks.swift -o .build/v2-onboarding-tests/checks > .build/v2-onboarding-tests/build.log 2>&1
.build/v2-onboarding-tests/checks
