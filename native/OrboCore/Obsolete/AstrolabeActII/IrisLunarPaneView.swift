import SwiftUI
import OrboCore

/// One circular limb, lowered or raised. Its rim catches light; its body deepens
/// to opaque violet before the reading begins (_pane material in the prototype).
struct IrisLunarPaneMaterial: View {
    var body: some View {
        GeometryReader { proxy in
            Circle()
                .fill(LinearGradient(stops: [
                    .init(color: Color(red: 0.58, green: 0.55, blue: 0.64).opacity(0.45), location: 0),
                    .init(color: IrisAstrolabeStyle.ink.opacity(0.6), location: 0.045),
                    .init(color: IrisAstrolabeStyle.ink.opacity(0.93), location: 0.10),
                    .init(color: IrisAstrolabeStyle.ink, location: 0.20)
                ], startPoint: .top, endPoint: .bottom))
                .overlay(Circle().stroke(IrisAstrolabeStyle.text.opacity(0.4), lineWidth: 0.7))
                .shadow(color: IrisAstrolabeStyle.text.opacity(0.12), radius: 6, y: -3)
                .frame(width: proxy.size.width * 2.1, height: proxy.size.width * 2.1)
                .position(x: proxy.size.width / 2, y: proxy.size.width * 1.05)
        }.clipped().allowsHitTesting(false)
    }
}

struct IrisLunarPaneView: View {
    let reading: ArtemisFactReading
    let hasNatal: Bool
    let select: (AstrolabeChart.Kind, AstroDNAGene?) -> Void
    let dismiss: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                IrisLunarPaneMaterial()
                VStack(spacing: 7) {
                    crown(width: proxy.size.width).frame(height: 64)
                    Text(title).font(.custom("Avenir Next", size: 17))
                        .foregroundStyle(IrisAstrolabeStyle.text).lineLimit(1).minimumScaleFactor(0.8)
                        .accessibilityIdentifier("orbo.pane.title")
                    Text(reading.chart.name + (reading.chart.sect.map { " · \($0.rawValue) chart" } ?? ""))
                        .font(.system(size: 9)).foregroundStyle(IrisAstrolabeStyle.text.opacity(0.6))
                    HStack {
                        Text("BODY").frame(maxWidth: .infinity, alignment: .leading)
                        Text("HSE").frame(width: 25)
                        Text("DISPOSITOR").frame(width: 68)
                    }.font(.system(size: 8)).tracking(1.4).foregroundStyle(IrisAstrolabeStyle.text.opacity(0.6))
                        .padding(.top, 4).padding(.bottom, 2)
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(reading.rows, id: \.gene) { placement in row(placement) }
                            if let gene = reading.selectedGene, let condition = reading.chart.placement(gene)?.condition {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("CONDITION").font(.system(size: 9)).tracking(1.4)
                                    Text(condition.fieldTemper.dispositorPath.map(\.rawValue).joined(separator: " → "))
                                    Text("Bound: \(condition.boundRuler.rawValue) · Face: \(condition.faceRuler.rawValue)")
                                }.font(.system(size: 12)).foregroundStyle(IrisAstrolabeStyle.text)
                                    .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 14)
                            }
                        }.padding(.bottom, 28)
                    }.scrollIndicators(.hidden)
                }.padding(.horizontal, 26)
            }.clipped()
        }.accessibilityElement(children: .contain)
    }

    /// The selected lens sits at the crown, its neighbor along the same arc.
    /// Act II adds the rotational gesture; this pass uses the existing selection.
    private func crown(width: Double) -> some View {
        ZStack {
            if hasNatal {
                lens("NATAL", kind: .natal)
                    .rotationEffect(.degrees(reading.chart.kind == .natal ? 0 : -16))
                    .offset(x: reading.chart.kind == .natal ? 0 : -width * 0.25,
                            y: reading.chart.kind == .natal ? 0 : 14)
            }
            lens("THE SKY", kind: .sky)
                .rotationEffect(.degrees(reading.chart.kind == .sky ? 0 : 16))
                .offset(x: reading.chart.kind == .sky ? 0 : width * 0.25,
                        y: reading.chart.kind == .sky ? 0 : 14)
            Button(action: dismiss) { Image(systemName: "chevron.down").font(.system(size: 10)).frame(width: 30, height: 30) }
                .foregroundStyle(IrisAstrolabeStyle.text.opacity(0.65))
                .offset(x: width / 2 - 42, y: 48)
                .accessibilityLabel("Lower Lunar Pane").accessibilityIdentifier("orbo.pane.close")
        }.padding(.top, 22)
    }

    private var title: String {
        if let gene = reading.selectedGene { return "\(reading.chart.kind == .natal ? "natal" : "the sky ·") \(gene.displayName)" }
        return reading.chart.kind == .natal ? "my natal chart" : "the sky of this moment"
    }

    private func lens(_ title: String, kind: AstrolabeChart.Kind) -> some View {
        Button { select(kind, nil) } label: {
            Text(title).font(.system(size: 10, weight: .medium)).tracking(1.5)
                .foregroundStyle(reading.chart.kind == kind ? IrisAstrolabeStyle.gold : IrisAstrolabeStyle.text.opacity(0.6))
                .frame(minWidth: 64, minHeight: 36)
                .overlay(alignment: .bottom) {
                    if reading.chart.kind == kind { Rectangle().fill(IrisAstrolabeStyle.gold).frame(width: 52, height: 0.7) }
                }
        }.buttonStyle(.plain).accessibilityIdentifier("orbo.pane.\(kind.rawValue)")
    }

    private func row(_ placement: AstrolabePlacement) -> some View {
        let longitude = placement.longitude
        return Button { select(reading.chart.kind, placement.gene) } label: {
            HStack(spacing: 4) {
                Text(IrisAstrolabeStyle.glyph(placement.gene)).font(.system(size: 18))
                    .foregroundStyle(IrisAstrolabeStyle.color(longitude.sign)).frame(width: 19)
                (Text(placement.gene.displayName + "  ").foregroundColor(IrisAstrolabeStyle.color(longitude.sign))
                    + Text(IrisAstrolabeStyle.position(longitude) + " " + String(describing: longitude.sign).capitalized)
                        .foregroundColor(IrisAstrolabeStyle.text)
                    + Text(placement.motion == .retrograde ? " ℞" : "").foregroundColor(IrisAstrolabeStyle.gold)
                    + Text("  " + IrisAstrolabeStyle.signs[longitude.sign.rawValue]).foregroundColor(IrisAstrolabeStyle.color(longitude.sign)))
                    .font(.system(size: 12)).lineLimit(1).minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(placement.house.map { "\($0.rawValue)" } ?? "—")
                    .font(.system(size: 12)).foregroundStyle(IrisAstrolabeStyle.text).frame(width: 25)
                if let bearer = placement.condition?.fieldTemper.bearer,
                   let gene = AstroDNAGene(rawValue: bearer.rawValue),
                   let dispositor = reading.chart.placement(gene) {
                    HStack(spacing: 5) {
                        Text(IrisAstrolabeStyle.glyph(gene)).foregroundStyle(IrisAstrolabeStyle.text)
                        Text(IrisAstrolabeStyle.signs[dispositor.longitude.sign.rawValue])
                            .foregroundStyle(IrisAstrolabeStyle.color(dispositor.longitude.sign))
                    }.font(.system(size: 16)).frame(width: 68)
                } else { Text("—").foregroundStyle(IrisAstrolabeStyle.text.opacity(0.5)).frame(width: 68) }
            }.frame(minHeight: 37)
                .overlay(alignment: .bottom) { Rectangle().fill(IrisAstrolabeStyle.text.opacity(0.15)).frame(height: 0.5) }
                .contentShape(Rectangle())
        }.buttonStyle(.plain).accessibilityIdentifier("orbo.pane.row.\(placement.gene.rawValue)")
    }
}
