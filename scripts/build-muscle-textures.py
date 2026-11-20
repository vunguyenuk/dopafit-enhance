#!/usr/bin/env python3
"""Ảnh nền cho mô hình 3D bản đồ cơ (kiểu giáp kim loại có đường ghép, như ảnh cơ thể trên landing page).

Từ hình nhóm cơ 2D (body-shapes.json) dựng 3 ảnh 2048x2048 cùng bố cục UV với muscle-body.bin:
  muscle-id.png      – mỗi điểm ảnh mang số thứ tự nhóm cơ (0 = thân), app tô màu theo số này
  muscle-seam.png    – đường ghép mảnh giữa các nhóm cơ (0..255)
  muscle-normal.png  – bản đồ pháp tuyến cho đường ghép lõm xuống, bắt sáng như rãnh trên giáp
Cần: numpy, scipy, Pillow.
"""
import json
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage

ROOT = Path(__file__).resolve().parents[1]
D = ROOT / 'DopafitRebuild/BodyShapes'
meta = json.loads((D / 'muscle-body.json').read_text())
shapes = json.loads((D / 'body-shapes.json').read_text())['male']
T = int(meta['texture']); S = meta['scale']; BASE = meta['baseline']
SKIP = {'head', 'hair', 'hands', 'feet'}          # để trơn như ma-nơ-canh
MERGE = {'knees', 'ankles'}
# độ rõ của rãnh trong cùng một nhóm cơ (bụng rõ múi; còn lại mờ)
MINOR = {'abs': 0.75}
# nhóm chung một khối khi dựng hình (vẫn tô màu riêng): ống chân liền bắp chân, cổ liền cơ thang
SEAM_GROUP = {'tibialis': 'calves', 'neck': 'trapezius'}
# độ phồng tương đối từng nhóm cơ (1 = lớn nhất)
AMP = {'chest': 1.0, 'deltoids': 1.0, 'quadriceps': 0.9, 'gluteal': 0.9, 'biceps': 0.85, 'triceps': 0.8,
       'calves': 0.85, 'abs': 0.55, 'obliques': 0.5, 'upper-back': 0.6, 'trapezius': 0.7, 'lower-back': 0.45,
       'hamstring': 0.8, 'forearm': 0.6, 'adductors': 0.55, 'tibialis': 0.5, 'neck': 0.35}
slugs = []
for side in ('front', 'back'):
    for p in shapes[side]['parts']:
        if p['slug'] not in SKIP | MERGE and p['slug'] not in slugs: slugs.append(p['slug'])

# vẽ từng mảnh (mỗi đa giác một số) để giữ cả rãnh trong một nhóm cơ (6 múi bụng, 3 đầu đùi trước...)
img = Image.new('I', (T, T), 0); dr = ImageDraw.Draw(img)
plabel = [0]          # mảnh -> nhóm cơ (0 thân trơn, 254 đầu/tay/bàn chân, 255 mảnh bỏ)
for side, cx in (('front', meta['frontCenter']), ('back', meta['backCenter'])):
    for p in shapes[side]['parts']:
        k = 254 if p['slug'] in SKIP else 255 if p['slug'] in MERGE else slugs.index(p['slug']) + 1
        for poly in p['polys']:
            plabel.append(k)
            dr.polygon([(cx + x * S, BASE - y * S) for x, y in poly], fill=len(plabel) - 1)
pieces = np.array(img, np.int32); plabel = np.array(plabel)
smooth_ids = np.flatnonzero(plabel == 254)   # đầu, tóc, tay, bàn chân: gộp thành một mảnh, không có rãnh
pieces[np.isin(pieces, smooth_ids)] = smooth_ids[0]

# lấp khe giữa các mảnh để còn lại đường ghép mảnh
dist, (iy, ix) = ndimage.distance_transform_edt(pieces == 0, return_indices=True)
pieces = np.where((pieces == 0) & (dist <= 9), pieces[iy, ix], pieces)
# bỏ các mảnh trang trí có gai (đầu gối, cổ chân): nhập vào mảnh bên cạnh
drop = (plabel[pieces] == 255) & (pieces > 0)
_, (iy, ix) = ndimage.distance_transform_edt(drop | (pieces == 0), return_indices=True)
pieces = np.where(drop, pieces[iy, ix], pieces)
# làm tròn viền: mỗi mảnh được làm mờ rồi chọn mảnh mạnh nhất -> hết răng cưa, gai nhọn
best = ndimage.gaussian_filter((pieces == 0).astype(np.float32), 10); out = np.zeros_like(pieces)
for k, sl in enumerate(ndimage.find_objects(pieces), start=1):
    if sl is None: continue
    sl = tuple(slice(max(z.start - 24, 0), z.stop + 24) for z in sl)
    m = ndimage.gaussian_filter((pieces[sl] == k).astype(np.float32), 10)
    sel = m > best[sl]; best[sl][sel] = m[sel]; out[sl][sel] = k
pieces = out
# lỗ trống lọt giữa các mảnh (đầu gối): lấp bằng mảnh gần nhất
holes = ndimage.binary_fill_holes(pieces > 0) & (pieces == 0)
_, (iy, ix) = ndimage.distance_transform_edt(pieces == 0, return_indices=True)
pieces = np.where(holes, pieces[iy, ix], pieces)
filled = plabel[pieces].astype(np.uint8)

# đường ghép 2 cấp: giữa hai nhóm cơ khác nhau (rõ) và giữa các mảnh trong cùng một nhóm (mờ, nông)
grp = np.arange(256)
for a_, b2 in SEAM_GROUP.items():
    if a_ in slugs and b2 in slugs: grp[slugs.index(a_) + 1] = slugs.index(b2) + 1
G = grp[filled]
major = np.zeros(pieces.shape, bool); minor = np.zeros(pieces.shape, bool)
for dy, dx in ((0, 1), (1, 0)):
    b_ = np.roll(pieces, (-dy, -dx), (0, 1)); lb = np.roll(G, (-dy, -dx), (0, 1))
    inside = (pieces > 0) & (b_ > 0) & (pieces != b_)
    major |= inside & (G != lb); minor |= inside & (G == lb) & (filled == np.roll(filled, (-dy, -dx), (0, 1)))
mstr = np.array([MINOR.get(slugs[k - 1], 0.0) if 0 < k <= len(slugs) else 0 for k in range(256)], np.float32)
seam = np.maximum(ndimage.gaussian_filter(major.astype(np.float32), 0.9) * 2.2,
                  ndimage.gaussian_filter(minor.astype(np.float32), 0.9) * 2.2 * mstr[filled] * 1.6)
seam = np.clip(seam, 0, 1)

# khối cơ: cả nhóm cơ là một vòm liền, cao ở giữa, thoải dần về ranh giới nhóm
d = ndimage.distance_transform_edt(~major & (pieces > 0)).astype(np.float32)
height = np.zeros_like(d)
for k in range(1, len(slugs) + 1):
    if grp[k] != k: continue
    comp, nc = ndimage.label(G == k)
    if nc == 0: continue
    mx = np.ones(nc + 1, np.float32); mx[1:] = np.maximum(ndimage.maximum(d, comp, index=np.arange(1, nc + 1)), 1)
    t = np.clip(d / mx[comp], 0, 1)
    dome = np.sin(t * np.pi / 2) ** 0.75   # căng đầy kiểu fitness, vẫn tròn
    height = np.where(comp > 0, dome * AMP.get(slugs[k - 1], 0.6), height)
# rãnh nông giữa các mảnh trong cùng nhóm (múi bụng, đầu cơ đùi)
dmin = ndimage.distance_transform_edt(~minor).astype(np.float32)
height -= np.exp(-dmin / 7) * mstr[filled] * np.where(filled > 0, height.max() * 0.35, 0)
height = np.clip(height, 0, None)
height = ndimage.gaussian_filter(height, 5.0)
# ra ngoài viền hình: giữ giá trị gần nhất để hai bên sườn không bị lõm
_, (iy, ix) = ndimage.distance_transform_edt(pieces == 0, return_indices=True)
height = np.where(pieces == 0, height[iy, ix], height)
height = ndimage.gaussian_filter(height, 2.0)
filled[filled >= 254] = 0   # đầu, tay, bàn chân: trơn

# rãnh lõm + vòm cơ -> bản đồ pháp tuyến cho chi tiết nhỏ (rãnh); khối lớn nằm ở hình 3D
hmap = -ndimage.gaussian_filter(seam, 1.4)
gy, gx = np.gradient(hmap); k = 3.0
n = np.dstack([-gx * k, gy * k, np.ones_like(hmap)]); n /= np.linalg.norm(n, axis=2, keepdims=True)
normal = ((n * 0.5 + 0.5) * 255).astype(np.uint8)
Image.fromarray((np.clip(height, 0, 1) * 65535).astype(np.uint16)).save(D / 'muscle-height.png')

Image.fromarray(filled.astype(np.uint8)).save(D / 'muscle-id.png', optimize=True)
Image.fromarray((seam * 255).astype(np.uint8)).save(D / 'muscle-seam.png', optimize=True)
Image.fromarray(normal).save(D / 'muscle-normal.png', optimize=True)
meta['ids'] = slugs
(D / 'muscle-body.json').write_text(json.dumps(meta, ensure_ascii=False, indent=1))
print(len(slugs), slugs)
