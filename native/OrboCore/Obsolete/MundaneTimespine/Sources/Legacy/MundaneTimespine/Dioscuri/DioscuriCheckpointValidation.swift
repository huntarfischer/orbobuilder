import Foundation

/// Structural validation for durable partial testimony. Resume is allowed to skip completed
/// questions only when the stored tally shape is exactly the shape that deterministic prefix can
/// have, and every recorded first-strike divergence has one matching tally divergence.
enum DioscuriCheckpointValidator {
    static let law = "exact scope-count shape + divergence parity / no replay"

    static func validate(
        checkpoint: DioscuriCertificationCheckpoint,
        storage: MundaneTimespineStorageImage
    ) throws {
        let tallies = Dictionary(uniqueKeysWithValues: checkpoint.scopeTallies.map { ($0.scope, $0) })
        guard tallies.count == DioscuriScope.allCases.count else {
            throw DioscuriCheckpointError.invalidTallies
        }

        let expected: [DioscuriScope: Int] = [
            .bodyOccurrence: checkpoint.completed.bodyOccurrence,
            .marker: markerCheckCount(
                forBodyQuestionPrefix: checkpoint.completed.bodyOccurrence,
                storage: storage
            ),
            .motion: checkpoint.completed.bodyOccurrence
                + checkpoint.completed.motionTopology
                + checkpoint.completed.station,
            .exactRelationship: checkpoint.completed.exactRelationship,
            .eclipse: checkpoint.completed.eclipse,
        ]

        for scope in DioscuriScope.allCases {
            guard tallies[scope]?.questions == expected[scope] else {
                throw DioscuriCheckpointError.invalidTallies
            }
        }

        let divergenceCounts = Dictionary(grouping: checkpoint.divergences, by: \.scope)
            .mapValues { $0.count }
        for scope in DioscuriScope.allCases {
            guard divergenceCounts[scope, default: 0] == tallies[scope]!.divergent else {
                throw DioscuriCheckpointError.invalidTallies
            }
        }
    }

    private static func markerCheckCount(
        forBodyQuestionPrefix completed: Int,
        storage: MundaneTimespineStorageImage
    ) -> Int {
        var remaining = completed
        var count = 0

        for body in storage.bodies.sorted(by: { $0.body.rawValue < $1.body.rawValue }) {
            guard remaining > 0 else { break }
            let consumed = min(remaining, body.occurrences.count)
            count += consumed * body.markerBodies.count
            remaining -= consumed
        }
        return count
    }
}
