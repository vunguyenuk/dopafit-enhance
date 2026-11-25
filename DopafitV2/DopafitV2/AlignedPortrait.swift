import SwiftUI

/// Displays a cell from a single coherent photoshoot. Framing is shared by every variant.
/// The source remains intact; all cropping belongs to the native view.
struct SheetPortrait: View {
    var asset: String
    var index: Int
    var columns = 3
    var rows = 2
    var torso = false
    var cellInset: CGFloat = 0
    var body: some View {
        GeometryReader { g in
            let side = torso ? g.size.height * 1.36 : min(g.size.height, g.size.width * 1.5)
            Image(asset).resizable()
                .frame(width: side * CGFloat(columns), height: side * CGFloat(rows))
                .offset(x: -side * CGFloat(index % columns), y: -side * CGFloat(index / columns))
                .frame(width: side, height: side, alignment: .topLeading).clipped()
                .mask(Rectangle().padding(cellInset))
                .offset(x: (g.size.width - side) / 2, y: torso ? -side * 0.28 : g.size.height - side)
        }.clipped().accessibilityHidden(true)
    }
}

struct AlignedBodyPortrait: View {
    var photo: String
    var torso = false
    var sex: Profile.Sex = .male
    var body: some View {
        if BodyIllustration.cell(photo) == 3 {
            // A dedicated 1024×1536 cutout retains fine torso detail at phone size.
            // Keep the same head/mid-thigh height as the square atlas cells.
            GeometryReader { g in
                let side = torso ? g.size.height * 1.36 : min(g.size.height, g.size.width * 1.5)
                Image(sex == .female ? "female-body-defined" : "male-body-defined")
                    .resizable().interpolation(.high).scaledToFit()
                    .frame(width: side, height: side)
                    .offset(x: (g.size.width - side) / 2, y: torso ? -side * 0.28 : g.size.height - side)
            }.clipped().accessibilityHidden(true)
        } else {
            SheetPortrait(asset: BodyIllustration.bodySheet(sex),
                          index: BodyIllustration.cell(photo), torso: torso)
        }
    }
}
