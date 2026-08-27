import Foundation

public enum OrboReadingDepth: Int, Hashable, Sendable {
    case l1 = 1
    case l2 = 2
    case l3 = 3
}

public enum OrboAstrologyInterest: Hashable, Sendable {
    case notVery
    case interested
    case veryInterested

    public var readingDepth: OrboReadingDepth {
        switch self {
        case .notVery:
            return .l1
        case .interested:
            return .l2
        case .veryInterested:
            return .l3
        }
    }

    public var displayLabel: String {
        switch self {
        case .notVery:
            return "NOT VERY"
        case .interested:
            return "INTERESTED"
        case .veryInterested:
            return "VERY INTERESTED"
        }
    }
}

public enum OrboBirthTimeKnowledge: Hashable, Sendable {
    case known
    case unknown
}

public enum OrboOnboardingProgress: Hashable, Sendable {
    case requestingName
    case requestingReadingDepth
    case requestingBirthDate
    case requestingBirthLocation
    case requestingBirthTimeKnowledge
    case requestingBirthTime
    case rectificationRequired
    case readyForEngraving
}

public struct OrboOnboardingBeat: Hashable, Sendable {
    public let progress: OrboOnboardingProgress
    public let orboLines: [String]

    internal init(
        progress: OrboOnboardingProgress,
        orboLines: [String]
    ) {
        self.progress = progress
        self.orboLines = orboLines
    }
}

public enum OrboOnboardingResponse: Hashable, Sendable {
    case name(String)
    case astrologyInterest(OrboAstrologyInterest)
    case birthDate(CivilDate)
    case birthLocation(String)
    case birthTimeKnowledge(OrboBirthTimeKnowledge)
    case birthTime(CivilClockTime)
}

public enum OrboOnboardingFailure: Error, Hashable, Sendable {
    case notStarted
    case unexpectedResponse
    case invalidName
    case invalidBirthLocation
    case terminalState
}

/// The narrow Front-of-House contract for Orbo's canonical onboarding script.
///
/// This is not a generic dialogue engine. It records only the answers Orbo asks
/// for in the root onboarding script and advances only in that script's order.
public struct OrboOnboardingSession: Hashable, Sendable {
    public private(set) var progress: OrboOnboardingProgress
    public private(set) var name: String?
    public private(set) var readingDepth: OrboReadingDepth?
    public private(set) var birthDate: CivilDate?
    public private(set) var birthLocation: String?
    public private(set) var birthTimeKnowledge: OrboBirthTimeKnowledge?
    public private(set) var birthTime: CivilClockTime?

    public init() {
        self.progress = .requestingName
        self.name = nil
        self.readingDepth = nil
        self.birthDate = nil
        self.birthLocation = nil
        self.birthTimeKnowledge = nil
        self.birthTime = nil
    }

    public var readyForEngraving: Bool {
        progress == .readyForEngraving
    }

    public var currentBeat: OrboOnboardingBeat {
        switch progress {
        case .requestingName:
            return OrboOnboardingBeat(
                progress: progress,
                orboLines: [
                    "Welcome, traveler.",
                    "My name is Orbo. What's yours?",
                ]
            )

        case .requestingReadingDepth:
            let travelerName = name ?? "Traveler"
            return OrboOnboardingBeat(
                progress: progress,
                orboLines: [
                    "Heya, \(travelerName). It's nice to meet you.",
                    "I am your guide to the astrosphere-the cosmic dimension on top of your own.",
                    "How interested are you in astrology?",
                ]
            )

        case .requestingBirthDate:
            return OrboOnboardingBeat(
                progress: progress,
                orboLines: [
                    "Everyone has their place in the astrosphere. Let's find yours.",
                    "What day were you born?",
                ]
            )

        case .requestingBirthLocation:
            return OrboOnboardingBeat(
                progress: progress,
                orboLines: ["Where were you Born?"]
            )

        case .requestingBirthTimeKnowledge:
            return OrboOnboardingBeat(
                progress: progress,
                orboLines: ["Do you know what time you were born?"]
            )

        case .requestingBirthTime:
            // The canonical root script moves directly from YES to the birth-time
            // entry control without adding another authored Orbo line.
            return OrboOnboardingBeat(progress: progress, orboLines: [])

        case .rectificationRequired:
            return OrboOnboardingBeat(
                progress: progress,
                orboLines: ["Do you know what time of day?"]
            )

        case .readyForEngraving:
            return OrboOnboardingBeat(progress: progress, orboLines: [])
        }
    }

    public mutating func respond(_ response: OrboOnboardingResponse) throws {
        switch (progress, response) {
        case let (.requestingName, .name(rawName)):
            let trimmed = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { throw OrboOnboardingFailure.invalidName }
            name = trimmed
            progress = .requestingReadingDepth

        case let (.requestingReadingDepth, .astrologyInterest(interest)):
            readingDepth = interest.readingDepth
            progress = .requestingBirthDate

        case let (.requestingBirthDate, .birthDate(date)):
            birthDate = date
            progress = .requestingBirthLocation

        case let (.requestingBirthLocation, .birthLocation(rawLocation)):
            let trimmed = rawLocation.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { throw OrboOnboardingFailure.invalidBirthLocation }
            birthLocation = trimmed
            progress = .requestingBirthTimeKnowledge

        case let (.requestingBirthTimeKnowledge, .birthTimeKnowledge(knowledge)):
            birthTimeKnowledge = knowledge
            switch knowledge {
            case .known:
                progress = .requestingBirthTime
            case .unknown:
                progress = .rectificationRequired
            }

        case let (.requestingBirthTime, .birthTime(time)):
            birthTime = time
            progress = .readyForEngraving

        case (.rectificationRequired, _), (.readyForEngraving, _):
            throw OrboOnboardingFailure.terminalState

        default:
            throw OrboOnboardingFailure.unexpectedResponse
        }
    }
}
