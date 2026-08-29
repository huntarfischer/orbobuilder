import Foundation

public enum HestiaPersistenceFailure: Error, Hashable, Sendable {
    case unsupportedCodec(Int)
    case invalidHouse
    case invalidHearth
    case invalidTapestry
}

public enum HestiaPersistence {
    public static let codec = 3

    public static func encode(_ hestia: Hestia) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(Snapshot(hestia: hestia))
    }

    public static func decode(_ data: Data) throws -> Hestia {
        let decoder = JSONDecoder()
        let envelope = try decoder.decode(CodecEnvelope.self, from: data)
        guard envelope.codec == Self.codec else {
            throw HestiaPersistenceFailure.unsupportedCodec(envelope.codec)
        }
        return try restore(decoder.decode(Snapshot.self, from: data))
    }

    public static func save(_ hestia: Hestia, to url: URL) throws {
        let data = try encode(hestia)
        try data.write(to: url, options: .atomic)
    }

    public static func load(from url: URL) throws -> Hestia {
        try decode(Data(contentsOf: url))
    }

    private static func restore(_ snapshot: Snapshot) throws -> Hestia {
        let holdingValues = snapshot.holdings.map { record in
            Holding(subjectID: record.subjectID, astroDNA: record.astroDNA)
        }
        let hallValues = try snapshot.hall.map { try $0.restore() }

        let holdingIDs = holdingValues.map(\.subjectID)
        let hallIDs = hallValues.map(\.subjectID)
        guard Set(holdingIDs).count == holdingIDs.count,
              Set(hallIDs).count == hallIDs.count,
              !holdingIDs.contains(snapshot.hearth.nativeSubjectID),
              !hallIDs.contains(snapshot.hearth.nativeSubjectID),
              Set(holdingIDs).isDisjoint(with: Set(hallIDs)) else {
            throw HestiaPersistenceFailure.invalidHouse
        }

        var holdings = Holdings()
        var hall = Hall()
        do {
            for holding in holdingValues {
                try holdings.admit(holding)
            }
            for resident in hallValues {
                try hall.admit(resident)
            }
        } catch {
            throw HestiaPersistenceFailure.invalidHouse
        }

        let engraving = try snapshot.hearth.engraving?.restore()
        guard let hearth = Hearth(
            restoringNativeSubjectID: snapshot.hearth.nativeSubjectID,
            engraving: engraving,
            hearthLit: snapshot.hearth.hearthLit
        ) else {
            throw HestiaPersistenceFailure.invalidHearth
        }

        return Hestia(
            restoringHoldings: holdings,
            hearth: hearth,
            hall: hall
        )
    }
}

private extension HestiaPersistence {
    struct CodecEnvelope: Codable {
        let codec: Int
    }

    struct Snapshot: Codable {
        let codec: Int
        let holdings: [HoldingRecord]
        let hearth: HearthRecord
        let hall: [HallResidentRecord]

        init(hestia: Hestia) throws {
            codec = HestiaPersistence.codec
            holdings = hestia.holdings.holdings.map(HoldingRecord.init)
            hearth = try HearthRecord(hestia.hearth)
            hall = hestia.hall.residents.map(HallResidentRecord.init)
        }
    }

    struct HoldingRecord: Codable {
        let subjectID: HermesSubjectID
        let astroDNA: AstroDNA

        init(_ holding: Holding) {
            subjectID = holding.subjectID
            astroDNA = holding.astroDNA
        }
    }

    struct HearthRecord: Codable {
        let nativeSubjectID: HermesSubjectID
        let hearthLit: Bool
        let engraving: EngravingRecord?

        init(_ hearth: Hearth) throws {
            if hearth.hearthLit {
                guard let engraving = hearth.engraving,
                      engraving.engraved,
                      engraving.subjectID == hearth.nativeSubjectID,
                      engraving.topos != nil,
                      engraving.tempus != nil,
                      engraving.astroDNA != nil,
                      engraving.tapestry != nil else {
                    throw HestiaPersistenceFailure.invalidHearth
                }
                self.engraving = try EngravingRecord(engraving)
            } else {
                guard hearth.engraving == nil else {
                    throw HestiaPersistenceFailure.invalidHearth
                }
                self.engraving = nil
            }

            nativeSubjectID = hearth.nativeSubjectID
            hearthLit = hearth.hearthLit
        }
    }

    struct EngravingRecord: Codable {
        let subjectID: HermesSubjectID
        let name: String
        let birthDate: CivilDate
        let birthTime: CivilClockTime
        let birthLocation: String
        let topos: Topos
        let tempus: Tempus
        let astroDNA: AstroDNA
        let tapestry: CanonicalTapestryRecord
        let engraved: Bool

        init(_ engraving: Engraving) throws {
            guard let topos = engraving.topos,
                  let tempus = engraving.tempus,
                  let astroDNA = engraving.astroDNA,
                  let tapestry = engraving.tapestry,
                  engraving.engraved else {
                throw HestiaPersistenceFailure.invalidHearth
            }

            subjectID = engraving.subjectID
            name = engraving.name
            birthDate = engraving.birthDate
            birthTime = engraving.birthTime
            birthLocation = engraving.birthLocation
            self.topos = topos
            self.tempus = tempus
            self.astroDNA = astroDNA
            self.tapestry = CanonicalTapestryRecord(tapestry.tapestry)
            engraved = true
        }

        func restore() throws -> Engraving {
            guard engraved else {
                throw HestiaPersistenceFailure.invalidHearth
            }
            let restoredTapestry = try tapestry.restore()
            let seal = AtroposTapestryPackage(restoringTapestry: restoredTapestry)

            return Engraving(
                restoringSubjectID: subjectID,
                name: name,
                birthDate: birthDate,
                birthTime: birthTime,
                birthLocation: birthLocation,
                topos: topos,
                tempus: tempus,
                astroDNA: astroDNA,
                tapestry: seal,
                engraved: true
            )
        }
    }

    struct HallResidentRecord: Codable {
        let subjectID: HermesSubjectID
        let astroDNA: AstroDNA
        let tapestry: CanonicalTapestryRecord

        init(_ resident: HallResident) {
            subjectID = resident.subjectID
            astroDNA = resident.astroDNA
            tapestry = CanonicalTapestryRecord(resident.tapestry.tapestry)
        }

        func restore() throws -> HallResident {
            let restoredTapestry = try tapestry.restore()
            return HallResident(
                subjectID: subjectID,
                astroDNA: astroDNA,
                tapestry: AtroposTapestryPackage(restoringTapestry: restoredTapestry)
            )
        }
    }

    struct CanonicalTapestryRecord: Codable {
        let degrees: [CanonicalDegreeRecord]

        init(_ tapestry: Tapestry) {
            degrees = tapestry.degrees.map(CanonicalDegreeRecord.init)
        }

        func restore() throws -> Tapestry {
            guard degrees.count == DegreeAddress.count else {
                throw HestiaPersistenceFailure.invalidTapestry
            }

            var restored: [TapestryDegree] = []
            restored.reserveCapacity(DegreeAddress.count)
            for (index, record) in degrees.enumerated() {
                guard let address = DegreeAddress(rawValue: record.address),
                      address == DegreeAddress.canonicalOrder[index] else {
                    throw HestiaPersistenceFailure.invalidTapestry
                }
                restored.append(try record.restore(at: address))
            }
            return Tapestry(allottedDegrees: restored)
        }
    }

    struct CanonicalDegreeRecord: Codable {
        let address: Int
        let placement: [PlacementRecord]
        let tympan: House?
        let mater: [QualifiedTemperRecord]
        let ring: [RingValueRecord]
        let arc: [ArcValueRecord]

        init(_ degree: TapestryDegree) {
            address = degree.address.rawValue
            placement = degree.placement.values.map(PlacementRecord.init)
            tympan = degree.tympan.house
            mater = degree.mater.conditions.map(QualifiedTemperRecord.init)
            ring = degree.ring.values.map(RingValueRecord.init)
            arc = degree.arc.values.map(ArcValueRecord.init)
        }

        func restore(at address: DegreeAddress) throws -> TapestryDegree {
            let placementValues = try placement.map { try $0.restore(at: address) }
            let materValues = try mater.map { try $0.restore(at: address) }
            let ringValues = try ring.map { try $0.restore(at: address) }
            let arcValues = try arc.map { try $0.restore(at: address) }

            return TapestryDegree(
                address: address,
                placement: TapestryPlacement(values: placementValues),
                tympan: TapestryTympan(house: tympan),
                mater: TapestryMater(conditions: materValues),
                ring: TapestryRing(values: ringValues),
                arc: TapestryArc(values: arcValues)
            )
        }
    }

    struct PlacementRecord: Codable {
        enum Kind: String, Codable {
            case astroDNA
            case fortune
            case spirit
            case eros
            case necessity
        }

        let kind: Kind
        let gene: AstroDNAGene?
        let stateRawValue: Int?
        let longitude: CelestialLongitude?

        init(_ value: TapestryPlacementValue) {
            switch value {
            case let .astroDNA(gene, state):
                kind = .astroDNA
                self.gene = gene
                stateRawValue = state.rawValue
                longitude = nil
            case let .fortune(value):
                kind = .fortune
                gene = nil
                stateRawValue = nil
                longitude = value
            case let .spirit(value):
                kind = .spirit
                gene = nil
                stateRawValue = nil
                longitude = value
            case let .eros(value):
                kind = .eros
                gene = nil
                stateRawValue = nil
                longitude = value
            case let .necessity(value):
                kind = .necessity
                gene = nil
                stateRawValue = nil
                longitude = value
            }
        }

        func restore(at address: DegreeAddress) throws -> TapestryPlacementValue {
            let value: TapestryPlacementValue
            switch kind {
            case .astroDNA:
                guard let gene, let stateRawValue, longitude == nil,
                      let state = RingFineState(stateRawValue) else {
                    throw HestiaPersistenceFailure.invalidTapestry
                }
                value = .astroDNA(gene: gene, state: state)
            case .fortune:
                guard gene == nil, stateRawValue == nil, let longitude else {
                    throw HestiaPersistenceFailure.invalidTapestry
                }
                value = .fortune(longitude)
            case .spirit:
                guard gene == nil, stateRawValue == nil, let longitude else {
                    throw HestiaPersistenceFailure.invalidTapestry
                }
                value = .spirit(longitude)
            case .eros:
                guard gene == nil, stateRawValue == nil, let longitude else {
                    throw HestiaPersistenceFailure.invalidTapestry
                }
                value = .eros(longitude)
            case .necessity:
                guard gene == nil, stateRawValue == nil, let longitude else {
                    throw HestiaPersistenceFailure.invalidTapestry
                }
                value = .necessity(longitude)
            }

            guard value.degreeAddress == address else {
                throw HestiaPersistenceFailure.invalidTapestry
            }
            return value
        }
    }

    struct RingValueRecord: Codable {
        let gene: AstroDNAGene
        let sourceRawValue: Int
        let mark: RingMark
        let targetArcsecond: Int

        init(_ value: TapestryRingValue) {
            gene = value.gene
            sourceRawValue = value.source.rawValue
            mark = value.mark
            targetArcsecond = value.targetArcsecond
        }

        func restore(at address: DegreeAddress) throws -> TapestryRingValue {
            guard let source = RingFineState(sourceRawValue),
                  targetArcsecond >= 0,
                  targetArcsecond < Ring.arcseconds else {
                throw HestiaPersistenceFailure.invalidTapestry
            }
            let value = TapestryRingValue(
                gene: gene,
                source: source,
                mark: mark,
                targetArcsecond: targetArcsecond
            )
            guard value.degreeAddress == address else {
                throw HestiaPersistenceFailure.invalidTapestry
            }
            return value
        }
    }

    struct ArcValueRecord: Codable {
        let subject: ArcSubject
        let cell: ArcCellRecord

        init(_ value: TapestryArcValue) {
            subject = value.subject
            cell = ArcCellRecord(value.cell)
        }

        func restore(at address: DegreeAddress) throws -> TapestryArcValue {
            TapestryArcValue(
                subject: subject,
                cell: try cell.restore(at: address)
            )
        }
    }

    struct ArcCellRecord: Codable {
        let degree: Int
        let coverage: ArcCoverageRecord
        let center: ArcPosition?
        let minusPole: ArcPosition?
        let plusPole: ArcPosition?

        init(_ cell: ArcDegreeCell) {
            degree = cell.degree
            coverage = ArcCoverageRecord(cell.coverage)
            center = cell.center
            minusPole = cell.minusPole
            plusPole = cell.plusPole
        }

        func restore(at address: DegreeAddress) throws -> ArcDegreeCell {
            guard degree == address.rawValue,
                  [center, minusPole, plusPole].compactMap({ $0 }).allSatisfy({ $0.degree == degree }) else {
                throw HestiaPersistenceFailure.invalidTapestry
            }

            return ArcDegreeCell(
                degree: degree,
                coverage: try coverage.restore(for: degree),
                center: center,
                minusPole: minusPole,
                plusPole: plusPole
            )
        }
    }

    struct ArcCoverageRecord: Codable {
        enum Kind: String, Codable {
            case impossible
            case possible
            case partial
        }

        let kind: Kind
        let lower: ArcPosition?
        let upper: ArcPosition?

        init(_ coverage: ArcDegreeCoverage) {
            switch coverage {
            case .impossible:
                kind = .impossible
                lower = nil
                upper = nil
            case .possible:
                kind = .possible
                lower = nil
                upper = nil
            case let .partial(range):
                kind = .partial
                lower = range.lower
                upper = range.upper
            }
        }

        func restore(for degree: Int) throws -> ArcDegreeCoverage {
            switch kind {
            case .impossible:
                guard lower == nil, upper == nil else {
                    throw HestiaPersistenceFailure.invalidTapestry
                }
                return .impossible
            case .possible:
                guard lower == nil, upper == nil else {
                    throw HestiaPersistenceFailure.invalidTapestry
                }
                return .possible
            case .partial:
                guard let lower, let upper,
                      lower.rawValue <= upper.rawValue,
                      lower.degree == degree,
                      upper.degree == degree else {
                    throw HestiaPersistenceFailure.invalidTapestry
                }
                return .partial(ArcTickRange(lower: lower, upper: upper))
            }
        }
    }

    struct QualifiedTemperRecord: Codable {
        let planet: Planet
        let longitude: CelestialLongitude
        let fieldTemper: FieldTemperRecord
        let sectDay: Bool
        let sectNight: Bool
        let traditionalDomicile: Bool
        let modernDomicile: Bool
        let traditionalDetriment: Bool
        let modernDetriment: Bool
        let exaltation: Bool
        let atExaltationDegree: Bool
        let triplicity: Bool
        let bound: Bool
        let face: Bool
        let fall: Bool
        let peregrineApplies: Bool
        let peregrine: Bool
        let mutualReception: Bool
        let boundRuler: Planet
        let faceRuler: Planet
        let triplicityDayRuler: Planet
        let triplicityNightRuler: Planet
        let triplicityParticipatingRuler: Planet
        let triplicityOperativeRuler: Planet?
        let mutualReceptionWith: [Planet]
        let mutualReceptionKinds: [Mater.MutualReceptionKind]

        init(_ value: Mater.QualifiedTemper) {
            planet = value.planet
            longitude = value.longitude
            fieldTemper = FieldTemperRecord(value.fieldTemper)
            sectDay = value.sectDay
            sectNight = value.sectNight
            traditionalDomicile = value.traditionalDomicile
            modernDomicile = value.modernDomicile
            traditionalDetriment = value.traditionalDetriment
            modernDetriment = value.modernDetriment
            exaltation = value.exaltation
            atExaltationDegree = value.atExaltationDegree
            triplicity = value.triplicity
            bound = value.bound
            face = value.face
            fall = value.fall
            peregrineApplies = value.peregrineApplies
            peregrine = value.peregrine
            mutualReception = value.mutualReception
            boundRuler = value.boundRuler
            faceRuler = value.faceRuler
            triplicityDayRuler = value.triplicityDayRuler
            triplicityNightRuler = value.triplicityNightRuler
            triplicityParticipatingRuler = value.triplicityParticipatingRuler
            triplicityOperativeRuler = value.triplicityOperativeRuler
            mutualReceptionWith = value.mutualReceptionWith
            mutualReceptionKinds = value.mutualReceptionKinds
        }

        func restore(at address: DegreeAddress) throws -> Mater.QualifiedTemper {
            guard Int(longitude.degrees.rounded(.down)) == address.rawValue else {
                throw HestiaPersistenceFailure.invalidTapestry
            }
            let restoredFieldTemper = try fieldTemper.restore()
            guard restoredFieldTemper.planet == planet,
                  restoredFieldTemper.temper.planet == planet,
                  restoredFieldTemper.temper.sign == longitude.sign else {
                throw HestiaPersistenceFailure.invalidTapestry
            }

            return Mater.QualifiedTemper(
                restoringPlanet: planet,
                longitude: longitude,
                fieldTemper: restoredFieldTemper,
                sectDay: sectDay,
                sectNight: sectNight,
                traditionalDomicile: traditionalDomicile,
                modernDomicile: modernDomicile,
                traditionalDetriment: traditionalDetriment,
                modernDetriment: modernDetriment,
                exaltation: exaltation,
                atExaltationDegree: atExaltationDegree,
                triplicity: triplicity,
                bound: bound,
                face: face,
                fall: fall,
                peregrineApplies: peregrineApplies,
                peregrine: peregrine,
                mutualReception: mutualReception,
                boundRuler: boundRuler,
                faceRuler: faceRuler,
                triplicityDayRuler: triplicityDayRuler,
                triplicityNightRuler: triplicityNightRuler,
                triplicityParticipatingRuler: triplicityParticipatingRuler,
                triplicityOperativeRuler: triplicityOperativeRuler,
                mutualReceptionWith: mutualReceptionWith,
                mutualReceptionKinds: mutualReceptionKinds
            )
        }
    }

    struct FieldTemperRecord: Codable {
        let planet: Planet
        let temper: TemperRecord
        let dispositorCapable: Bool
        let bearer: Planet
        let dispositorPath: [Planet]
        let keeperKind: Mater.DispositorTerminalKind
        let keeperID: String
        let terminalKind: Mater.DispositorTerminalKind
        let cycleMembership: DispositorCycleRecord?
        let mutualReception: Bool
        let mutualReceptionWith: [Planet]
        let mutualReceptionKinds: [Mater.MutualReceptionKind]
        let immediateDependents: [Planet]
        let transitiveDescendants: [Planet]

        init(_ value: Mater.FieldTemper) {
            planet = value.planet
            temper = TemperRecord(value.temper)
            dispositorCapable = value.dispositorCapable
            bearer = value.bearer
            dispositorPath = value.dispositorPath
            keeperKind = value.keeper.kind
            keeperID = value.keeper.id
            terminalKind = value.terminalKind
            cycleMembership = value.cycleMembership.map(DispositorCycleRecord.init)
            mutualReception = value.mutualReception
            mutualReceptionWith = value.mutualReceptionWith
            mutualReceptionKinds = value.mutualReceptionKinds
            immediateDependents = value.immediateDependents
            transitiveDescendants = value.transitiveDescendants
        }

        func restore() throws -> Mater.FieldTemper {
            let restoredTemper = temper.restore()
            guard restoredTemper.planet == planet else {
                throw HestiaPersistenceFailure.invalidTapestry
            }
            let keeper = Mater.DispositorKeeper(restoringKind: keeperKind, id: keeperID)
            let cycle = try cycleMembership?.restore()

            return Mater.FieldTemper(
                restoringPlanet: planet,
                temper: restoredTemper,
                dispositorCapable: dispositorCapable,
                bearer: bearer,
                dispositorPath: dispositorPath,
                keeper: keeper,
                terminalKind: terminalKind,
                cycleMembership: cycle,
                mutualReception: mutualReception,
                mutualReceptionWith: mutualReceptionWith,
                mutualReceptionKinds: mutualReceptionKinds,
                immediateDependents: immediateDependents,
                transitiveDescendants: transitiveDescendants
            )
        }
    }

    struct DispositorCycleRecord: Codable {
        let id: String
        let members: [Planet]
        let length: Int
        let kind: Mater.DispositorTerminalKind

        init(_ value: Mater.DispositorCycle) {
            id = value.id
            members = value.members
            length = value.length
            kind = value.kind
        }

        func restore() throws -> Mater.DispositorCycle {
            guard length == members.count else {
                throw HestiaPersistenceFailure.invalidTapestry
            }
            return Mater.DispositorCycle(
                restoringID: id,
                members: members,
                kind: kind
            )
        }
    }

    struct TemperRecord: Codable {
        let planet: Planet
        let sign: Sign
        let element: Element
        let modality: Modality
        let traditionalDomicile: Bool
        let traditionalDetriment: Bool
        let modernDomicile: Bool
        let modernDetriment: Bool
        let exaltation: Bool
        let fall: Bool
        let triplicityDay: Bool
        let triplicityNight: Bool

        init(_ value: Mater.Temper) {
            planet = value.planet
            sign = value.sign
            element = value.element
            modality = value.modality
            traditionalDomicile = value.traditionalRulership.domicile
            traditionalDetriment = value.traditionalRulership.detriment
            modernDomicile = value.modernRulership.domicile
            modernDetriment = value.modernRulership.detriment
            exaltation = value.exaltation
            fall = value.fall
            triplicityDay = value.triplicityDay
            triplicityNight = value.triplicityNight
        }

        func restore() -> Mater.Temper {
            Mater.Temper(
                restoringPlanet: planet,
                sign: sign,
                element: element,
                modality: modality,
                traditionalDomicile: traditionalDomicile,
                traditionalDetriment: traditionalDetriment,
                modernDomicile: modernDomicile,
                modernDetriment: modernDetriment,
                exaltation: exaltation,
                fall: fall,
                triplicityDay: triplicityDay,
                triplicityNight: triplicityNight
            )
        }
    }
}

// MARK: - Persistence-only restoration seams

private extension Engraving {
    init(
        restoringSubjectID subjectID: HermesSubjectID,
        name: String,
        birthDate: CivilDate,
        birthTime: CivilClockTime,
        birthLocation: String,
        topos: Topos?,
        tempus: Tempus?,
        astroDNA: AstroDNA?,
        tapestry: AtroposTapestryPackage?,
        engraved: Bool
    ) {
        self.subjectID = subjectID
        self.name = name
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.birthLocation = birthLocation
        self.topos = topos
        self.tempus = tempus
        self.astroDNA = astroDNA
        self.tapestry = tapestry
        self.engraved = engraved
    }
}

private extension AtroposTapestryPackage {
    init(restoringTapestry tapestry: Tapestry) {
        self.tapestry = tapestry
    }
}

private extension Mater.SignFlags {
    init(restoring sign: Sign) {
        aries = sign == .aries
        taurus = sign == .taurus
        gemini = sign == .gemini
        cancer = sign == .cancer
        leo = sign == .leo
        virgo = sign == .virgo
        libra = sign == .libra
        scorpio = sign == .scorpio
        sagittarius = sign == .sagittarius
        capricorn = sign == .capricorn
        aquarius = sign == .aquarius
        pisces = sign == .pisces
    }
}

private extension Mater.ElementFlags {
    init(restoring element: Element) {
        fire = element == .fire
        earth = element == .earth
        air = element == .air
        water = element == .water
    }
}

private extension Mater.ModalityFlags {
    init(restoring modality: Modality) {
        cardinal = modality == .cardinal
        fixed = modality == .fixed
        mutable = modality == .mutable
    }
}

private extension Mater.RulershipFlags {
    init(restoringDomicile domicile: Bool, detriment: Bool) {
        self.domicile = domicile
        self.detriment = detriment
    }
}

private extension Mater.Temper {
    init(
        restoringPlanet planet: Planet,
        sign: Sign,
        element: Element,
        modality: Modality,
        traditionalDomicile: Bool,
        traditionalDetriment: Bool,
        modernDomicile: Bool,
        modernDetriment: Bool,
        exaltation: Bool,
        fall: Bool,
        triplicityDay: Bool,
        triplicityNight: Bool
    ) {
        self.planet = planet
        self.sign = sign
        signFlags = Mater.SignFlags(restoring: sign)
        self.element = element
        elementFlags = Mater.ElementFlags(restoring: element)
        self.modality = modality
        modalityFlags = Mater.ModalityFlags(restoring: modality)
        traditionalRulership = Mater.RulershipFlags(
            restoringDomicile: traditionalDomicile,
            detriment: traditionalDetriment
        )
        modernRulership = Mater.RulershipFlags(
            restoringDomicile: modernDomicile,
            detriment: modernDetriment
        )
        self.exaltation = exaltation
        self.fall = fall
        self.triplicityDay = triplicityDay
        self.triplicityNight = triplicityNight
    }
}

private extension Mater.DispositorKeeper {
    init(restoringKind kind: Mater.DispositorTerminalKind, id: String) {
        self.kind = kind
        self.id = id
    }
}

private extension Mater.DispositorCycle {
    init(
        restoringID id: String,
        members: [Planet],
        kind: Mater.DispositorTerminalKind
    ) {
        self.id = id
        self.members = members
        length = members.count
        self.kind = kind
    }
}

private extension Mater.FieldTemper {
    init(
        restoringPlanet planet: Planet,
        temper: Mater.Temper,
        dispositorCapable: Bool,
        bearer: Planet,
        dispositorPath: [Planet],
        keeper: Mater.DispositorKeeper,
        terminalKind: Mater.DispositorTerminalKind,
        cycleMembership: Mater.DispositorCycle?,
        mutualReception: Bool,
        mutualReceptionWith: [Planet],
        mutualReceptionKinds: [Mater.MutualReceptionKind],
        immediateDependents: [Planet],
        transitiveDescendants: [Planet]
    ) {
        self.planet = planet
        self.temper = temper
        self.dispositorCapable = dispositorCapable
        self.bearer = bearer
        self.dispositorPath = dispositorPath
        self.keeper = keeper
        self.terminalKind = terminalKind
        self.cycleMembership = cycleMembership
        self.mutualReception = mutualReception
        self.mutualReceptionWith = mutualReceptionWith
        self.mutualReceptionKinds = mutualReceptionKinds
        self.immediateDependents = immediateDependents
        self.transitiveDescendants = transitiveDescendants
    }
}

private extension Mater.QualifiedTemper {
    init(
        restoringPlanet planet: Planet,
        longitude: CelestialLongitude,
        fieldTemper: Mater.FieldTemper,
        sectDay: Bool,
        sectNight: Bool,
        traditionalDomicile: Bool,
        modernDomicile: Bool,
        traditionalDetriment: Bool,
        modernDetriment: Bool,
        exaltation: Bool,
        atExaltationDegree: Bool,
        triplicity: Bool,
        bound: Bool,
        face: Bool,
        fall: Bool,
        peregrineApplies: Bool,
        peregrine: Bool,
        mutualReception: Bool,
        boundRuler: Planet,
        faceRuler: Planet,
        triplicityDayRuler: Planet,
        triplicityNightRuler: Planet,
        triplicityParticipatingRuler: Planet,
        triplicityOperativeRuler: Planet?,
        mutualReceptionWith: [Planet],
        mutualReceptionKinds: [Mater.MutualReceptionKind]
    ) {
        self.planet = planet
        self.longitude = longitude
        self.fieldTemper = fieldTemper
        self.sectDay = sectDay
        self.sectNight = sectNight
        self.traditionalDomicile = traditionalDomicile
        self.modernDomicile = modernDomicile
        self.traditionalDetriment = traditionalDetriment
        self.modernDetriment = modernDetriment
        self.exaltation = exaltation
        self.atExaltationDegree = atExaltationDegree
        self.triplicity = triplicity
        self.bound = bound
        self.face = face
        self.fall = fall
        self.peregrineApplies = peregrineApplies
        self.peregrine = peregrine
        self.mutualReception = mutualReception
        self.boundRuler = boundRuler
        self.faceRuler = faceRuler
        self.triplicityDayRuler = triplicityDayRuler
        self.triplicityNightRuler = triplicityNightRuler
        self.triplicityParticipatingRuler = triplicityParticipatingRuler
        self.triplicityOperativeRuler = triplicityOperativeRuler
        self.mutualReceptionWith = mutualReceptionWith
        self.mutualReceptionKinds = mutualReceptionKinds
    }
}
