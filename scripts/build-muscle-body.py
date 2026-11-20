#!/usr/bin/env python3
"""Dựng dữ liệu mô hình 3D "bản đồ cơ" cho màn Hồi phục.

Thân 3D: MakeHuman CC0 (DopafitRebuild/Form3D/neutral.glb), giữ nguyên bề mặt mịn.
Hình nhóm cơ: react-native-body-highlighter (MIT), DopafitRebuild/BodyShapes/body-shapes.json.
Mỗi đỉnh được gán toạ độ ảnh (UV) trỏ vào hình 2D mặt trước hoặc mặt sau, nên app chỉ cần
vẽ hình 2D thành ảnh rồi dán lên thân 3D: đường chia cơ sắc nét, bề mặt không bị sần.

Đầu ra: DopafitRebuild/BodyShapes/muscle-body.bin + muscle-body.json
"""
import json, struct
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
GLB = ROOT / 'DopafitRebuild/Form3D/neutral.glb'
OUT = ROOT / 'DopafitRebuild/BodyShapes'
MUSCLE = 0.016   # độ phồng tối đa của khối cơ (m)
ARM_GROW = 0.16; SHOULDER = 0.11; WAIST = 0.07; CHEST = 0.014; LEGS_IN = 0.085
TEX = 2048; SCALE = 1137.0; FRONT_CX = 512.0; BACK_CX = 1536.0; BASE = 2019.0

f = GLB.read_bytes()
L = struct.unpack('<I', f[12:16])[0]; js = json.loads(f[20:20 + L]); BIN = 20 + L + 8
def acc(i, comps, dtype):
    a = js['accessors'][i]; v = js['bufferViews'][a['bufferView']]
    off = BIN + v.get('byteOffset', 0) + a.get('byteOffset', 0)
    return np.frombuffer(f, dtype=dtype, count=a['count'] * comps, offset=off).reshape(a['count'], comps)
prim = js['meshes'][0]['primitives'][0]
P = acc(prim['attributes']['POSITION'], 3, np.float32).astype(np.float64)
N = acc(prim['attributes']['NORMAL'], 3, np.float32).astype(np.float64)
I = acc(prim['indices'], 1, np.uint32).reshape(-1, 3)
x, h, z = P[:, 0], P[:, 1], P[:, 2]          # glTF: y lên trên, mặt trước hướng +z

# --- đầu ma-nơ-canh: làm mịn mặt (mắt, mũi, miệng, tai) thành khối trơn như ảnh trên landing page ---
from scipy import sparse
nv = len(P)
rows = np.concatenate([I[:, 0], I[:, 1], I[:, 2], I[:, 1], I[:, 2], I[:, 0]])
cols = np.concatenate([I[:, 1], I[:, 2], I[:, 0], I[:, 0], I[:, 1], I[:, 2]])
Adj = sparse.csr_matrix((np.ones(len(rows)), (rows, cols)), shape=(nv, nv)); Adj.data[:] = 1
deg = np.asarray(Adj.sum(1)).ravel(); deg[deg == 0] = 1
# chiếu đầu lên một khối elip (đầu trứng không mặt), rồi làm mịn vùng cổ chuyển tiếp
hm = P[:, 1] > 1.62
top = P[hm, 1].max(); chin = 1.545
c = np.array([np.median(P[hm, 0]), (top + chin) / 2, np.median(P[hm, 2]) - 0.02])
band = hm & (np.abs(P[:, 1] - (c[1] + 0.01)) < 0.03)
r = np.array([np.percentile(np.abs(P[band, 0] - c[0]), 97), (top - chin) / 2,
              np.percentile(np.abs(P[band, 2] - c[2]), 92)])
d = (P - c) / r
E = c + r * d / (np.linalg.norm(d, axis=1, keepdims=True) + 1e-9)
w = np.clip((P[:, 1] - 1.545) / 0.06, 0, 1)[:, None]
w = w * w * (3 - 2 * w)
P = P + w * (E - P)
ws = np.clip(1 - np.abs(P[:, 1] - 1.56) / 0.045, 0, 1)[:, None]
for _ in range(25):
    P = P + 0.5 * ws * ((Adj @ P) / deg[:, None] - P)
w = np.maximum(w, ws)
fn0 = np.cross(P[I[:, 1]] - P[I[:, 0]], P[I[:, 2]] - P[I[:, 0]])
Nn = np.zeros_like(P)
for c in range(3): np.add.at(Nn, I[:, c], fn0)
Nn /= np.linalg.norm(Nn, axis=1, keepdims=True) + 1e-12
N = np.where(w > 0, Nn, N)
x, h, z = P[:, 0], P[:, 1], P[:, 2]

# --- tay tách khỏi thân bên dưới nách: tìm các mảng liền nhau ---
low = h < 1.30
parent = np.arange(len(P))
def find(a):
    while parent[a] != a:
        parent[a] = parent[parent[a]]; a = parent[a]
    return a
for tri in I:
    for a, b in ((tri[0], tri[1]), (tri[1], tri[2])):
        if low[a] and low[b]:
            ra, rb = find(a), find(b)
            if ra != rb: parent[ra] = rb
roots = np.array([find(i) for i in range(len(P))])
from collections import Counter
comps = Counter(roots[low]).most_common(3)
arm = np.zeros(len(P), bool)
for r, _ in comps[1:]: arm |= (roots == r) & low

# --- ánh xạ (x, chiều cao) của thân 3D -> toạ độ hình 2D ---
def U(r):
    r2 = r * r; return np.where(r2 > 0, r2 * np.log(r2 + 1e-20), 0)
legs3 = [(0.8,-0.202,-0.013),(0.65,-0.195,-0.06),(0.5,-0.214,-0.106),(0.35,-0.234,-0.129),(0.2,-0.24,-0.174),(0.08,-0.246,-0.18)]
legs2 = [(0.752,-0.178,-0.013),(0.611,-0.155,-0.044),(0.47,-0.158,-0.061),(0.329,-0.162,-0.053),(0.188,-0.138,-0.076),(0.075,-0.149,-0.072)]
tor3 = [(0.95,-0.17),(1.05,-0.159),(1.15,-0.138),(1.25,-0.146),(1.35,-0.25),(1.45,-0.255)]
tor2 = [(0.897,-0.173),(0.996,-0.152),(1.096,-0.139),(1.195,-0.145),(1.295,-0.243),(1.395,-0.243)]
src = [(0,1.819),(0,1.589),(0,1.511),(0,1.2),(0,0.889)]; dst = [(0,1.709),(0,1.533),(0,1.442),(0,1.153),(0,0.836)]
for (hh,o3,i3),(y,o2,i2) in zip(legs3, legs2):
    for s in (1,-1): src += [(s*o3,hh),(s*i3,hh)]; dst += [(s*o2,y),(s*i2,y)]
for (hh,x3),(y,x2) in zip(tor3, tor2):
    for s in (1,-1): src.append((s*x3,hh)); dst.append((s*x2,y))
for s in (1,-1): src.append((s*-0.215,0.0)); dst.append((s*-0.11,0.0))
src = np.array(src, float); dst = np.array(dst, float); n = len(src)
K = U(np.linalg.norm(src[:, None] - src[None], axis=2)); Pm = np.hstack([np.ones((n, 1)), src])
A = np.zeros((n + 3, n + 3)); A[:n, :n] = K + np.eye(n) * 1e-5; A[:n, n:] = Pm; A[n:, :n] = Pm.T
W = np.linalg.solve(A, np.vstack([dst, np.zeros((3, 2))]))
def body_map(q):
    k = U(np.linalg.norm(q[:, None] - src[None], axis=2)); return k @ W[:n] + np.hstack([np.ones((len(q), 1)), q]) @ W[n:]
T3 = np.array([-0.194, 1.285]); B3 = np.array([-0.186, 0.697]); T2 = np.array([-0.225, 1.292]); B2 = np.array([-0.367, 0.749])
def arm_map(q):
    s = np.sign(q[:, 0]); s[s == 0] = 1; xx = q[:, 0] * -s
    t = (T3[1] - q[:, 1]) / (T3[1] - B3[1]); ax = T3[0] + (B3[0] - T3[0]) * t; d = xx - ax
    a2 = T2[None] + (B2 - T2)[None] * t[:, None]
    u = (B2 - T2) / np.linalg.norm(B2 - T2); nr = np.array([-u[1], u[0]])
    if nr[0] < 0: nr = -nr
    p = a2 + nr[None] * (d[:, None] * 1.2); p[:, 0] *= -s; return p
q = np.stack([x, h], 1); Q = np.zeros_like(q)
Q[~arm] = body_map(q[~arm]); Q[arm] = arm_map(q[arm])

P0 = P.copy()
# --- đắp khối cơ: đẩy bề mặt ra theo vòm từng nhóm cơ (muscle-height.png, từ build-muscle-textures.py) ---
from PIL import Image
from scipy import ndimage as ndi
Hm = np.asarray(Image.open(OUT / 'muscle-height.png'), np.float64) / 65535
def samp(px, py): return ndi.map_coordinates(Hm, [py, px], order=1, mode='nearest')
py_ = BASE - Q[:, 1] * SCALE
hf = samp(FRONT_CX + Q[:, 0] * SCALE, py_); hb = samp(BACK_CX - Q[:, 0] * SCALE, py_)
wf = np.clip((N[:, 2] + 0.35) / 0.7, 0, 1); wf = wf * wf * (3 - 2 * wf)
hv = wf * hf + (1 - wf) * hb
hv *= np.clip((1.555 - P[:, 1]) / 0.03, 0, 1)
P = P + N * (hv * MUSCLE)[:, None]
for _ in range(3):   # làm mịn nhẹ để vòm cơ liền mạch, không gợn
    P = P + 0.3 * ((Adj @ P) / deg[:, None] - P) * (hv > 0)[:, None]
fn0 = np.cross(P[I[:, 1]] - P[I[:, 0]], P[I[:, 2]] - P[I[:, 0]])
N = np.zeros_like(P)
for c in range(3): np.add.at(N, I[:, c], fn0)
N /= np.linalg.norm(N, axis=1, keepdims=True) + 1e-12

# --- dáng fitness (chữ V): vai rộng, tay to, eo thon, hai chân đứng gọn ---
def sm(t): t = np.clip(t, 0, 1); return t * t * (3 - 2 * t)
y0 = P0[:, 1]; ax_ = np.abs(P0[:, 0]); sx = np.sign(P0[:, 0])
# 1) tay to hơn: phóng to quanh trục giữa của từng cánh tay
for r, _ in comps[1:]:
    m = (roots == r) & low
    bins = np.round(y0[m] / 0.02).astype(int)
    for bval in np.unique(bins):
        sel = np.flatnonzero(m)[bins == bval]
        c = P[sel][:, [0, 2]].mean(0)
        g = ARM_GROW * sm((y0[sel] - 0.80) / 0.25) * sm((1.31 - y0[sel]) / 0.16)   # bắp tay to nhất, thoải dần lên vai và xuống cổ tay
        P[sel, 0] = c[0] + (P[sel, 0] - c[0]) * (1 + g[:, None][:, 0])
        P[sel, 2] = c[1] + (P[sel, 2] - c[1]) * (1 + g[:, None][:, 0])
# 2) vai rộng: kéo phần ngực-vai và cả cánh tay ra hai bên
gw = np.where(arm, 1.0, sm((y0 - 1.08) / 0.17) * sm((1.60 - y0) / 0.14))
P[:, 0] *= 1 + SHOULDER * gw
# 3) eo thon
gwaist = np.where(arm, 0, sm((y0 - 0.92) / 0.08) * sm((1.20 - y0) / 0.10))
P[:, 0] *= 1 - WAIST * gwaist; P[:, 2] *= 1 - WAIST * 0.6 * gwaist
# 4) ngực dày, lưng xô rộng
gch = np.where(arm, 0, sm((y0 - 1.20) / 0.08) * sm((1.48 - y0) / 0.08))
P[:, 2] += np.where(P0[:, 2] > 0, CHEST * gch * sm((0.16 - ax_) / 0.08), 0)
# 5) hai chân khép lại cho dáng đứng gọn
gl = np.where(arm, 0, sm((0.92 - y0) / 0.85)) * sm(ax_ / 0.04)
P[:, 0] -= sx * LEGS_IN * gl
fn0 = np.cross(P[I[:, 1]] - P[I[:, 0]], P[I[:, 2]] - P[I[:, 0]])
N = np.zeros_like(P)
for c in range(3): np.add.at(N, I[:, c], fn0)
N /= np.linalg.norm(N, axis=1, keepdims=True) + 1e-12

# --- tách mặt trước / mặt sau theo hướng mặt tam giác, gán UV ---
fn = np.cross(P[I[:, 1]] - P[I[:, 0]], P[I[:, 2]] - P[I[:, 0]])
front_face = fn[:, 2] >= 0
verts = {}; pos = []; nor = []; uv = []; idx = []
def vid(v, front):
    key = (int(v), bool(front))
    if key not in verts:
        verts[key] = len(pos); pos.append(P[v]); nor.append(N[v])
        x2, y2 = Q[v]
        px = FRONT_CX + x2 * SCALE if front else BACK_CX - x2 * SCALE
        if P[v, 1] > 1.56: uv.append(((FRONT_CX + (P[v, 0] + 0.3 * P[v, 2]) * SCALE * 0.3) / TEX, (BASE - (1.70 + (P[v, 1] - 1.70) * 0.3) * SCALE) / TEX))   # đầu trứng: một điểm trơn, không rãnh
        else: uv.append((px / TEX, (BASE - y2 * SCALE) / TEX))
    return verts[key]
for t, fr in zip(I, front_face):
    idx.extend(vid(v, fr) for v in t)
pos = np.asarray(pos, np.float32); nor = np.asarray(nor, np.float32); uv = np.asarray(uv, np.float32); idx = np.asarray(idx, np.uint32)
OUT.mkdir(parents=True, exist_ok=True)
with open(OUT / 'muscle-body.bin', 'wb') as o:
    o.write(pos.tobytes()); o.write(nor.tobytes()); o.write(uv.tobytes()); o.write(idx.tobytes())
old = json.loads((OUT / 'muscle-body.json').read_text()) if (OUT / 'muscle-body.json').exists() else {}
meta = {'vertexCount': int(len(pos)), 'indexCount': int(len(idx)), 'height': float(h.max()),
        'texture': TEX, 'scale': SCALE, 'frontCenter': FRONT_CX, 'backCenter': BACK_CX, 'baseline': BASE,
        'layout': 'float32 position[v*3], float32 normal[v*3], float32 uv[v*2], uint32 index[i]',
        'source': 'Thân: MakeHuman CC0 (Form3D/neutral.glb). Hình cơ: react-native-body-highlighter 3.2.0, MIT.'}
if 'ids' in old: meta['ids'] = old['ids']
(OUT / 'muscle-body.json').write_text(json.dumps(meta, ensure_ascii=False, indent=1))
print(meta)
