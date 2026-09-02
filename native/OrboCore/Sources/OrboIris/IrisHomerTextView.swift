import SwiftUI
import OrboCore

/// Iris manifestation of Homer's presentation-neutral port.
///
/// Iris renders the text and selections it receives. It does not interpret
/// entity state or decide what any selection means.
public struct IrisHomerTextView: View {
    public let port: HomerIrisPort
    private let onSelect: (HomerSelection) -> Void

    public init(
        port: HomerIrisPort,
        onSelect: @escaping (HomerSelection) -> Void = { _ in }
    ) {
        self.port = port
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(port.text)
                .font(.body.monospaced())
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("iris.homer.text")

            VStack(alignment: .leading, spacing: 10) {
                ForEach(port.selections, id: \.id) { selection in
                    Button {
                        onSelect(selection)
                    } label: {
                        Text("> \(selection.label)")
                            .font(.body.monospaced())
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("iris.homer.selection.\(selection.id)")
                }
            }
        }
        .accessibilityIdentifier("iris.homer")
    }
}
