import SwiftUI
import OrboCore

/// Rows, caption, credits and rests all come from Artemis's accepted pass.
struct IrisLunarCourseView: View {
    let reading: ArtemisLunarReading
    let goToMoment: (JulianDay) -> Void
    var body: some View {
        VStack(spacing: 10) {
            Text(reading.caption).font(.custom("Avenir Next", size: 17))
                .accessibilityIdentifier("orbo.pane.title")
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if reading.ticket.rows.isEmpty { Text("No matching events in this reading.").font(.caption) }
                    ForEach(Array(reading.ticket.rows.enumerated()), id: \.offset) { _, row in rowView(row) }
                    if !reading.provenance.isEmpty {
                        Text(reading.provenance.joined(separator: " · ")).font(.system(size: 9))
                            .foregroundStyle(IrisAstrolabeStyle.text.opacity(0.55)).padding(.top, 10)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 34)
            }.scrollIndicators(.hidden)
        }.foregroundStyle(IrisAstrolabeStyle.text).padding(.horizontal, 26)
    }
    @ViewBuilder private func rowView(_ row: LunarRow) -> some View {
        switch row {
        case let .fact(key, value, _):
            HStack(alignment: .firstTextBaseline) { Text(key).foregroundStyle(IrisAstrolabeStyle.gold); Spacer(); Text(value).multilineTextAlignment(.trailing) }.font(.system(size: 13))
        case let .relation(left, mark, right, orb):
            HStack { Text(left); Text(mark).foregroundStyle(IrisAstrolabeStyle.gold); Text(right); Spacer(); if let orb { Text(String(format: "%.2f°", orb)).font(.caption.monospacedDigit()) } }.font(.system(size: 12))
        case let .ledger(mark, what, when, track):
            Button { goToMoment(when) } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text(mark + "  " + what).font(.system(size: 12))
                    Text(date(when)).font(.caption.monospacedDigit()).foregroundStyle(IrisAstrolabeStyle.gold)
                    if let track { trackView(track) }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }.buttonStyle(.plain)
        case let .span(span): spanView(span)
        case let .prose(_, text, source):
            Text(text).font(.body)
            Text(source).font(.caption).foregroundStyle(IrisAstrolabeStyle.gold)
        }
        Divider().overlay(IrisAstrolabeStyle.text.opacity(0.12))
    }
    private func spanView(_ span: LunarSpan) -> AnyView {
        AnyView(VStack(alignment: .leading, spacing: 6) {
            Text("\(span.glyph) · L\(span.level)")
            Text(date(span.start) + " — " + date(span.end)).font(.caption)
            if let track = span.track { trackView(track) }
            ForEach(Array(span.children.enumerated()), id: \.offset) { _, child in spanView(child).padding(.leading, 12) }
        })
    }
    private func trackView(_ track: LunarTrack) -> some View {
        VStack(alignment: .leading) {
            ProgressView(value: track.fill).tint(IrisAstrolabeStyle.gold)
            Text("\(track.value.formatted()) \(track.unit) · \(track.minimum.formatted())–\(track.maximum.formatted())").font(.caption2)
        }
    }
    private func date(_ jd: JulianDay) -> String {
        Date(timeIntervalSince1970: (jd.value - 2440587.5) * 86400).formatted(date: .abbreviated, time: .shortened)
    }
}
