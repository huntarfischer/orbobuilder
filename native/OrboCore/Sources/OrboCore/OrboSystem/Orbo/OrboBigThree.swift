import Foundation

/// Presentation-ready native truth established elsewhere and supplied to Orbo.
/// Orbo may present these sign labels; he does not calculate or reinterpret them.
public struct OrboEstablishedBigThree: Hashable, Sendable {
    public let ascendantSign: String
    public let moonSign: String
    public let sunSign: String

    public init?(
        ascendantSign: String,
        moonSign: String,
        sunSign: String
    ) {
        let ascendant = ascendantSign.trimmingCharacters(in: .whitespacesAndNewlines)
        let moon = moonSign.trimmingCharacters(in: .whitespacesAndNewlines)
        let sun = sunSign.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !ascendant.isEmpty, !moon.isEmpty, !sun.isEmpty else { return nil }

        self.ascendantSign = ascendant
        self.moonSign = moon
        self.sunSign = sun
    }
}

public enum OrboBigThreeProgress: Hashable, Sendable {
    case moment
    case ascendant
    case moon
    case sun
    case bigThree
    case focus
    case tourChoice
    case complete
}

public enum OrboTourChoice: Hashable, Sendable {
    case noThanks
    case yesPlease
}

public struct OrboBigThreeBeat: Hashable, Sendable {
    public let progress: OrboBigThreeProgress
    public let orboLines: [String]

    internal init(progress: OrboBigThreeProgress, orboLines: [String]) {
        self.progress = progress
        self.orboLines = orboLines
    }
}

public enum OrboBigThreeFailure: Error, Hashable, Sendable {
    case nativeTruthUnavailable
    case astrosphereIntroductionIncomplete
    case notStarted
    case tourResponseRequired
    case tourResponseNotExpected
    case complete
}

/// The canonical Part Four FOH sequence. It consumes already-established
/// presentation truth and contains no astrology calculation surface.
public struct OrboBigThreeSession: Hashable, Sendable {
    public let truth: OrboEstablishedBigThree
    public private(set) var progress: OrboBigThreeProgress
    public private(set) var tourChoice: OrboTourChoice?

    internal init(truth: OrboEstablishedBigThree) {
        self.truth = truth
        self.progress = .moment
        self.tourChoice = nil
    }

    public var currentBeat: OrboBigThreeBeat {
        switch progress {
        case .moment:
            return OrboBigThreeBeat(
                progress: progress,
                orboLines: ["The moment you were born is as unique to you as your DNA."]
            )

        case .ascendant:
            return OrboBigThreeBeat(
                progress: progress,
                orboLines: ["When you were born, \(truth.ascendantSign) was on the horizon."]
            )

        case .moon:
            return OrboBigThreeBeat(
                progress: progress,
                orboLines: ["When you were born, the Moon was in \(truth.moonSign)."]
            )

        case .sun:
            return OrboBigThreeBeat(
                progress: progress,
                orboLines: ["When you were born, the Sun was in \(truth.sunSign)."]
            )

        case .bigThree:
            return OrboBigThreeBeat(
                progress: progress,
                orboLines: ["Your Sun, Moon and rising are known as your Big Three."]
            )

        case .focus:
            return OrboBigThreeBeat(
                progress: progress,
                orboLines: [
                    "The Big Three focus on how you show up in the world. And how the astrosphere shows up for you."
                ]
            )

        case .tourChoice:
            return OrboBigThreeBeat(
                progress: progress,
                orboLines: ["Would you like a tour?"]
            )

        case .complete:
            return OrboBigThreeBeat(
                progress: progress,
                orboLines: ["The astrosphere awaits!"]
            )
        }
    }

    public mutating func advance() throws {
        switch progress {
        case .moment:
            progress = .ascendant
        case .ascendant:
            progress = .moon
        case .moon:
            progress = .sun
        case .sun:
            progress = .bigThree
        case .bigThree:
            progress = .focus
        case .focus:
            progress = .tourChoice
        case .tourChoice:
            throw OrboBigThreeFailure.tourResponseRequired
        case .complete:
            throw OrboBigThreeFailure.complete
        }
    }

    public mutating func respondToTour(_ choice: OrboTourChoice) throws {
        guard progress == .tourChoice else {
            if progress == .complete { throw OrboBigThreeFailure.complete }
            throw OrboBigThreeFailure.tourResponseNotExpected
        }

        tourChoice = choice
        progress = .complete
    }
}
