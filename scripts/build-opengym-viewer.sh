#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
dopafit_viewer_tools=".build/opengym-viewer-tools"
mkdir -p "$dopafit_viewer_tools"
cp third_party/opengym3d/viewer-package.json "$dopafit_viewer_tools/package.json"
cp third_party/opengym3d/viewer-package-lock.json "$dopafit_viewer_tools/package-lock.json"
npm ci --prefix "$dopafit_viewer_tools" --no-audit --no-fund
cp scripts/opengym/viewer-entry.js "$dopafit_viewer_tools/entry.js"
"$dopafit_viewer_tools/node_modules/.bin/esbuild" "$dopafit_viewer_tools/entry.js" --bundle --format=iife --minify --outfile=DopafitRebuild/OpenGym3D/viewer.js
cp "$dopafit_viewer_tools/node_modules/three/LICENSE" DopafitRebuild/OpenGym3D/licenses/Three-MIT.txt
