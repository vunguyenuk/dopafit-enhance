# Character asset provenance

The Form v2 human is derived from MakeHuman **graphical assets**. MakeHuman's graphical assets are CC0-1.0; its application source code has a different license and is not incorporated into this project's character builder.

Official license: https://static.makehumancommunity.org/about/license.html

Pinned repository: https://github.com/makehumancommunity/makehuman/tree/a8bc2d54ff0ac92e78ff71431b1023eda42bf482

Bundled source assets in `assets/source/makehuman/`:

- `base.obj`
- `default.mhskel`
- `default_weights.mhw`
- `african-male-young.target`, `asian-male-young.target`, `caucasian-male-young.target` (equal blend)
- `universal-male-young-maxmuscle-averageweight.target` (75%)
- `universal-male-young-maxmuscle-minweight.target` (25%)
- The upstream `LICENSE.md` and `LICENSE.ASSETS.md`

The original rig/weight metadata credits Data Collection AB, Joel Palmius, and Jonas Hauquier. The source data and derivative meshes remain CC0. The runtime binary's SHA-256 is recorded in `src/character/generated/figure.json`.

The conversion, subdivision implementation, rig adaptation, muscle painting, and studio interface are project code. The dumbbells, barbell, bench, and rack remain procedurally authored in this project. No MakeHuman application code is executed or bundled.
