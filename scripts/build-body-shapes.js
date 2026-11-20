// Chuẩn bị: cd third_party/body-highlighter && npm pack react-native-body-highlighter@3.2.0 && tar xzf react-native-body-highlighter-3.2.0.tgz; npm i svgpath@2.6.0 playwright
// Chạy: node scripts/build-body-shapes.js DopafitRebuild/BodyShapes/body-shapes.json
// Lấy mẫu đường SVG của react-native-body-highlighter (MIT) thành đa giác, chuẩn hoá về mét, cho mô hình 3D trong app.
const fs=require('fs'),path=require('path'),svgpath=require('svgpath');const {chromium}=require('playwright');
const P=path.join(__dirname,'../third_party/body-highlighter/package/dist');const A=f=>require(path.join(P,'assets',f));
const wrap=f=>fs.readFileSync(path.join(P,'components',f),'utf8');
const border=(src,side)=>{const m=src.match(new RegExp('side === "'+side+'" && \\(<react_native_svg_1\\.Path[^>]*?d="([^"]+)"'));return m&&m[1]};
const G={male:{front:A('bodyFront.js').bodyFront,back:A('bodyBack.js').bodyBack,w:wrap('SvgMaleWrapper.js')},
         female:{front:A('bodyFemaleFront.js').bodyFemaleFront,back:A('bodyFemaleBack.js').bodyFemaleBack,w:wrap('SvgFemaleWrapper.js')}};
function split(d){const abs=svgpath(d).abs().toString();return abs.split(/(?=M)/).map(s=>s.trim()).filter(s=>s.length>2)}
function rdp(pts,eps){if(pts.length<3)return pts;let dmax=0,idx=0;const [ax,ay]=pts[0],[bx,by]=pts[pts.length-1];const L=Math.hypot(bx-ax,by-ay)||1;
 for(let i=1;i<pts.length-1;i++){const d=Math.abs((by-ay)*pts[i][0]-(bx-ax)*pts[i][1]+bx*ay-by*ax)/L;if(d>dmax){dmax=d;idx=i}}
 if(dmax>eps){return rdp(pts.slice(0,idx+1),eps).slice(0,-1).concat(rdp(pts.slice(idx),eps))}return [pts[0],pts[pts.length-1]]}
(async()=>{const b=await chromium.launch();const p=await b.newPage();await p.setContent('<svg xmlns="http://www.w3.org/2000/svg"><path id="p"/></svg>');
 const sample=async d=>p.evaluate((d)=>{const el=document.getElementById('p');el.setAttribute('d',d);const L=el.getTotalLength();const n=Math.max(12,Math.ceil(L/2));const out=[];for(let i=0;i<n;i++){const q=el.getPointAtLength(L*i/n);out.push([q.x,q.y])}return out},d);
 const out={source:'react-native-body-highlighter 3.2.0 (MIT, © 2022 ELABBASSI Hicham)'};
 for(const g of ['male','female']){out[g]={};let scale=null;
  for(const side of ['front','back']){const parts=[];let minx=1e9,maxx=-1e9,miny=1e9,maxy=-1e9;
   const raw=[];
   for(const part of G[g][side]){const ds=[...(part.path.common||[]),...(part.path.left||[]),...(part.path.right||[])];const polys=[];
    for(const d of ds)for(const sd of split(d)){let pts=rdp((await sample(sd)).concat([]),0.45);if(pts.length<3)continue;polys.push(pts);for(const [x,y] of pts){minx=Math.min(minx,x);maxx=Math.max(maxx,x);miny=Math.min(miny,y);maxy=Math.max(maxy,y)}}
    raw.push({slug:part.slug,polys})}
   let ol=[];const bd=border(G[g].w,side);if(bd)for(const sd of split(bd)){const pts=rdp(await sample(sd),0.45);if(pts.length>2)ol.push(pts);for(const [x,y] of pts){minx=Math.min(minx,x);maxx=Math.max(maxx,x);miny=Math.min(miny,y);maxy=Math.max(maxy,y)}}
   if(scale===null)scale=1.75/(maxy-miny);const cx=(minx+maxx)/2;
   const T=pts=>pts.map(([x,y])=>[+((x-cx)*scale).toFixed(4),+((maxy-y)*scale).toFixed(4)]);
   out[g][side]={parts:raw.map(r=>({slug:r.slug,polys:r.polys.map(T)})),outline:ol.map(T)};
   console.log(g,side,raw.length,'parts',raw.reduce((a,r)=>a+r.polys.length,0),'polys',ol.length,'outline', (maxy-miny)*scale)}
 }
 fs.writeFileSync(process.argv[2],JSON.stringify(out));await b.close()})();
