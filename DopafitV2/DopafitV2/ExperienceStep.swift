import SwiftUI

/// Experience is a history answer, not an ability inferred from a photograph.
struct ExperienceStep: View {
    @Binding var selection: Profile.Level
    private let spans = ["<6", "6–24", "24+"]
    var body: some View {
        OnboardingPage(title: "Bạn đã tập tạ [bao lâu]?", subtitle: "Tính khoảng thời gian bạn đã tập. Không cần nâng nặng hay biết hết các bài.") {
            VStack(spacing: 14) {
                ForEach(Array(Profile.Level.allCases.enumerated()), id: \.element) { index, level in
                    let on = selection == level
                    Button { selection = level } label: {
                        HStack(spacing: 18) {
                            ExperienceCalendarIcon(value: spans[index], selected: on)
                            VStack(alignment: .leading, spacing: 7) {
                                Text(level.name).font(T.font(20, .semibold)).foregroundStyle(on ? T.lime : T.text)
                                Text(level.detail).font(T.font(14)).foregroundStyle(T.sub).fixedSize(horizontal: false, vertical: true)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                            ChoiceRadio(selected: on)
                        }.padding(18).frame(maxWidth: .infinity, minHeight: 128)
                            .background(on ? T.raised : T.surface, in: RoundedRectangle(cornerRadius: 22))
                            .overlay(RoundedRectangle(cornerRadius: 22).stroke(on ? T.lime : T.line, lineWidth: 1))
                    }.buttonStyle(.plain).accessibilityElement(children: .combine)
                        .accessibilityAddTraits(on ? .isSelected : [])
                        .accessibilityIdentifier("onboarding.level.\(level.rawValue)")
                }
            }
            Label("Mức tạ khởi điểm luôn chỉnh được ở từng set.", systemImage: "slider.horizontal.3")
                .font(T.font(14)).foregroundStyle(T.sub).padding(.top, 8)
        }.sensoryFeedback(.selection, trigger: selection)
    }
}

struct SexSetupStep: View {
    @Binding var selection: Profile.Sex
    var body: some View {
        OnboardingPage(title: "Bạn là [nam hay nữ]?", subtitle: "Để chọn hình minh họa và mức tạ gợi ý ban đầu. Plan còn dựa vào mục tiêu, kinh nghiệm và điều kiện tập của bạn.") {
            HStack(spacing: 14) {
                option(.male, title: "Nam")
                option(.female, title: "Nữ")
            }.padding(.top, 28)
            Text("Bạn có thể đổi lựa chọn trong Cài đặt.").font(T.font(14)).foregroundStyle(T.sub)
        }
    }
    private func option(_ sex: Profile.Sex, title: String) -> some View {
        let on = selection == sex
        return Button { selection = sex } label: {
            VStack(spacing: 0) {
                AlignedBodyPortrait(photo: "comparison-average", sex: sex).frame(height: 260)
                HStack { Text(title).font(T.font(22, .semibold)); Spacer(); ChoiceRadio(selected: on) }
                    .foregroundStyle(on ? T.lime : T.text).padding(18)
            }.background(on ? T.raised : T.surface, in: RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(on ? T.lime : T.line, lineWidth: 1.5))
                .clipShape(RoundedRectangle(cornerRadius: 22))
        }.buttonStyle(.plain).accessibilityLabel(title).accessibilityAddTraits(on ? .isSelected : [])
            .accessibilityIdentifier("onboarding.sex.\(sex.rawValue)")
    }
}

/// A calendar page, not an unrelated numeric badge.
private struct ExperienceCalendarIcon: View {
    var value: String
    var selected: Bool
    var body: some View {
        Image("experience-calendar-" + key + (selected ? "-selected" : ""))
            .resizable().scaledToFit().frame(width: 96, height: 96)
            .accessibilityHidden(true).allowsHitTesting(false)
    }
    private var key: String {
        switch value { case "<6": "new"; case "6–24": "experienced"; default: "advanced" }
    }
}
