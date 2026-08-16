import SwiftUI
import OrboCore

@main
struct OrboLabApp: App {
    var body: some Scene {
        WindowGroup {
            FoundationLabView()
        }
    }
}

private struct FoundationLabView: View {
    private let bodyLongitude = CelestialLongitude(70)!
    private let ascendantLongitude = CelestialLongitude(220)!

    private var condition: EssentialCondition {
        Mater.essentialCondition(
            of: .mars,
            at: bodyLongitude,
            sect: .day
        )!
    }

    private var frame: Tympan.Frame {
        Tympan.frame(for: .scorpio)
    }

    private var ringRelation: RingMark? {
        let bodyState = Ring.state(of: bodyLongitude, motion: .direct)
        let ascendantState = Ring.state(of: ascendantLongitude, motion: .retrograde)
        return Ring.relation(between: bodyState, and: ascendantState)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("ORBO LAB")
                    .font(.title2.monospaced().weight(.semibold))

                Text("PHASE 1a / NATIVE FOUNDATION")
                    .font(.caption.monospaced())

                Divider()

                sectionTitle("RING")
                readout("states", "\(Ring.states)")
                readout("fine states", "\(Ring.fineStates)")
                readout("marks", "\(Ring.marks.count)")
                readout("sample", "70 -> 220")
                readout("relation", ringRelation.map(ringMarkName) ?? "none")

                Divider()

                sectionTitle("MATER")
                readout("planet", condition.planet.rawValue)
                readout("longitude", "\(condition.longitude.degrees)")
                readout("sign", signName(condition.longitude.sign))
                readout("element", Mater.element(of: condition.longitude.sign).rawValue)
                readout("modality", Mater.modality(of: condition.longitude.sign).rawValue)
                readout("domicile ruler", Mater.domicileRuler(of: condition.longitude.sign).rawValue)
                readout("dignities", dignityText)
                readout("debilities", debilityText)
                readout("bound ruler", condition.bound.ruler.rawValue)
                readout("face ruler", condition.face.ruler.rawValue)
                readout("peregrine", condition.isPeregrine ? "yes" : "no")

                Divider()

                sectionTitle("TYMPAN")
                readout("rising", signName(frame.risingSign))
                readout(
                    "Mars governs",
                    houseList(Tympan.housesRuled(by: .mars, rising: frame.risingSign))
                )

                ForEach(frame.houses, id: \.house) { record in
                    let coRuler = record.coRuler.map { " / co-ruler \($0.rawValue)" } ?? ""
                    readout(
                        "house \(record.house.rawValue)",
                        "\(signName(record.sign)) / \(record.ruler.rawValue)\(coRuler)"
                    )
                }

                Divider()

                Text("Diagnostic readout of live OrboCore. Tests remain the proof authority.")
                    .font(.caption.monospaced())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
    }

    private var dignityText: String {
        let values = DignityRung.allCases
            .filter { condition.dignities.contains($0) }
            .map(\.rawValue)
        return values.isEmpty ? "none" : values.joined(separator: ", ")
    }

    private var debilityText: String {
        let values = EssentialDebility.allCases
            .filter { condition.debilities.contains($0) }
            .map(\.rawValue)
        return values.isEmpty ? "none" : values.joined(separator: ", ")
    }

    private func houseList(_ houses: [House]) -> String {
        houses.map { String($0.rawValue) }.joined(separator: ", ")
    }

    @ViewBuilder
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline.monospaced())
    }

    @ViewBuilder
    private func readout(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .frame(width: 120, alignment: .leading)

            Text(value)
                .font(.body.monospaced())
                .textSelection(.enabled)
        }
    }

    private func ringMarkName(_ mark: RingMark) -> String {
        switch mark {
        case .conjunction: return "conjunction"
        case .semisextile: return "semisextile"
        case .semisquare: return "semisquare"
        case .sextile: return "sextile"
        case .quintile: return "quintile"
        case .square: return "square"
        case .trine: return "trine"
        case .sesquiquadrate: return "sesquiquadrate"
        case .biquintile: return "biquintile"
        case .quincunx: return "quincunx"
        case .opposition: return "opposition"
        }
    }

    private func signName(_ sign: Sign) -> String {
        switch sign {
        case .aries: return "Aries"
        case .taurus: return "Taurus"
        case .gemini: return "Gemini"
        case .cancer: return "Cancer"
        case .leo: return "Leo"
        case .virgo: return "Virgo"
        case .libra: return "Libra"
        case .scorpio: return "Scorpio"
        case .sagittarius: return "Sagittarius"
        case .capricorn: return "Capricorn"
        case .aquarius: return "Aquarius"
        case .pisces: return "Pisces"
        }
    }
}
