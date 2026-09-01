public struct SynchronicThemisImprint: Sendable {
    public let offset: Int
    public let imprint: Tympan.Imprint

    public var risingSign: Sign {
        imprint.risingSign
    }

    internal init(offset: Int, imprint: Tympan.Imprint) {
        self.offset = offset
        self.imprint = imprint
    }
}

public struct SynchronicThemisField: Sendable {
    public static let canonicalOffsets = [-3, -2, -1, 0, 1, 2, 3]

    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID
    public let bone: SynchronicSpineBone
    public let natalRisingSign: Sign
    public let imprints: [SynchronicThemisImprint]

    internal init(
        subjectID: HermesSubjectID,
        ticketID: HermesTicketID,
        bone: SynchronicSpineBone,
        natalRisingSign: Sign,
        imprints: [SynchronicThemisImprint]
    ) {
        self.subjectID = subjectID
        self.ticketID = ticketID
        self.bone = bone
        self.natalRisingSign = natalRisingSign
        self.imprints = imprints
    }

    public subscript(offset: Int) -> SynchronicThemisImprint? {
        imprints.first { $0.offset == offset }
    }
}

public extension Themis {
    /// Selects the seven already-canonical Tympan Imprints centered on the
    /// native rising sign. Themis does not rebuild house or governance truth.
    static func synchronicImprints(around natalRisingSign: Sign) -> [SynchronicThemisImprint] {
        SynchronicThemisField.canonicalOffsets.map { offset in
            let raw = (natalRisingSign.rawValue + offset + 12) % 12
            let risingSign = Sign(rawValue: raw)!
            return SynchronicThemisImprint(
                offset: offset,
                imprint: Tympan.imprint(for: risingSign)
            )
        }
    }
}

public extension Lachesis {
    /// Calls Themis for the seven lawful Synchronic whole-sign frames around
    /// the native Ascendant. Every returned frame is the complete canonical
    /// Tympan Imprint, including its forward and reverse governance structure.
    static func callThemisForSynchronicSpine(
        foundation: SynchronicSpineFoundation,
        natalAstroDNA: AstroDNA
    ) -> SynchronicThemisField {
        let natalRisingSign = natalAstroDNA.sign(of: .ascendant)
        return SynchronicThemisField(
            subjectID: foundation.commission.subjectID,
            ticketID: foundation.commission.ticketID,
            bone: foundation.bone,
            natalRisingSign: natalRisingSign,
            imprints: Themis.synchronicImprints(around: natalRisingSign)
        )
    }
}
