import SwiftUI
import OrboCore

/// Text-only Iris manifestation of the same Horae frame used by Chart3D.
///
/// The view owns presentation only. All temporal and celestial truth has already
/// been resolved by Horae before the frame reaches Iris.
public struct IrisHoraeTextView: View {
    public let readout: IrisHoraeTextReadout

    public init(frame: IrisHoraeFrame) {
        self.readout = IrisHoraeTextReadout(frame: frame)
    }

    public init(readout: IrisHoraeTextReadout) {
        self.readout = readout
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("HORAE")
                    .font(.headline.monospaced())

                Text("UT · JD \(readout.julianDay.value, format: .number.precision(.fractionLength(5)))")
                    .font(.caption.monospaced())

                Divider()

                ForEach(readout.rows, id: \.body) { row in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(row.body.displayName)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(row.positionText)
                            .monospacedDigit()
                    }
                    .font(.body.monospaced())
                    .accessibilityElement(children: .combine)
                }

                Divider()

                Text(readout.terraReadout.displayText)
                    .font(.caption.monospaced())
            }
            .padding()
        }
        .accessibilityIdentifier("iris.horae.text")
    }
}
