import SwiftUI
import OrboCore

public struct IrisTabulaView<Content: View>: View {
    @Binding var selected: HermesTabulaSeat
    let returnToAegis: () -> Void
    let content: () -> Content
    public init(selected: Binding<HermesTabulaSeat>, returnToAegis: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self._selected = selected; self.returnToAegis = returnToAegis; self.content = content
    }
    public var body: some View {
        GeometryReader { proxy in
            let diameter = min(proxy.size.width - 12, proxy.size.height * 0.51)
            VStack(spacing: 4) {
                ZStack {
                    Circle().fill(IrisAstrolabeStyle.ink).shadow(color: .black.opacity(0.5), radius: 8, y: 4)
                    ForEach(Hermes.tabulaSeats, id: \.self) { seat in
                        let angle = Double(seat.rawValue) * 30 + 180
                        TabulaWedge(start: angle - 15, end: angle + 15)
                            .fill(seat == selected ? IrisAstrolabeStyle.gold.opacity(0.16) : .clear)
                            .overlay(TabulaWedge(start: angle - 15, end: angle + 15).stroke(IrisAstrolabeStyle.text.opacity(0.22), lineWidth: 0.7))
                            .contentShape(TabulaWedge(start: angle - 15, end: angle + 15))
                            .onTapGesture { selected = seat }
                        Button { selected = seat } label: {
                            VStack(spacing: 4) {
                                Text(IrisAstrolabeStyle.signs[seat.rawValue]).font(.system(size: 20))
                                Text(seat.title).font(.system(size: 8)).lineLimit(1).minimumScaleFactor(0.7)
                            }.foregroundStyle(seat == selected ? IrisAstrolabeStyle.gold : IrisAstrolabeStyle.text.opacity(0.7))
                                .frame(width: diameter * 0.23, height: 44).contentShape(Rectangle())
                        }.buttonStyle(.plain).accessibilityIdentifier("orbo.tabula.\(seat.rawValue)")
                            .position(x: diameter / 2 + cos(angle * .pi / 180) * diameter * 0.38,
                                      y: diameter / 2 - sin(angle * .pi / 180) * diameter * 0.38)
                    }
                    VStack(spacing: 10) {
                        Text(selected.title).font(.custom("Avenir Next", size: 18))
                        Text(selected.owner.uppercased()).font(.system(size: 9)).tracking(2).foregroundStyle(IrisAstrolabeStyle.gold)
                        Button("AEGIS", action: returnToAegis).font(.system(size: 10)).tracking(2).padding(10)
                            .overlay(Capsule().stroke(IrisAstrolabeStyle.text.opacity(0.3)))
                            .accessibilityIdentifier("orbo.tabula.return")
                    }.foregroundStyle(IrisAstrolabeStyle.text)
                }.frame(width: diameter, height: diameter)
                ScrollView { content().padding(22).frame(maxWidth: .infinity, alignment: .leading) }
                    .scrollIndicators(.hidden).background(IrisAstrolabeStyle.ink.opacity(0.9))
            }.frame(maxWidth: .infinity)
        }
    }
}
private struct TabulaWedge: Shape {
    let start: Double
    let end: Double
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        path.addArc(center: center, radius: radius, startAngle: .degrees(-end), endAngle: .degrees(-start), clockwise: false)
        path.addArc(center: center, radius: radius * 0.55, startAngle: .degrees(-start), endAngle: .degrees(-end), clockwise: true)
        path.closeSubpath()
        return path
    }
}
