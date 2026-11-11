#!/bin/zsh
# Ảnh thay cho nhóm Mông/Chân (trùng ảnh challenge-lower-28). Pexels License.
# TMA Management (@modelstma), Pexels 31028213 — https://www.pexels.com/photo/focused-woman-exercising-in-a-dark-gym-setting-31028213/
set -u
cd "${0:A:h:h}"
mkdir -p third_party/challenge-photos/incoming
curl -fsSL --retry 2 -o third_party/challenge-photos/incoming/pexels-31028213.jpg "https://images.pexels.com/photos/31028213/pexels-photo-31028213.jpeg?cs=srgb&dl=pexels-modelstma-31028213.jpg&fm=jpg" && echo "Xong: đã tải ảnh" || echo "Lỗi tải ảnh"
