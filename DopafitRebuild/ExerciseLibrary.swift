import SwiftUI

// Màn chọn bài kiểu mới (10/11/2026, theo yêu cầu trực tiếp của người dùng — KHÔNG phải bản sao màn gốc):
// ô tìm ở trên cùng, hàng nhóm cơ bằng icon, nút lọc cộng dồn (hôm nay / dụng cụ / độ khó / loại dụng cụ).
// Icon nhóm cơ là hình cơ thể phẳng tô lime, thay cho ảnh giải phẫu 3D để khác Fitbod.

// Hình cơ thể phẳng: bóng người xám đậm, mỗi nhóm cơ là một mảng màu phẳng. Hình tự vẽ cho Dopafit.
// Toạ độ 200 x 400; dữ liệu chỉ mô tả nửa phải, nửa trái lấy đối xứng qua x=100.
enum SVGPath {
    static func parse(_ data:String)->Path {
        var path=Path()
        var command:Character="M"
        var nums:[CGFloat]=[]
        func flush() {
            switch command {
            case "M": if nums.count>=2 {path.move(to:CGPoint(x:nums[0],y:nums[1]))}
            case "L": if nums.count>=2 {path.addLine(to:CGPoint(x:nums[0],y:nums[1]))}
            case "C": if nums.count>=6 {path.addCurve(to:CGPoint(x:nums[4],y:nums[5]),control1:CGPoint(x:nums[0],y:nums[1]),control2:CGPoint(x:nums[2],y:nums[3]))}
            case "Z": path.closeSubpath()
            default: break
            }
            nums=[]
        }
        var started=false
        for token in data.split(separator:" ") {
            var text=String(token)
            if let first=text.first, first.isLetter {
                if started {flush()}
                started=true
                command=first
                text.removeFirst()
            }
            if let value=Double(text) {nums.append(CGFloat(value))}
        }
        if started {flush()}
        return path
    }
    static func mirrored(_ path:Path)->Path {
        var both=path
        both.addPath(path.applying(CGAffineTransform(a:-1,b:0,c:0,d:1,tx:200,ty:0)))
        return both
    }
}

struct MuscleSpec {
    var back:Bool
    var parts:[String]
    var box:CGRect
}

enum MuscleFigure {
    static let whole=CGRect(x:-100,y:0,width:400,height:400)
    static let headData="M100 8 C112 8 118 18 118 30 C118 44 110 54 100 54 C90 54 82 44 82 30 C82 18 88 8 100 8 Z"
    static let baseData:[(String,String)]=[
        ("torso","M100 56 L113 56 C122 64 134 67 145 72 L141 104 C139 125 132 145 129 162 C129 175 132 185 135 194 L100 210 Z"),
        ("arm","M137 72 C150 68 161 78 162 93 C164 110 166 126 169 142 C173 160 178 180 182 198 C185 206 187 217 184 225 C181 230 175 227 173 219 C171 211 170 205 168 199 C162 182 156 164 152 146 C148 132 143 118 138 106 Z"),
        ("leg","M135 188 C140 215 140 250 133 290 C136 310 135 332 127 372 L131 389 C125 395 112 395 108 389 L111 372 C106 340 105 315 108 292 C104 262 101 235 100 208 L100 198 Z")
    ]
    static let frontData:[(String,String)]=[
        ("neck","M101 57 L111 58 C113 62 117 66 122 68 C114 70 107 70 101 69 Z"),
        ("trap","M114 59 C122 65 131 68 139 71 L127 72 C121 70 117 66 114 59 Z"),
        ("chest","M102 76 C112 71 127 72 137 80 C140 90 138 102 131 108 C121 114 109 113 102 107 Z"),
        ("delt","M140 74 C151 71 160 80 161 94 C161 102 158 108 154 113 C150 102 146 92 141 85 Z"),
        ("abs","M102 114 L116 113 C118 118 118 123 116 127 L102 128 Z M102 131 L116 130 C118 135 118 140 116 144 L102 145 Z M102 148 L116 147 C117 152 117 157 115 161 L102 162 Z M102 165 L115 164 C116 176 110 194 102 204 Z"),
        ("side","M121 113 C127 113 132 111 135 108 C134 128 131 148 129 162 C129 172 131 180 132 187 C126 185 121 180 120 172 Z"),
        ("biceps","M146 108 C152 103 158 106 161 114 C163 124 165 132 165 140 C160 144 155 143 152 139 C150 128 148 118 146 108 Z"),
        ("forearm","M154 148 C160 145 166 146 170 150 C174 166 178 182 180 196 L170 198 C164 182 158 166 154 148 Z"),
        ("quad","M105 214 C114 207 126 200 134 196 C139 220 138 252 132 281 C125 288 115 288 109 281 C105 258 103 236 105 214 Z"),
        ("shin","M110 298 C116 294 126 294 131 298 C133 318 131 340 126 364 L113 364 C108 340 107 318 110 298 Z")
    ]
    static let backData:[(String,String)]=[
        ("trap","M101 57 L113 59 C122 66 131 69 139 72 C129 77 119 86 112 100 L101 124 Z"),
        ("delt","M140 74 C151 71 160 80 161 94 C161 102 158 108 154 113 C150 102 146 92 141 85 Z"),
        ("lat","M114 103 C121 94 130 90 138 88 C140 110 135 136 129 158 C121 160 110 157 103 150 L103 128 Z"),
        ("lowback","M102 155 C110 162 120 164 128 163 C129 173 131 182 133 189 L102 197 Z"),
        ("triceps","M146 108 C152 103 158 106 161 114 C163 124 165 132 165 140 C160 144 155 143 152 139 C150 128 148 118 146 108 Z"),
        ("forearm","M154 148 C160 145 166 146 170 150 C174 166 178 182 180 196 L170 198 C164 182 158 166 154 148 Z"),
        ("glute","M102 201 C112 197 124 195 135 192 C139 206 138 222 133 232 C123 239 111 237 102 230 Z"),
        ("ham","M104 239 C112 243 124 243 134 238 C137 256 135 272 132 283 C125 288 115 288 109 283 C105 268 104 254 104 239 Z"),
        ("calf","M109 296 C116 290 127 290 132 296 C135 314 133 334 127 356 L113 356 C107 334 106 314 109 296 Z")
    ]
    static let silhouette:Path={
        var p=SVGPath.parse(headData)
        for item in baseData {p.addPath(SVGPath.mirrored(SVGPath.parse(item.1)))}
        return p
    }()
    static let front:[(String,Path)]=frontData.map{($0.0,SVGPath.mirrored(SVGPath.parse($0.1)))}
    static let back:[(String,Path)]=backData.map{($0.0,SVGPath.mirrored(SVGPath.parse($0.1)))}
    static func spec(_ muscle:String)->MuscleSpec {
        switch muscle {
        case "Ngực": return MuscleSpec(back:false,parts:["chest"],box:CGRect(x:30,y:40,width:140,height:140))
        case "Vai": return MuscleSpec(back:false,parts:["delt"],box:CGRect(x:30,y:40,width:140,height:140))
        case "Bụng": return MuscleSpec(back:false,parts:["abs"],box:CGRect(x:30,y:75,width:140,height:140))
        case "Cổ": return MuscleSpec(back:false,parts:["neck","trap"],box:CGRect(x:50,y:5,width:100,height:100))
        case "Tay trước": return MuscleSpec(back:false,parts:["biceps"],box:CGRect(x:30,y:60,width:140,height:140))
        case "Cẳng tay": return MuscleSpec(back:false,parts:["forearm"],box:CGRect(x:30,y:100,width:140,height:140))
        case "Đùi trước": return MuscleSpec(back:false,parts:["quad"],box:CGRect(x:15,y:150,width:170,height:170))
        case "Cơ khép hông": return MuscleSpec(back:false,parts:["quad"],box:CGRect(x:15,y:150,width:170,height:170))
        case "Cơ dạng hông": return MuscleSpec(back:true,parts:["glute"],box:CGRect(x:15,y:150,width:170,height:170))
        case "Lưng": return MuscleSpec(back:true,parts:["lat"],box:CGRect(x:30,y:45,width:140,height:140))
        case "Cơ thang": return MuscleSpec(back:true,parts:["trap"],box:CGRect(x:30,y:30,width:140,height:140))
        case "Lưng dưới": return MuscleSpec(back:true,parts:["lowback"],box:CGRect(x:30,y:80,width:140,height:140))
        case "Tay sau": return MuscleSpec(back:true,parts:["triceps"],box:CGRect(x:30,y:60,width:140,height:140))
        case "Mông": return MuscleSpec(back:true,parts:["glute"],box:CGRect(x:15,y:150,width:170,height:170))
        case "Đùi sau": return MuscleSpec(back:true,parts:["ham"],box:CGRect(x:15,y:150,width:170,height:170))
        case "Bắp chân": return MuscleSpec(back:true,parts:["calf"],box:CGRect(x:15,y:225,width:170,height:170))
        default: return MuscleSpec(back:false,parts:[],box:whole)
        }
    }
}

// muscle: nhóm cơ chính (tô lime). secondary: nhóm cơ phụ cùng mặt trước/sau (tô lime nhạt). full: vẽ cả người.
struct MuscleGlyph:View {
    var muscle:String
    var full=false
    var secondary:[String]=[]
    var body:some View {
        Canvas { ctx,size in
            let spec=MuscleFigure.spec(muscle)
            var soft=Set<String>()
            for name in secondary {
                let other=MuscleFigure.spec(name)
                if other.back==spec.back {soft.formUnion(other.parts)}
            }
            let box=full ? MuscleFigure.whole:spec.box
            let s=min(size.width/box.width,size.height/box.height)
            let dx=(size.width-box.width*s)/2-box.minX*s
            let dy=(size.height-box.height*s)/2-box.minY*s
            let t=CGAffineTransform(a:s,b:0,c:0,d:s,tx:dx,ty:dy)
            ctx.fill(MuscleFigure.silhouette.applying(t),with:.color(Color(white:0.17)))
            for item in (spec.back ? MuscleFigure.back:MuscleFigure.front) {
                let color:Color=spec.parts.contains(item.0) ? Dopa.lime:(soft.contains(item.0) ? Dopa.lime.opacity(0.38):Color(white:0.24))
                ctx.fill(item.1.applying(t),with:.color(color))
            }
        }.accessibilityHidden(true)
    }
}

struct GearGlyph:View {
    var gear:String
    var color:Color = .white
    var body:some View {
        Canvas { ctx,size in
            let s=min(size.width,size.height)/24
            func pt(_ x:CGFloat,_ y:CGFloat)->CGPoint {CGPoint(x:x,y:y)}
            func box(_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ h:CGFloat)->CGRect {CGRect(x:x,y:y,width:w,height:h)}
            let round=CGSize(width:1.2,height:1.2)
            var p=Path()
            var pre=CGAffineTransform.identity
            switch gear {
            case "Tạ đòn":
                p.move(to:pt(3,12));p.addLine(to:pt(21,12))
                p.addRoundedRect(in:box(5,7,2.6,10),cornerSize:round)
                p.addRoundedRect(in:box(16.4,7,2.6,10),cornerSize:round)
            case "Tạ đơn":
                p.move(to:pt(8,12));p.addLine(to:pt(16,12))
                p.addRoundedRect(in:box(4.2,8,3.8,8),cornerSize:round)
                p.addRoundedRect(in:box(16,8,3.8,8),cornerSize:round)
                pre=CGAffineTransform(translationX:12,y:12).rotated(by:-0.6).translatedBy(x:-12,y:-12)
            case "Máy":
                p.move(to:pt(5,20));p.addLine(to:pt(5,4));p.addLine(to:pt(19,4));p.addLine(to:pt(19,20))
                p.move(to:pt(3.5,20));p.addLine(to:pt(20.5,20))
                p.addRoundedRect(in:box(9,7.5,6,2.6),cornerSize:round)
                p.addRoundedRect(in:box(9,11,6,2.6),cornerSize:round)
                p.addRoundedRect(in:box(9,14.5,6,2.6),cornerSize:round)
            case "Cáp":
                p.move(to:pt(4,20));p.addLine(to:pt(8,20))
                p.move(to:pt(6,20));p.addLine(to:pt(6,4));p.addLine(to:pt(13.6,4))
                p.addEllipse(in:box(13.6,3.6,4.8,4.8))
                p.move(to:pt(16,8.4));p.addLine(to:pt(16,15))
                p.move(to:pt(12.5,15));p.addLine(to:pt(19.5,15));p.addLine(to:pt(18.3,18.6));p.addLine(to:pt(13.7,18.6));p.closeSubpath()
            case "Dây":
                p.addEllipse(in:box(3,6.5,18,11))
                p.addEllipse(in:box(7.5,9.8,9,4.4))
            default:
                p.addEllipse(in:box(9.7,2.7,4.6,4.6))
                p.move(to:pt(5,10));p.addLine(to:pt(12,9));p.addLine(to:pt(19,10))
                p.move(to:pt(12,9));p.addLine(to:pt(12,15));p.addLine(to:pt(8.5,21))
                p.move(to:pt(12,15));p.addLine(to:pt(15.5,21))
            }
            let scaled=p.applying(pre).applying(CGAffineTransform(scaleX:s,y:s))
            ctx.stroke(scaled,with:.color(color),style:StrokeStyle(lineWidth:1.7*s,lineCap:.round,lineJoin:.round))
        }.accessibilityHidden(true)
    }
}

struct LevelDots:View {
    var level:Int
    var body:some View {
        HStack(spacing:2.5) {
            ForEach(1...3,id:\.self) { i in
                Circle().fill(i<=level ? Dopa.lime:Color(white:0.28)).frame(width:5,height:5)
            }
        }.accessibilityLabel("Độ khó: "+ExerciseMeta.levelName(level))
    }
}

struct ExercisePicker:View {
    @EnvironmentObject var store:AppStore
    @Environment(\.dismiss) var dismiss
    var title:String
    var replacement=false
    var replacing:Exercise?=nil
    var multiple=false
    var initialMuscle:String?=nil
    var onChoose:(Exercise)->Void
    @State private var query=""
    @State private var muscle:String?=nil
    @State private var levels:Set<Int>=[]
    @State private var gears:Set<String>=[]
    @State private var today=false
    @State private var owned=false
    @State private var picked:[String]=[]
    @State private var preview:Exercise?=nil
    @State private var showFilters=false
    @State private var initialized=false

    var trimmed:String {query.trimmingCharacters(in:.whitespaces)}
    var active:Bool {!trimmed.isEmpty || muscle != nil || !levels.isEmpty || !gears.isEmpty || today || owned}
    var todayMuscles:Set<String> {Set((store.data.draft?.exercises ?? []).flatMap{$0.exercise.muscles})}
    var availableGears:[String] {
        let used=Set(Catalog.all.map{ExerciseMeta.gearGroup($0.equipment)})
        return ExerciseMeta.gearGroups.filter{used.contains($0)}
    }
    func done(_ ex:Exercise)->Int {store.exerciseHistory(ex.id).reduce(0){$0+$1.1.doneCount}}
    var results:[Exercise] {
        let filter=ExerciseLibraryFilter(query:trimmed,muscle:muscle,levels:levels,gears:gears,todayMuscles:today ? todayMuscles:nil,ownedGear:owned ? Set(store.currentGym.equipment):nil)
        return store.exercises(replacing:replacing).filter { ex in
            !(replacement && ex.id==replacing?.id) && filter.matches(ex)
        }
    }

    var sections:[PickerSection] {
        let list=results
        if muscle != nil {return list.isEmpty ? []:[PickerSection(title:"",rows:list)]}
        var out:[PickerSection]=[]
        var used=Set<String>()
        if !active {
            let lastDates=Dictionary(grouping:store.data.history.flatMap{s in s.completedExercises.map{($0.exercise.id,s.started)}},by:{$0.0}).mapValues{$0.map{$0.1}.max()!}
            let recent=list.filter{done($0)>0}.sorted{(lastDates[$0.id] ?? .distantPast) > (lastDates[$1.id] ?? .distantPast)}
            if !recent.isEmpty {
                out.append(PickerSection(title:"Tập gần đây",rows:recent))
                used=Set(recent.map{$0.id})
            }
        }
        for name in Catalog.muscleNames {
            let rows=list.filter{$0.muscles.first==name && !used.contains($0.id)}
            if !rows.isEmpty {out.append(PickerSection(title:name,rows:rows))}
        }
        let rest=list.filter{!used.contains($0.id) && !Catalog.muscleNames.contains($0.muscles.first ?? "")}
        if !rest.isEmpty {out.append(PickerSection(title:"Khác",rows:rest))}
        return out
    }
    func clear() {query="";muscle=nil;levels=[];gears=[];today=false;owned=false}
    func choose(_ ex:Exercise) {
        if multiple {
            if let i=picked.firstIndex(of:ex.id) {picked.remove(at:i)} else {picked.append(ex.id)}
        } else {
            onChoose(ex)
            if !replacement {dismiss()}
        }
    }
    func commit() {
        for id in picked {
            if let ex=Catalog.all.first(where:{$0.id==id}) {onChoose(ex)}
        }
        dismiss()
    }

    var body:some View {
        let secs=sections
        let total=secs.reduce(0){$0+$1.rows.count}
        return VStack(spacing:0) {
            SheetTitle(title:title)
            searchField
            muscleStrip
            chipRow
            HStack {
                Text("\(total) bài"+(muscle.map{" · "+$0} ?? "")).font(.dopa(size:13)).foregroundStyle(Dopa.muted)
                Spacer()
                if active {Button("Xóa lọc"){clear()}.font(.dopa(size:13,weight:.medium)).foregroundStyle(Dopa.lime)}
            }.padding(.horizontal,18).padding(.top,4).padding(.bottom,6)
            ScrollView {
                LazyVStack(alignment:.leading,spacing:0) {
                    ForEach(secs) { sec in
                        if !sec.title.isEmpty {
                            Text(sec.title.uppercased()).font(.dopa(size:12,weight:.bold)).tracking(0.7).foregroundStyle(Dopa.muted).padding(.top,24).padding(.bottom,8)
                        }
                        ForEach(sec.rows) { ex in row(ex).id(ex.id+(picked.contains(ex.id) ? "-selected":"-idle")) }
                    }
                    if total==0 {
                        Text("Không có bài nào khớp.\nThử bỏ bớt một nút lọc.").multilineTextAlignment(.center).foregroundStyle(Dopa.muted).frame(maxWidth:.infinity).padding(40)
                    }
                }.padding(.horizontal,20).padding(.bottom,16)
            }.scrollDismissesKeyboard(.immediately)
            if multiple {
                DopaButton(title:picked.isEmpty ? "Chọn bài để thêm":"Thêm \(picked.count) bài",enabled:!picked.isEmpty){commit()}.padding(.horizontal,16).padding(.top,8).padding(.bottom,10)
            }
        }.background(Dopa.background).presentationDragIndicator(.visible)
        .onAppear{if !initialized{muscle=initialMuscle;initialized=true}}
        .sheet(item:$preview){ex in ExerciseGuide(exercise:ex,modal:true).environmentObject(store)}
        .sheet(isPresented:$showFilters){filtersPanel}
    }
    var searchField:some View {
        HStack(spacing:8) {
            Image(systemName:"magnifyingglass").foregroundStyle(Dopa.muted)
            TextField("Tìm bài tập, ví dụ: squat",text:$query).autocorrectionDisabled().textInputAutocapitalization(.never).submitLabel(.search)
            if !query.isEmpty {
                Button {query=""} label:{Image(systemName:"xmark.circle.fill").foregroundStyle(Dopa.muted)}.accessibilityLabel("Xóa chữ tìm")
            }
        }.padding(.horizontal,14).frame(height:46).background(Dopa.card).clipShape(Capsule()).overlay(Capsule().stroke(.white.opacity(0.16))).padding(.horizontal,16)
    }
    var muscleStrip:some View {
        ScrollView(.horizontal,showsIndicators:false) {
            HStack(spacing:12) {
                ForEach(Catalog.muscleNames,id:\.self) { name in
                    muscleTile(name)
                }
            }.padding(.horizontal,16)
        }.padding(.top,16)
    }
    func muscleTile(_ name:String)->some View {
        let on=muscle==name
        return Button {muscle=on ? nil:name} label: {
            VStack(spacing:5) {
                MuscleGlyph(muscle:name).padding(3).frame(width:56,height:56).background(on ? Dopa.lime.opacity(0.16):Dopa.card).clipShape(RoundedRectangle(cornerRadius:10)).overlay(RoundedRectangle(cornerRadius:10).stroke(on ? Dopa.lime:Color.clear,lineWidth:1.5))
                Text(name).font(.dopa(size:12,weight:on ? .semibold:.regular)).foregroundStyle(on ? Color.white:Dopa.muted).lineLimit(1)
            }.frame(width:64)
        }.buttonStyle(.plain).accessibilityLabel(name).accessibilityAddTraits(on ? .isSelected:[]).accessibilityRemoveTraits(on ? []:.isSelected)
    }
    func chip(_ label:String,on:Bool,gear:String?=nil,action:@escaping ()->Void)->some View {
        Button(action:action) {
            HStack(spacing:6) {
                if let gear {GearGlyph(gear:gear,color:on ? .black:.white).frame(width:16,height:16)}
                Text(label).font(.dopa(size:13,weight:on ? .semibold:.regular))
            }.foregroundStyle(on ? Color.black:Color.white).padding(.horizontal,13).frame(height:34).background(on ? Dopa.lime:Dopa.card).clipShape(Capsule()).overlay(Capsule().stroke(.white.opacity(on ? 0:0.14)))
        }.buttonStyle(.plain).accessibilityAddTraits(on ? .isSelected:[]).accessibilityRemoveTraits(on ? []:.isSelected)
    }
    var chipRow:some View {
        HStack(spacing:8) {
            if !todayMuscles.isEmpty {chip("Hợp hôm nay",on:today){today.toggle()}}
            chip("Dụng cụ tôi có",on:owned){owned.toggle()}
            Spacer(minLength:0)
            Button{showFilters=true}label:{
                HStack(spacing:5){Image(systemName:"slider.horizontal.3");Text("Lọc");if !levels.isEmpty || !gears.isEmpty {Text("\(levels.count+gears.count)").font(.dopa(size:11,weight:.bold)).foregroundStyle(.black).frame(width:18,height:18).background(Dopa.lime).clipShape(Circle())}}
                    .font(.dopa(size:13,weight:.semibold)).foregroundStyle(.white).frame(minHeight:36)
            }.accessibilityLabel("Bộ lọc độ khó và dụng cụ")
        }.padding(.horizontal,20).padding(.top,16).padding(.bottom,12)
    }
    var filtersPanel:some View {
        VStack(alignment:.leading,spacing:24){
            HStack{Text("Bộ lọc").font(.dopa(size:20,weight:.bold));Spacer();Button("Đặt lại"){levels=[];gears=[]}.foregroundStyle(Dopa.lime)}
            VStack(alignment:.leading,spacing:12){
                Text("ĐỘ KHÓ").font(.dopa(size:12,weight:.bold)).tracking(0.7).foregroundStyle(Dopa.muted)
                HStack(spacing:10){ForEach(1...3,id:\.self){level in chip(ExerciseMeta.levelName(level),on:levels.contains(level)){if levels.contains(level){levels.remove(level)}else{levels.insert(level)}}}}
            }
            VStack(alignment:.leading,spacing:12){
                Text("DỤNG CỤ").font(.dopa(size:12,weight:.bold)).tracking(0.7).foregroundStyle(Dopa.muted)
                LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())],alignment:.leading,spacing:12){ForEach(availableGears,id:\.self){gear in chip(gear,on:gears.contains(gear),gear:gear){if gears.contains(gear){gears.remove(gear)}else{gears.insert(gear)}}}}
            }
            Spacer(minLength:0)
            DopaButton(title:"Xem \(results.count) bài"){showFilters=false}
        }.padding(24).padding(.top,8).dopaSheet().presentationDetents([.height(400)]).presentationDragIndicator(.visible)
    }
    func row(_ ex:Exercise)->some View {
        let on=picked.contains(ex.id)
        let main=ex.muscles.first ?? ""
        return HStack(spacing:16) {
            if ExerciseDBMedia.hasMotionThumbnail(for:ex) {Button {preview=ex} label:{
                ExerciseMotionThumbnail(exercise:ex).frame(width:64,height:64).clipShape(RoundedRectangle(cornerRadius:10))
                    .overlay(alignment:.bottomTrailing){Image(systemName:"play.fill").font(.dopa(size:8,weight:.bold)).foregroundStyle(.white).frame(width:18,height:18).background(.black.opacity(0.75)).clipShape(Circle()).padding(3)}
            }.buttonStyle(.plain).accessibilityLabel("Xem động tác: "+ex.name)}
            Button {choose(ex)} label: {
                HStack(spacing:14){
                    VStack(alignment:.leading,spacing:7) {
                        Text(store.english ? ex.english:ex.name).font(.dopa(size:17,weight:.medium)).lineSpacing(2).foregroundStyle(.white).multilineTextAlignment(.leading).fixedSize(horizontal:false,vertical:true)
                        HStack(spacing:8) {
                            Text(main+" · "+ex.equipment).font(.dopa(size:13)).foregroundStyle(Dopa.muted).fixedSize(horizontal:false,vertical:true)
                            LevelDots(level:ExerciseMeta.level(ex))
                        }
                    }.frame(maxWidth:.infinity,alignment:.leading)
                    if multiple {
                        ZStack{
                            Circle().fill(on ? Dopa.lime:Color.clear)
                            Circle().stroke(on ? Color.clear:Dopa.muted.opacity(0.65),lineWidth:1.25)
                            if on{Image(systemName:"checkmark").font(.dopa(size:11,weight:.semibold)).foregroundStyle(.black)}
                        }.frame(width:22,height:22).frame(width:32,height:44)
                    }
                }.contentShape(Rectangle())
            }.buttonStyle(.plain).accessibilityAddTraits(on ? .isSelected:[]).accessibilityRemoveTraits(on ? []:.isSelected)
                .accessibilityLabel((multiple ? "Chọn: ":"Đổi sang: ")+ex.name).accessibilityValue(on ? "Đã chọn":"Chưa chọn")
            if !ExerciseDBMedia.hasMotionThumbnail(for:ex) {
                Button{preview=ex}label:{Image(systemName:"info.circle").font(.dopa(size:18)).foregroundStyle(Dopa.muted).frame(width:44,height:44)}
                    .buttonStyle(.plain).accessibilityLabel("Xem hướng dẫn: "+ex.name)
            }
        }.padding(.vertical,17)
            .overlay(alignment:.bottom){Rectangle().fill(Dopa.stroke.opacity(0.45)).frame(height:0.5).padding(.leading,ExerciseDBMedia.hasMotionThumbnail(for:ex) ? 80:0)}
    }

}

struct PickerSection:Identifiable {
    var title:String
    var rows:[Exercise]
    var id:String {title}
}
