import SwiftUI

/// Sơ đồ cơ thể phẳng hai màu (thay hình nộm 3D tô cam kiểu Fitbod).
/// Hình vẽ: react-native-body-highlighter 3.2.0 (MIT, © 2022 ELABBASSI Hicham).
struct BodyShapes {
    struct Part { var slug: String; var polys: [[CGPoint]] }
    struct Side { var parts: [Part]; var outline: [[CGPoint]] }
    var front: Side
    var back: Side

    static let male: BodyShapes? = load("male")
    static let female: BodyShapes? = load("female")

    private static func load(_ key: String) -> BodyShapes? {
        guard let url = Res.url("body-shapes", "json"),
              let data = try? Data(contentsOf: url),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let sex = root[key] as? [String: Any] else { return nil }
        func points(_ any: Any?) -> [[CGPoint]] {
            guard let polys = any as? [[[Double]]] else { return [] }
            return polys.map { $0.compactMap { $0.count >= 2 ? CGPoint(x: $0[0], y: $0[1]) : nil } }
        }
        func side(_ name: String) -> Side? {
            guard let s = sex[name] as? [String: Any], let parts = s["parts"] as? [[String: Any]] else { return nil }
            return Side(parts: parts.compactMap { p in
                guard let slug = p["slug"] as? String else { return nil }
                return Part(slug: slug, polys: points(p["polys"]))
            }, outline: points(s["outline"]))
        }
        guard let f = side("front"), let b = side("back") else { return nil }
        return BodyShapes(front: f, back: b)
    }
}

struct BodyOutlineShape: Shape {
    var polys: [[CGPoint]]
    func path(in rect: CGRect) -> Path {
        let s = min(rect.width / 0.9, rect.height / 1.78)
        let ox = rect.midX, oy = rect.midY + 0.875 * s
        var p = Path()
        for poly in polys where poly.count > 2 {
            p.move(to: CGPoint(x: ox + poly[0].x * s, y: oy - poly[0].y * s))
            for pt in poly.dropFirst() { p.addLine(to: CGPoint(x: ox + pt.x * s, y: oy - pt.y * s)) }
            p.closeSubpath()
        }
        return p
    }
}

/// Vẽ một mặt cơ thể; mỗi vùng cơ lấy màu từ `color(slug)`.
struct BodySideView: View {
    var side: BodyShapes.Side
    var color: (String) -> Color
    var body: some View {
        ZStack {
            BodyOutlineShape(polys: side.outline).fill(Color.white.opacity(0.04))
            ForEach(Array(side.parts.enumerated()), id: \.offset) { _, part in
                BodyOutlineShape(polys: part.polys).fill(color(part.slug))
            }
            BodyOutlineShape(polys: side.outline).stroke(Color.white.opacity(0.12), lineWidth: 0.8)
        }
        .aspectRatio(0.9 / 1.78, contentMode: .fit)
    }
}

/// Sơ đồ đầy đủ trước + sau.
struct BodyMapView: View {
    var female = false
    var color: (String) -> Color
    var body: some View {
        if let shapes = (female ? BodyShapes.female : BodyShapes.male) ?? BodyShapes.male {
            HStack(spacing: 18) {
                VStack(spacing: 6) {
                    BodySideView(side: shapes.front, color: color)
                    Text("Mặt trước").font(T.font(12)).foregroundStyle(T.faint)
                }
                VStack(spacing: 6) {
                    BodySideView(side: shapes.back, color: color)
                    Text("Mặt sau").font(T.font(12)).foregroundStyle(T.faint)
                }
            }
        } else {
            Text("Không tải được sơ đồ cơ thể").font(T.font(13)).foregroundStyle(T.sub)
        }
    }
}

/// Biểu tượng nhỏ cho một nhóm cơ: hình người phẳng, tô trắng vùng cơ đó.
struct MuscleMiniMap: View {
    var muscle: Muscle
    var tint: Color = .white
    var body: some View {
        if let shapes = BodyShapes.male {
            let backFirst: Set<Muscle> = [.back, .lowerBack, .triceps, .hamstrings, .glutes]
            let side = backFirst.contains(muscle) ? shapes.back : shapes.front
            BodySideView(side: side) { slug in
                if ["head", "hair", "hands", "feet", "ankles", "knees", "neck"].contains(slug) { return Color.white.opacity(0.10) }
                return muscle.bodySlugs.contains(slug) ? tint : Color.white.opacity(0.18)
            }
        } else {
            Image(systemName: "figure.strengthtraining.traditional").foregroundStyle(tint)
        }
    }
}
