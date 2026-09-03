import SwiftUI
import OrboCore

struct IrisLunarPaneView: View {
    let reading: ArtemisFactReading
    let hasNatal: Bool
    let select: (AstrolabeChart.Kind, AstroDNAGene?) -> Void
    let dismiss: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                Circle()
                    .fill(LinearGradient(colors: [Color(red: 0.36, green: 0.34, blue: 0.46).opacity(0.7),
                        IrisAstrolabeStyle.ink.opacity(0.97), IrisAstrolabeStyle.ink], startPoint: .top, endPoint: .bottom))
                    .overlay(Circle().stroke(IrisAstrolabeStyle.text.opacity(0.45), lineWidth: 0.8))
                    .frame(width: proxy.size.width * 2.1, height: proxy.size.width * 2.1)
                    .position(x: proxy.size.width / 2, y: proxy.size.width * 1.05)
                VStack(spacing: 12) {
                    HStack(spacing: 26) {
                        if hasNatal { lens("NATAL", kind: .natal) }
                        lens("THE SKY", kind: .sky)
                        Button(action: dismiss) { Image(systemName: "chevron.down").font(.system(size: 12)) }
                            .foregroundStyle(IrisAstrolabeStyle.text).accessibilityLabel("Lower Lunar Pane")
                    }
                    .padding(.top, 30)
                    Text(title).font(.custom("Avenir Next", size: 18))
                        .foregroundStyle(IrisAstrolabeStyle.text).lineLimit(1).minimumScaleFactor(0.8)
                    Text(reading.chart.name + (reading.chart.sect.map { " · \($0.rawValue) chart" } ?? ""))
                        .font(.system(size: 10)).foregroundStyle(IrisAstrolabeStyle.text.opacity(0.6))
                    HStack {
                        Text("BODY").frame(maxWidth: .infinity, alignment: .leading)
                        Text("HSE").frame(width: 30)
                        Text("DISPOSITOR").frame(width: 76)
                    }.font(.system(size: 9)).tracking(1.4).foregroundStyle(IrisAstrolabeStyle.text.opacity(0.6))
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(reading.rows, id: \.gene) { placement in
                                row(placement)
                            }
                            if let gene = reading.selectedGene, let condition = reading.chart.placement(gene)?.condition {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("CONDITION").font(.system(size: 9)).tracking(1.4)
                                    Text(condition.fieldTemper.dispositorPath.map(\.rawValue).joined(separator: " → "))
                                    Text("Bound: \(condition.boundRuler.rawValue) · Face: \(condition.faceRuler.rawValue)")
                                }.font(.system(size: 12)).foregroundStyle(IrisAstrolabeStyle.text)
                                    .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 14)
                            }
                            Text(reading.chart.kind == .natal
                                ? "Hestia’s kept Tapestry · whole-sign houses · Rhea’s condition testimony"
                                : "OrboSpine through Horae · whole-sign houses through Themis · condition through Rhea")
                                .font(.system(size: 9)).foregroundStyle(IrisAstrolabeStyle.text.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 12)
                        }
                    }.scrollIndicators(.hidden)
                }.padding(.horizontal, 28)
            }.clipped()
        }
        .accessibilityIdentifier("orbo.lunar-pane")
    }

    private var title: String {
        if let gene = reading.selectedGene {
            return "\(reading.chart.kind == .natal ? "natal" : "the sky ·") \(gene.displayName)"
        }
        return reading.chart.kind == .natal ? "my natal chart" : "the sky of this moment"
    }

    private func lens(_ title: String, kind: AstrolabeChart.Kind) -> some View {
        Button { select(kind, nil) } label: {
            Text(title).font(.system(size: 10, weight: .medium)).tracking(1.5)
                .foregroundStyle(reading.chart.kind == kind ? IrisAstrolabeStyle.gold : IrisAstrolabeStyle.text.opacity(0.6))
                .padding(.bottom, 7)
                .overlay(alignment: .bottom) {
                    if reading.chart.kind == kind { Rectangle().fill(IrisAstrolabeStyle.gold).frame(height: 0.7) }
                }
        }.accessibilityIdentifier("orbo.pane.\(kind.rawValue)")
    }

    private func row(_ placement: AstrolabePlacement) -> some View {
        let longitude = placement.longitude
        return Button { select(reading.chart.kind, placement.gene) } label: {
            HStack(spacing: 5) {
                Text(IrisAstrolabeStyle.glyph(placement.gene)).font(.system(size: 19))
                    .foregroundStyle(IrisAstrolabeStyle.color(longitude.sign)).frame(width: 20)
                (Text(placement.gene.displayName + "  ").foregroundColor(IrisAstrolabeStyle.color(longitude.sign))
                    + Text(IrisAstrolabeStyle.position(longitude) + " " + String(describing: longitude.sign).capitalized)
                        .foregroundColor(IrisAstrolabeStyle.text)
                    + Text(placement.motion == .retrograde ? " ℞" : "").foregroundColor(IrisAstrolabeStyle.gold))
                    .font(.system(size: 13)).lineLimit(1).minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(placement.house.map { "\($0.rawValue)" } ?? "—")
                    .font(.system(size: 13)).foregroundStyle(IrisAstrolabeStyle.text).frame(width: 30)
                if let bearer = placement.condition?.fieldTemper.bearer,
                   let gene = AstroDNAGene(rawValue: bearer.rawValue),
                   let dispositor = reading.chart.placement(gene) {
                    HStack(spacing: 5) {
                        Text(IrisAstrolabeStyle.glyph(gene)).foregroundStyle(IrisAstrolabeStyle.text)
                        Text(IrisAstrolabeStyle.signs[dispositor.longitude.sign.rawValue])
                            .foregroundStyle(IrisAstrolabeStyle.color(dispositor.longitude.sign))
                    }.font(.system(size: 17)).frame(width: 76)
                } else { Text("—").foregroundStyle(IrisAstrolabeStyle.text.opacity(0.5)).frame(width: 76) }
            }.padding(.vertical, 13)
                .overlay(alignment: .bottom) { Rectangle().fill(IrisAstrolabeStyle.text.opacity(0.15)).frame(height: 0.5) }
                .contentShape(Rectangle())
        }.buttonStyle(.plain)
        .accessibilityIdentifier("orbo.pane.row.\(placement.gene.rawValue)")
    }
}
