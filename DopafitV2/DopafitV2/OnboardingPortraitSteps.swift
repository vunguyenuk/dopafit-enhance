import SwiftUI

struct GoalPortraitRow: View {
    var photo: String
    var title: String
    var detail: String
    var selected: Bool
    var bodyPortrait = false
    var sheetIndex: Int? = nil
    var sex: Profile.Sex = .male
    var rowHeight: CGFloat = 132
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(title).font(T.font(20, .semibold)).foregroundStyle(selected ? T.lime : T.text)
                    Text(detail).font(T.font(13)).foregroundStyle(T.sub)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 18)
                Group {
                    if let sheetIndex { SheetPortrait(asset: sex == .female ? "female-goals-actions" : "male-goals-actions", index: sheetIndex, columns: 2, rows: 2) }
                    else if bodyPortrait { AlignedBodyPortrait(photo: photo, torso: true, sex: sex) }
                    else { Image(photo).resizable().scaledToFit() }
                }.frame(width: 142, height: rowHeight, alignment: .bottom).accessibilityHidden(true)
            }
            .frame(height: rowHeight)
            .background(selected ? T.raised : T.surface, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(selected ? T.lime : .clear, lineWidth: 1.5))
            .overlay(alignment: .topTrailing) {
                if selected {
                    Image(systemName: "checkmark").font(T.font(11, .bold)).foregroundStyle(.black)
                        .frame(width: 22, height: 22).background(T.lime, in: Circle()).padding(10)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selected)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title + ", " + detail)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// Same identity, pose, wardrobe, lighting and canvas; only physique differs.
struct TransformationStep: View {
    var goal: Profile.Goal
    var current: Profile.BodyShape? = nil
    var target: Profile.BodyGoal? = nil
    var belly: Profile.BellyShape? = nil
    var sex: Profile.Sex = .male
    var body: some View {
        OnboardingPage(title: "Từng bước tới [phiên bản bạn muốn].", subtitle: "Bắt đầu hôm nay. Xây thói quen trong 4 tuần đầu, rồi tiếp tục tiến lên.") {
            TransformationPair(current: current, target: target, goal: goal, height: 340, belly: belly, sex: sex)
                .padding(.top, 18)
            Text(target?.detail ?? "Tập đều, giữ đúng nhịp và tăng tạ khi bạn đã sẵn sàng.")
                .font(T.font(16)).foregroundStyle(T.sub)
            Text("Nhân vật AI minh họa mục tiêu. Kết quả thực tế tùy mỗi người.")
                .font(T.font(12)).foregroundStyle(T.faint)
        }
    }
}

struct TransformationPair: View {
    var current: Profile.BodyShape?
    var target: Profile.BodyGoal?
    var goal: Profile.Goal
    var height: CGFloat
    var belly: Profile.BellyShape? = nil
    var sex: Profile.Sex = .male
    private var before: String { BodyIllustration.currentPhoto(shape: current, belly: belly) }
    private var after: String { BodyIllustration.targetPhoto(shape: current, target: target, goal: goal, belly: belly) }
    var body: some View {
        if !BodyIllustration.showsComparison(shape: current, target: target, goal: goal, belly: belly) {
            VStack(spacing: 0) {
                AlignedBodyPortrait(photo: before, sex: sex).frame(height: height - 52)
                Text(target == .maintain ? "Giữ vóc dáng, khỏe hơn" : "Xây tiếp nền tảng đang có")
                    .font(T.font(18, .semibold)).foregroundStyle(T.bg)
                    .frame(maxWidth: .infinity, minHeight: 52).background(T.lime)
            }.frame(height: height).background(T.surface)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(T.lime, lineWidth: 1))
        } else {
        GeometryReader { g in
            let width = max(1, (g.size.width - 12) / 2)
            ZStack {
                HStack(spacing: 12) {
                    portrait(before, title: "Hôm nay", accented: false, width: width)
                    portrait(after, title: "Mục tiêu", accented: true, width: width)
                }
                Image(systemName: "arrow.right")
                    .font(T.font(22, .semibold)).foregroundStyle(T.lime)
                    .frame(width: 44, height: 44).background(T.bg, in: Circle())
                    .overlay(Circle().stroke(T.lime.opacity(0.3)))
                    .accessibilityHidden(true)
            }
        }.frame(height: height)
        }
    }
    private func portrait(_ photo: String, title: String, accented: Bool, width: CGFloat) -> some View {
        VStack(spacing: 0) {
            AlignedBodyPortrait(photo: photo, sex: sex)
                .frame(width: width, height: height - 52, alignment: .bottom).accessibilityHidden(true)
            Text(title).font(T.font(18, .semibold)).foregroundStyle(accented ? T.bg : T.text)
                .frame(width: width, height: 52).background(accented ? T.lime : T.raised)
        }.frame(width: width, height: height).background(T.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(accented ? T.lime : T.line, lineWidth: 1))
    }
}

struct ActivityLevelStep: View {
    @Binding var selection: Profile.Activity?
    var sex: Profile.Sex = .male
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var activity: Profile.Activity { selection ?? .light }
    private var position: Int { Profile.Activity.allCases.firstIndex(of: activity) ?? 1 }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Mức độ vận động\ncủa bạn?")
                        .font(T.font(32, .bold)).foregroundStyle(T.text).lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 22)
                    ZStack(alignment: .bottom) {
                        Ellipse().fill(T.surface).frame(width: 238, height: 48).offset(y: 6)
                        SheetPortrait(asset: sex == .female ? "female-activity-sheet" : "onboarding-activity-sheet", index: position, columns: 2, rows: 2)
                            .frame(maxWidth: 280).frame(height: min(280, geometry.size.height * 0.39), alignment: .bottom)
                            .id(activity).transition(.opacity).accessibilityHidden(true)
                    }
                    .frame(maxWidth: .infinity).padding(.top, 40).padding(.bottom, 27)
                    Text(activity.detail).font(T.font(17)).foregroundStyle(T.text)
                        .multilineTextAlignment(.center).lineSpacing(4)
                        .frame(maxWidth: .infinity, minHeight: 74)
                        .padding(.horizontal, 10)
                        .accessibilityIdentifier("onboarding.activity.description")
                    slider.padding(.top, 30)
                    HStack {
                        Text("Ít vận động")
                        Spacer()
                        Text("Rất tích cực")
                    }.font(T.font(14, .medium)).foregroundStyle(T.sub).padding(.top, 9)
                    Text(activity.name).font(T.font(14, .semibold)).foregroundStyle(T.lime)
                        .frame(maxWidth: .infinity).padding(.top, 24)
                }
                .padding(.horizontal, 24).padding(.bottom, 24)
            }.scrollIndicators(.hidden)
        }
        .onAppear { if selection == nil { selection = .light } }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: activity)
        .sensoryFeedback(.selection, trigger: activity)
        .onAppear { if selection == nil { selection = .light } }
    }

    private var slider: some View {
        GeometryReader { geometry in
            let margin: CGFloat = 18
            let usable = geometry.size.width - margin * 2
            let step = usable / 3
            ZStack(alignment: .leading) {
                Capsule().fill(T.raised).frame(height: 18)
                Capsule().fill(T.lime.opacity(0.2)).frame(width: margin + CGFloat(position) * step, height: 18)
                ForEach(0..<4) { index in
                    Circle().fill(index <= position ? T.lime : T.faint).frame(width: 5, height: 5)
                        .position(x: margin + CGFloat(index) * step, y: 24)
                }
                Circle().fill(T.lime).frame(width: 30, height: 30)
                    .overlay(Circle().stroke(T.text, lineWidth: 3))
                    .shadow(color: .black.opacity(0.35), radius: 6, y: 3)
                    .position(x: margin + CGFloat(position) * step, y: 24)
            }
            .frame(height: 48)
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                let index = min(3, max(0, Int(((value.location.x - margin) / step).rounded())))
                selection = Profile.Activity.allCases[index]
            })
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Mức độ vận động")
            .accessibilityValue("\(position + 1) trong 4, \(activity.name)")
            .accessibilityIdentifier("onboarding.activity.slider")
            .accessibilityAdjustableAction { direction in
                let increment = direction == .increment ? 1 : -1
                selection = Profile.Activity.allCases[min(3, max(0, position + increment))]
            }
        }.frame(height: 48)
    }
}

/// One explicit choice, followed by the existing fixed safe-area Next control.
struct TrainingBreakStep: View {
    @Binding var selection: Profile.TrainingBreak?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Bạn đã nghỉ tập\nbao lâu?")
                    .font(T.font(32, .bold)).foregroundStyle(T.text).lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 22)
                Text("Chọn khoảng thời gian gần đúng.")
                    .font(T.font(16)).foregroundStyle(T.sub)
                    .padding(.top, 14).padding(.bottom, 36)
                VStack(spacing: 12) {
                    ForEach(Profile.TrainingBreak.allCases, id: \.self) { value in
                        let selected = selection == value
                        Button { selection = value } label: {
                            HStack(spacing: 16) {
                                Text(value.name).font(T.font(20, .semibold))
                                    .foregroundStyle(selected ? T.lime : T.text)
                                Spacer(minLength: 10)
                                ZStack {
                                    Circle().stroke(selected ? T.lime : T.faint, lineWidth: 1.5)
                                    if selected {
                                        Circle().fill(T.lime)
                                        Image(systemName: "checkmark").font(T.font(11, .bold)).foregroundStyle(T.bg)
                                    }
                                }.frame(width: 23, height: 23)
                            }
                            .padding(.horizontal, 20).frame(maxWidth: .infinity, minHeight: 86)
                            .background(selected ? T.raised : T.surface, in: RoundedRectangle(cornerRadius: 20))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(selected ? T.lime : T.line, lineWidth: selected ? 1.5 : 1))
                            .contentShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(value.name)
                        .accessibilityAddTraits(selected ? .isSelected : [])
                        .accessibilityIdentifier("onboarding.training-break.\(value.rawValue)")
                    }
                }
            }
            .padding(.horizontal, 24).padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .sensoryFeedback(.selection, trigger: selection)
    }
}
