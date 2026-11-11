# OpenGym3D-derived muscular media

User explicitly requested OpenGym3D assets and a more muscular model. This directory preserves provenance and editable source across Codex accounts.

- `manifest.json`: pinned upstream commit/archive/original model hashes, separately the four shipped derivative hashes and three exercise mappings.
- `generation.json`: adult male MakeHuman macros/detail targets, baked before export.
- `workfiles/muscular_source.blend`: editable baked CC0 mesh/default rig. No MPFB add-on code is embedded in the app bundle.
- `retarget-report.json`: v1 rotations transferred by bone name onto new rest skeleton, preserving new limb lengths.
- `geometry-qa.json`: shipped GLB SHA, all214frames structurally checked. This detects nonfinite/large deformation, not all self-intersections or exercise form errors.
- `viewer-package*.json`: pinned offline Three.js/esbuild tooling. Runtime JS and license notices are bundled in the app.

See ../../rebuild/OPENGYM-INTEGRATION.md for exact limitations and the selected simulator cases verified in C23–C32. Existing C15–C22 screenshots show the old v1 mannequin. The muscular PNG previews are authored Blender renders, never original Dopafit or simulator captures. New loading/error placeholder UI remains unverified. Keep Figma's original evidence unchanged.

Do not run an old restore script over the muscular bundle. `scripts/prepare_opengym_assets.py` only stages upstream sources under.build; final promotion requires retarget + geometry QA + visual review + hash updates + simulator checks. `run-simulator.sh` now gates build/install on asset integrity.
