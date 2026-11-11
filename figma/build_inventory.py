from pathlib import Path
import json,base64,textwrap,html
base=Path(__file__).resolve().parent
rows=json.loads((base/'screen-inventory.json').read_text())
onboarding=[
("R01","Màn chào — theo dõi từng buổi","Giới thiệu app và bắt đầu thiết lập","Mở app ở trạng thái chưa thiết lập","R02 Bắt đầu thiết lập; đăng nhập; ngôn ngữ","Headline, nhân vật cơ, CTA thiết lập","Đặt lại minh họa, VI, đăng nhập","Onboarding state, locale, tài nguyên minh họa"),
("R02","Giới thiệu — ghi từng set","Nêu giá trị log và tiến bộ","R01 Bắt đầu thiết lập","R03 Tiếp tục; back R01","Minh họa tập, headline tiến bộ, CTA","Đồ thị squat và set minh họa","Onboarding step, media"),
("R03","Mục tiêu tập luyện","Chọn hướng tập mong muốn","R02 Tiếp tục","Tự chuyển R04 sau chọn; back","4 thẻ tăng cơ/sức mạnh/giảm mỡ/duy trì","Nhân vật đổi trạng thái, progress 3 chặng","Goal answer, media theo lựa chọn"),
("R04","Rào cản tập luyện","Hiểu lý do cản trở mục tiêu","R03 chọn Tăng sức mạnh","R05 Tiếp tục; back","6 lựa chọn rào cản và CTA","Icons và progress","Goal text, selected obstacle"),
("R05","Nhu cầu sử dụng Dopafit","Ưu tiên công việc người dùng muốn app làm","R04 Tiếp tục","R06 sau chọn tối đa 3; back","7 nhu cầu và bộ đếm 0/3","Checkbox, CTA disabled khi chưa chọn","Multi-select giới hạn 3, onboarding state"),
("R06","Nguồn biết đến Dopafit","Thu thập nguồn giới thiệu","R05 Tiếp tục","R07 sau chọn; back","8 nguồn giới thiệu","Brand icons và progress","Referral answer; chưa biết luồng attribution backend"),
("R07","Kinh nghiệm tập luyện","Chọn mức kinh nghiệm","R06 chọn nguồn","R08 sau chọn Mới bắt đầu; back","Chưa từng/Mới bắt đầu/Đã kinh nghiệm","Mô tả thời gian tập, chip mục tiêu","Goal, experience answer"),
("R08","Tình trạng tập gần đây","Phân biệt tập đều/ngắt quãng/quay lại","R07 chọn Mới bắt đầu","R09 sau chọn Lúc tập lúc nghỉ","3 lựa chọn tình trạng","Mô tả và progress","Consistency answer, onboarding branch"),
("R09","Tần suất bốn tuần qua","Xác định tần suất hiện tại","R08 chọn tình trạng","R10 chọn số rồi Tiếp tục","Số buổi/tuần, lựa chọn 0–7+","Card giá trị lớn, CTA disabled","Recent frequency answer"),
("R10","Pain point — thay đổi vóc dáng","Cho người dùng tự nhận diện khó khăn","R09 Tiếp tục","R11 trả lời; back","Nhân vật, câu hỏi vóc dáng","Hai nút Không phải tôi/Đúng vậy","Narrative step, câu trả lời yes/no, media"),
("R11","Pain point — không biết tập gì","Nhận diện nhu cầu lập kế hoạch","R10 trả lời","R12 trả lời; back","Câu hỏi vào gym không biết tập gì","Hai nút trả lời và minh họa","Narrative step, yes/no"),
("R12","Pain point — không chắc form","Nhận diện nhu cầu hướng dẫn kỹ thuật","R11 trả lời","R13 trả lời; back","Câu hỏi kỹ thuật và minh họa squat","Hai lựa chọn không phán xét","Narrative step, media"),
("R13","Câu chuyện — tập theo cảm giác","Giải thích giới hạn khi không ghi dữ liệu","R12 trả lời","R14 mũi tên lên; back","Headline và chart chưa ghi set","Gợi ý vuốt lên / nút lên","Narrative progression, media và copy"),
("R14","Câu chuyện — bỏ lỡ buổi tập","Nhấn mạnh khó khăn duy trì thói quen","R13 lên","R15 lên; back","Lỡ 3 tuần, nhân vật nghỉ trên sofa","Nút lên và back","Narrative step, dữ liệu minh họa không phải log thật"),
("R15","Câu chuyện — plateau","Giải thích nỗ lực chưa có tiến bộ","R14 lên","R16 lên; back","36 buổi, 40→40 kg trong minh họa","Headline, copy, nút lên","Media/copy; số liệu ví dụ"),
("R16","Lời hứa — một hệ thống tập","Kết nối plan, log và progress","R15 lên","R17 lên; back","Ba lợi ích và target 42.5 kg ×8","Rings, trophy/flame và CTA khám phá","Narrative step, nội dung định vị"),
("R17","Lợi ích — plan cá nhân","Minh họa buổi theo điều kiện riêng","R16 lên","R18 lên; back","Card buổi Thân trên/Sức mạnh","45 phút, 7 bài, phòng tập nhỏ","Ví dụ plan; chưa chứng minh kết quả generator"),
("R18","Lợi ích — khi nào tăng tạ","Giải thích progression qua ghi set","R17 lên","R19 lợi ích hồi phục; back R17","Log trước/target sau, headline tăng tạ","Nút lên và back","Ví dụ prescription, narrative state")
]
for data in onboarding:
    key,name,purpose,entry,exit,primary,secondary,deps=data
    matches=list((base.parent/'rebuild/audit').glob(key+'-*.png'))
    if not matches:continue
    rows.append(dict(id=key,name=name,purpose=purpose,entry=entry,exit=exit,primary=primary,secondary=secondary,dependencies=deps,note="Ảnh app gốc chụp bổ sung. Nhánh đã chọn: tăng sức mạnh / mới bắt đầu / tập ngắt quãng. Chưa xác minh cách backend dùng câu trả lời.",group="00 — Onboarding app gốc",path=str(matches[0].resolve())))
rows.sort(key=lambda s:(0 if s['id'].startswith('R') else 1,int(s['id'][1:])))
additional=base/'additional-onboarding.json'
extra=json.loads(additional.read_text()) if additional.exists() else []
postpath=base/'additional-postlogin.json'
post=json.loads(postpath.read_text()) if postpath.exists() else []
chunks=[rows[i:i+6] for i in range(0,len(rows),6)]+[extra[i:i+6] for i in range(0,len(extra),6)]+[post[i:i+6] for i in range(0,len(post),6)]
livepath=base/'additional-live-recheck.json'
live=json.loads(livepath.read_text()) if livepath.exists() else []
chunks += [live[i:i+6] for i in range(0,len(live),6)]
rows=sorted(rows+extra+post+live,key=lambda s:(0 if s['id'].startswith('R') else 1,int(s['id'][1:])))
(base/'complete-inventory.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2))
def txt(value,x,y,size=17,bold=False):
    return '<text x="'+str(x)+'" y="'+str(y)+'" fill="#202623" font-family="Inter" font-size="'+str(size)+'"'+(' font-weight="600"' if bold else '')+'>'+html.escape(value)+'</text>'
def card(s):
    raw=Path(s['path']).read_bytes()
    im=base64.b64encode(raw).decode()
    mime='image/jpeg' if raw[:2]==b'\xff\xd8' else 'image/png'
    parts=['<rect width="900" height="1100" rx="20" fill="#F5F6F4"/>',txt(s['id']+' · '+s['name'],24,42,25,True),'<image x="20" y="75" width="400" height="878" preserveAspectRatio="xMidYMid meet" href="data:'+mime+';base64,'+im+'"/>']
    y=100
    for label,key in [('MỤC ĐÍCH','purpose'),('ĐIỂM VÀO','entry'),('ĐIỂM RA / LUỒNG','exit'),('YẾU TỐ CHÍNH','primary'),('YẾU TỐ PHỤ','secondary'),('PHỤ THUỘC','dependencies'),('BẰNG CHỨNG / GIỚI HẠN','note')]:
        parts.append(txt(label,448,y,12,True));y+=24
        for line in textwrap.wrap(s[key],width=43):parts.append(txt(line,448,y));y+=24
        y+=18
    parts.append(txt('DOPAFIT GỐC · 09/11/2026 · Ảnh nguyên gốc; annotation là phân tích UI',24,1030,14))
    return ''.join(parts)
parts=[txt('DOPAFIT GỐC — MÀN HÌNH, MỤC ĐÍCH VÀ LUỒNG',40,70,44,True),txt(str(len(rows))+' ảnh trạng thái gốc · Không có ảnh rebuild · Chú thích chỉnh sửa được · Không phải source thuật toán',40,115,23),txt('Luồng tập: D01 → D17 → D18/D21 → D25–D29 → D34 → D35 → D37 → D50–D54.',40,160,21),txt('Thiết lập: D01 → D08–D12. Sau tập: D38–D42. Account: D37 → D43–D48. Onboarding: R01 → R38 (nhánh nhập tay).',40,200,21),txt('Các trạng thái/nhánh chưa quan sát không được coi là chức năng thiếu. Các số buổi tập giả và số minh họa được ghi riêng.',40,240,19)]
y=310
groups=list(dict.fromkeys(s['group'] for s in rows))
for group in groups:
    members=[s for s in rows if s['group']==group]
    parts.append(txt(group,40,y+45,36,True));y+=95
    for i,s in enumerate(members):
        x=40+(i%4)*940;cy=y+(i//4)*1140
        parts.append('<g id="'+html.escape(s['id']+' — '+s['name'],quote=True)+'" transform="translate('+str(x)+','+str(cy)+')">'+card(s)+'</g>')
    y+=((len(members)+3)//4)*1140+70
svg='<svg xmlns="http://www.w3.org/2000/svg" width="3800" height="'+str(y+40)+'" viewBox="0 0 3800 '+str(y+40)+'"><rect width="3800" height="'+str(y+40)+'" fill="#FFFFFF"/>'+''.join(parts)+'</svg>'
(base/'Dopafit-original-inventory.svg').write_text(svg)
print(json.dumps({'screens':len(rows),'width':3800,'height':y+40,'bytes':len(svg.encode())}))
batchDir=base/'batches';batchDir.mkdir(exist_ok=True)
batches=[]
for index,chunk in enumerate(chunks):
    h=260+((len(chunk)+2)//3)*1140
    blocks=[txt('DOPAFIT GỐC · '+chunk[0]['id']+' – '+chunk[-1]['id'],40,60,36,True),txt('Ảnh gốc + tên / mục đích / luồng / chính–phụ / phụ thuộc',40,100,22),txt(chunk[0]['group'],40,145,21)]
    for i,s in enumerate(chunk):
        blocks.append('<g id="'+html.escape(s['id']+' — '+s['name'],quote=True)+'" transform="translate('+str(40+(i%3)*940)+','+str(200+(i//3)*1140)+')">'+card(s)+'</g>')
    svg='<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="2860" height="'+str(h)+'"><rect width="2860" height="'+str(h)+'" fill="#FFFFFF"/>'+''.join(blocks)+'</svg>'
    svg=svg.replace(' href="data:',' xlink:href="data:')
    path=batchDir/f'{index+1:02d}.svg';path.write_text(svg)
    batches.append({'index':index+1,'path':str(path),'first':chunk[0]['id'],'last':chunk[-1]['id'],'width':2860,'height':h,'x':(index%3)*3040,'y':(index//3)*2850,'name':'Dopafit gốc '+chunk[0]['id']+'–'+chunk[-1]['id']})
(base/'batches.json').write_text(json.dumps(batches,ensure_ascii=False,indent=2))
print('Batches:',len(batches),'max bytes:',max(Path(b['path']).stat().st_size for b in batches))
