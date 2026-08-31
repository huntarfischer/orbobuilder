public struct NatalSpineNativeTruth: Hashable, Sendable {
    public let subjectID: HermesSubjectID
    public let tempus: Tempus
    public let tapestry: AtroposTapestryPackage
    public let sect: Sect

    public init(
        subjectID: HermesSubjectID,
        tempus: Tempus,
        tapestry: AtroposTapestryPackage,
        sect: Sect
    ) {
        self.subjectID = subjectID
        self.tempus = tempus
        self.tapestry = tapestry
        self.sect = sect
    }
}

public enum NatalSpineHearthIntakeFailure: Error, Hashable, Sendable {
    case hearthUnlit
    case wrongSubject
    case missingTempus
    case missingTapestry
    case missingPreservedSect
    case inconsistentPreservedSect
}

public extension Hestia {
    /// Reads only truth already kept at the lit Hearth for Natal Spine construction.
    /// Sect is recovered from the canonical Tapestry's preserved Mater testimony;
    /// no chart geometry or astrological formula is rerun here.
    func natalSpineNativeTruth(
        for subjectID: HermesSubjectID
    ) throws -> NatalSpineNativeTruth {
        guard hearthLit, let engraving = nativeEngraving() else {
            throw NatalSpineHearthIntakeFailure.hearthUnlit
        }
        guard subjectID == nativeSubjectID,
              engraving.subjectID == subjectID else {
            throw NatalSpineHearthIntakeFailure.wrongSubject
        }
        guard let tempus = engraving.tempus else {
            throw NatalSpineHearthIntakeFailure.missingTempus
        }
        guard let tapestry = engraving.tapestry else {
            throw NatalSpineHearthIntakeFailure.missingTapestry
        }
        let sect = try preservedSect(from: tapestry)

        return NatalSpineNativeTruth(
            subjectID: subjectID,
            tempus: tempus,
            tapestry: tapestry,
            sect: sect
        )
    }

    private func preservedSect(
        from package: AtroposTapestryPackage
    ) throws -> Sect {
        let conditions = package.tapestry.degrees.flatMap { $0.mater.conditions }
        guard !conditions.isEmpty else {
            throw NatalSpineHearthIntakeFailure.missingPreservedSect
        }

        if conditions.allSatisfy({ $0.sectDay && !$0.sectNight }) {
            return .day
        }
        if conditions.allSatisfy({ !$0.sectDay && $0.sectNight }) {
            return .night
        }

        throw NatalSpineHearthIntakeFailure.inconsistentPreservedSect
    }
}
