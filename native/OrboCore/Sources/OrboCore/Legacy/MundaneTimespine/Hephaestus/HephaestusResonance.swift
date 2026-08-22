import Foundation

/// Identity of the Dioscuri resonance contract a Hephaestus recipe requires
/// before an immutable candidate may leave the forge.
///
/// Hephaestus does not interpret the contract's domain. It only binds manufacture
/// to an exact identifier/version and later requires matching Dioscuri testimony.
public struct HephaestusResonanceContractIdentity: Hashable, Codable, Sendable, CustomStringConvertible {
    public let identifier: String
    public let version: UInt16

    public var description: String { "\(identifier)/v\(version)" }

    public init?(identifier: String, version: UInt16) {
        guard !identifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              version > 0 else { return nil }
        self.identifier = identifier
        self.version = version
    }
}

/// Native resonance contracts currently understood by recipes.
/// New recipes may declare different contracts without changing Hephaestus.
public enum HephaestusResonanceContracts {
    public static let timespineV1 = HephaestusResonanceContractIdentity(
        identifier: "timespine-resonance",
        version: 1
    )!
}
