# Native pulse capture — 10/11/2026

C55-0…6 are the earlier low-contrast native pulse. C59-0…6 are after adding diffuse intensity modulation. Both captures are static-pose native SceneKit, not moving Three.js models. Screenshot size854×1858; ROI x400…409,y450…489 is inside the active thigh. AppKit decoded existing PNGs; no UI capture was performed outside CUA.

Seven C59 samples captured over about3.6seconds. Mean green channel varied approximately0.460…0.522, compared with0.511…0.525 in C55. This supports changing illumination in a fixed region; it does not establish pixel parity, flicker compliance, or full Reduce Motion behavior. Stronger pulse source modulates active-material diffuse intensity0.6…1 and emission0.02…0.17 over1.8seconds. Inactive materials remain stable. Reduce Motion is implemented but has not been independently UI-tested.

JSON: native-pulse-measurement.json and native-pulse-final-measurement.json. C41 is the older yellow clipping defect, not passing evidence for current lighting.
