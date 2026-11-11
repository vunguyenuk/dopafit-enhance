import SwiftUI
import UniformTypeIdentifiers

// Visual tokens extracted from the user's 193 Ladder iOS Jul2024 screenshots.
// Existing Dopafit screen hierarchy/positions/actions remain the source of layout.
enum Dopa {
    static let background=Color(red:16/255,green:16/255,blue:16/255)
    static let card=Color(red:30/255,green:30/255,blue:30/255)
    static let raised=Color(red:41/255,green:41/255,blue:41/255)
    static let sheet=Color(red:20/255,green:20/255,blue:20/255)
    static let muted=Color(red:166/255,green:166/255,blue:166/255)
    static let stroke=Color(red:62/255,green:62/255,blue:62/255)
    static let lime=Color(red:0.71,green:0.96,blue:0.24)
    static let blue=Color(red:0.28,green:0.73,blue:0.94)
    static let push=Color(red:0.98,green:0.82,blue:0.13)
    static let pull=Color(red:0.86,green:0.12,blue:0.34)
    static let legs=Color(red:0.27,green:0.64,blue:0.61)
    static let radius:CGFloat=14
    static func titleFont(_ size:CGFloat)->Font {.dopa(size:size,weight:.bold)}
    static func metricFont(_ size:CGFloat)->Font {.dopa(size:size,weight:.bold).monospacedDigit()}
}
struct DopaTitleStyle:ViewModifier {
    var size:CGFloat
    func body(content:Content)->some View {content.font(Dopa.titleFont(size))}
}
extension View {
    func dopaTitle(_ size:CGFloat)->some View {modifier(DopaTitleStyle(size:size))}
    /// Tiêu đề mục trong các tab (Buổi tập, Cơ thể, Mục tiêu, Nhật ký) — một cỡ duy nhất.
    func dopaSection()->some View {font(.dopa(size:22,weight:.bold))}
}

struct PillTabs:View {
    var titles:[String]
    @Binding var selection:Int
    var bright=false
    var controlHeight:CGFloat=31
    var body:some View {
        HStack(spacing:3) {ForEach(titles.indices,id:\.self) { i in
            Button {selection=i} label:{Text(titles[i]).font(.dopa(size:13,weight:.medium)).lineLimit(1).minimumScaleFactor(0.8).frame(maxWidth:.infinity).frame(height:controlHeight).foregroundStyle(selection==i ? (bright ? Color.black:Dopa.lime):Dopa.muted).background(selection==i ? (bright ? Dopa.lime:Dopa.raised):.clear).clipShape(Capsule())}.buttonStyle(.plain).accessibilityAddTraits(selection==i ? .isSelected:[]).accessibilityRemoveTraits(selection==i ? []:.isSelected)
        }}.padding(3).background(Dopa.card).clipShape(Capsule()).overlay(Capsule().stroke(.white.opacity(0.08)))
    }
}
struct DopaButton: View {
    var title: String
    var icon: String? = nil
    var enabled = true
    var secondary = false
    var action: ()->Void
    var body: some View {
        Button(action:action) {
            HStack(spacing:8) {
                if let icon { Image(systemName:icon) }
                Text(title).font(.dopa(size:18,weight:.semibold))
            }.frame(maxWidth:.infinity).frame(height:52)
                .foregroundStyle(secondary ? Color.white : Color.black)
                .background(secondary ? Dopa.card : Dopa.lime).clipShape(Capsule()).overlay(Capsule().stroke(secondary ? Dopa.stroke:Color.clear,lineWidth:1))
                .opacity(enabled ? 1 : 0.4)
        }.buttonStyle(.plain).disabled(!enabled)
    }
}
struct CircleButton: View {
    var icon: String
    var tint: Color = .white
    var action: ()->Void
    var body: some View {
        Button(action:action) {
            Image(systemName:icon).font(.dopa(size:21,weight:.medium))
                .foregroundStyle(tint).frame(width:44,height:44)
                .background(Dopa.raised).clipShape(Circle())
                .overlay(Circle().stroke(Dopa.stroke.opacity(0.65),lineWidth:0.75))
        }.buttonStyle(.plain).accessibilityLabel(icon == "chevron.left" ? "Quay lại" : icon == "xmark" ? "Đóng" : icon)
    }
}
struct ScreenHeader: View {
    var title:String
    var back: (()->Void)? = nil
    var trailingIcon:String? = nil
    var trailing: (()->Void)? = nil
    var body: some View {
        HStack {
            if let back { CircleButton(icon:"chevron.left",action:back) }
            else { Color.clear.frame(width:44,height:44) }
            Spacer(minLength:4)
            Text(title).font(.dopa(size:18,weight:.semibold)).lineLimit(1)
            Spacer(minLength:4)
            if let trailingIcon { CircleButton(icon:trailingIcon,action:{trailing?()}) }
            else { Color.clear.frame(width:44,height:44) }
        }.padding(.horizontal,16).padding(.vertical,10)
    }
}
struct SectionLabel: View {
    var title:String
    var body: some View { Text(title.uppercased()).font(.dopa(size:12,weight:.bold)).tracking(0.65).foregroundStyle(Dopa.muted).padding(.top,22).padding(.bottom,8) }
}
struct SettingRow: View {
    var title:String
    var value:String = ""
    var icon:String? = nil
    var chevron = true
    var action:(()->Void)? = nil
    var body: some View {
        Group {
            if let action {Button(action:action){row}.buttonStyle(.plain)}
            else {row}
        }
    }
    private var row:some View {
        HStack(spacing:12) {
            if let icon {Image(systemName:icon).font(.dopa(size:20)).frame(width:32)}
            Text(title).font(.dopa(size:17,weight:.semibold)).foregroundStyle(.white)
            Spacer(minLength:4)
            if !value.isEmpty {Text(value).foregroundStyle(Dopa.muted).multilineTextAlignment(.trailing)}
            if chevron {Image(systemName:"chevron.right").font(.dopa(size:13,weight:.bold)).foregroundStyle(Dopa.muted)}
        }.font(.dopa(size:17)).padding(.horizontal,16).frame(minHeight:52).contentShape(Rectangle())
    }
}

struct GroupCard<Content:View>: View {
    @ViewBuilder var content:Content
    var body: some View { VStack(spacing:0){content}.background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:Dopa.radius)) }
}
struct InfoCard: View {
    var title:String
    var text:String
    var icon:String = "info.circle"
    var body: some View {
        HStack(alignment:.top,spacing:12) {
            Image(systemName:icon).font(.title3)
            VStack(alignment:.leading,spacing:6) {
                Text(title).font(.dopa(size:17,weight:.semibold))
                Text(text).font(.dopa(size:15)).foregroundStyle(Dopa.muted).fixedSize(horizontal:false,vertical:true)
            }
        }.padding(16).frame(maxWidth:.infinity,alignment:.leading).background(Dopa.card).clipShape(RoundedRectangle(cornerRadius:14))
    }
}
// Reference media are displayed as clipped image regions. Every interactive control is native SwiftUI.
struct ReferenceCrop: View {
    var asset:String
    var rect:[Double]
    var body: some View {
        GeometryReader { g in
            let sx = g.size.width / max(1,rect[2])
            let sy = g.size.height / max(1,rect[3])
            Image(asset).resizable()
                .frame(width:864*sx,height:1896*sy)
                .offset(x:-rect[0]*sx,y:-rect[1]*sy)
        }.clipped().accessibilityHidden(true)
    }
}
struct ExerciseThumb: View {
    var exercise:Exercise
    var size:CGFloat = 80
    var body: some View {
        if ExerciseDBMedia.hasMotionThumbnail(for:exercise) {
            ExerciseMotionThumbnail(exercise:exercise).frame(width:size,height:size).clipped().clipShape(RoundedRectangle(cornerRadius:10))
        }
    }
}
struct SheetTitle: View {
    @Environment(\.dismiss) private var dismiss
    var title:String
    var body:some View {
        HStack { Text(title).font(.dopa(size:20,weight:.bold)); Spacer(); CircleButton(icon:"xmark"){dismiss()} }.padding(16)
    }
}
struct ChoiceSheet: View {
    @Environment(\.dismiss) private var dismiss
    var title:String
    var choices:[String]
    var selected:String
    var detail:String = ""
    var onSelect:(String)->Void
    var body:some View {
        ScrollView {
            VStack(alignment:.leading,spacing:14) {
                SheetTitle(title:title)
                if !detail.isEmpty { Text(detail).foregroundStyle(Dopa.muted).padding(.horizontal,16) }
                GroupCard {
                    ForEach(choices,id:\.self) { item in
                        Button { onSelect(item); dismiss() } label: {
                            HStack { Text(item).foregroundStyle(.white); Spacer(); if selected==item { Image(systemName:"checkmark").foregroundStyle(Dopa.lime) } }
                                .font(.dopa(size:17)).padding(18).contentShape(Rectangle())
                        }.buttonStyle(.plain)
                        if item != choices.last { Divider().padding(.leading,18) }
                    }
                }.padding(.horizontal,16)
            }
        }.background(Dopa.background).presentationDragIndicator(.visible).preferredColorScheme(.dark)
    }
}
struct ArticleSheet: View {
    var title:String
    var sections:[(String,String)]
    var body:some View {
        ScrollView {
            VStack(alignment:.leading,spacing:20) {
                SheetTitle(title:title)
                ForEach(sections.indices,id:\.self) { i in
                    VStack(alignment:.leading,spacing:10) {
                        Text(sections[i].0).font(.dopa(size:21,weight:.semibold))
                        Text(sections[i].1).font(.dopa(size:17)).lineSpacing(6).foregroundStyle(Dopa.muted)
                    }.padding(.horizontal,24)
                }
            }.padding(.bottom,30)
        }.background(Dopa.background).presentationDragIndicator(.visible)
    }
}
struct CSVDocument:FileDocument {
    static var readableContentTypes:[UTType] { [.commaSeparatedText] }
    var text:String
    init(text:String) { self.text=text }
    init(configuration:ReadConfiguration) throws { text=String(data:configuration.file.regularFileContents ?? Data(),encoding:.utf8) ?? "" }
    func fileWrapper(configuration:WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents:text.data(using:.utf8) ?? Data()) }
}
extension TimeInterval {
    var clock:String {
        let value=max(0,Int(self))
        return value>=3600 ? String(format:"%d:%02d:%02d",value/3600,value/60%60,value%60) : String(format:"%02d:%02d",value/60,value%60)
    }
}

extension View {
    /// Nền sheet phủ kín từ mép trên tới đáy, không để lộ nền xám mặc định của hệ thống.
    func dopaSheet()->some View {
        self.frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.top)
            .background(Dopa.background.ignoresSafeArea())
            .presentationBackground(Dopa.background)
    }
}

/// Cỡ chữ toàn app theo cài đặt "Cỡ chữ" (người lớn tuổi, mắt kém). RootView đặt scale trước khi vẽ các tab.
enum DopaText {
    nonisolated(unsafe) static var scale:CGFloat=1
    static let options:[(String,CGFloat)]=[("Vừa",1),("Lớn",1.15),("Rất lớn",1.3)]
    static func scale(for name:String?)->CGFloat {options.first{$0.0==name}?.1 ?? 1}
}
extension Font {
    static func dopa(size:CGFloat,weight:Font.Weight = .regular,design:Font.Design = .default)->Font {
        .system(size:(size*DopaText.scale).rounded(),weight:weight,design:design)
    }
}
