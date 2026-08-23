import Foundation

public enum HestiaPersistenceFailure: Error, Hashable, Sendable {
    case unsupportedCodec(Int)
    case invalidHouse
    case invalidTapestry
}

public enum HestiaPersistence {
    public static let codec = 1

    public static func encode(_ hestia: Hestia) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(Snapshot(hestia: hestia))
    }

    public static func decode(_ data: Data) throws -> Hestia {
        let snapshot = try JSONDecoder().decode(Snapshot.self, from: data)
        guard snapshot.codec == Self.codec else {
            throw HestiaPersistenceFailure.unsupportedCodec(snapshot.codec)
        }
        return try restore(snapshot)
    }

    public static func save(_ hestia: Hestia, to url: URL) throws {
        let data = try encode(hestia)
        try data.write(to: url, options: .atomic)
    }

    public static func load(from url: URL) throws -> Hestia {
        try decode(Data(contentsOf: url))
    }

    private static func restore(_ snapshot: Snapshot) throws -> Hestia {
        var hestia = Hestia(nativeSubjectID: snapshot.hearth.nativeSubjectID)

        do {
            for holding in snapshot.holdings {
                try hestia.hold(
                    subjectID: holding.subjectID,
                    astroDNA: holding.astroDNA
                )
            }

            if let resident = snapshot.hearth.resident {
                let tapestry = try resident.tapestry.restore()
                guard Hestia.tapestry(tapestry, matches: resident.astroDNA) else {
                    throw HestiaPersistenceFailure.invalidTapestry
                }
                try hestia.admit(
                    subjectID: snapshot.hearth.nativeSubjectID,
                    astroDNA: resident.astroDNA,
                    tapestry: tapestry
                )
            }

            for resident in snapshot.hall {
                guard resident.subjectID != snapshot.hearth.nativeSubjectID else {
                    throw HestiaPersistenceFailure.invalidHouse
                }

                let tapestry = try resident.tapestry.restore()
                guard Hestia.tapestry(tapestry, matches: resident.astroDNA) else {
                    throw HestiaPersistenceFailure.invalidTapestry
                }
                try hestia.admit(
                    subjectID: resident.subjectID,
                    astroDNA: resident.astroDNA,
                    tapestry: tapestry
                )
            }
        } catch let failure as HestiaPersistenceFailure {
            throw failure
        } catch {
            throw HestiaPersistenceFailure.invalidHouse
        }

        return hestia
    }
}

private extension HestiaPersistence {
    struct Snapshot: Codable {
        let codec: Int
        let holdings: [HoldingRecord]
        let hearth: HearthRecord
        let hall: [HallResidentRecord]

        init(hestia: Hestia) {
            codec = HestiaPersistence.codec
            holdings = hestia.holdings.holdings.map(HoldingRecord.init)
            hearth = HearthRecord(hestia.hearth)
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
        let resident: HearthResidentRecord?

        init(_ hearth: Hearth) {
            nativeSubjectID = hearth.nativeSubjectID
            resident = hearth.resident.map(HearthResidentRecord.init)
        }
    }

    struct HearthResidentRecord: Codable {
        let astroDNA: AstroDNA
        let tapestry: TapestryRecord

        init(_ resident: HearthResident) {
            astroDNA = resident.astroDNA
            tapestry = TapestryRecord(resident.tapestry)
        }
    }

    struct HallResidentRecord: Codable {
        let subjectID: HermesSubjectID
        let astroDNA: AstroDNA
        let tapestry: TapestryRecord

        init(_ resident: HallResident) {
            subjectID = resident.subjectID
            astroDNA = resident.astroDNA
            tapestry = TapestryRecord(resident.tapestry)
        }
    }

    struct TapestryRecord: Codable {
        let cells: [CellRecord]

        init(_ tapestry: AtroposPackage) {
            cells = tapestry.grid.cells.map(CellRecord.init)
        }

        func restore() throws -> AtroposPackage {
            guard cells.count == DegreeAddress.count else {
                throw HestiaPersistenceFailure.invalidTapestry
            }

            var restoredCells: [DegreeCell] = []
            restoredCells.reserveCapacity(DegreeAddress.count)

            for (index, cell) in cells.enumerated() {
                guard let address = DegreeAddress(rawValue: cell.address),
                      address == DegreeAddress.canonicalOrder[index] else {
                    throw HestiaPersistenceFailure.invalidTapestry
                }

                var restoredThreads: [ClothoThread] = []
                restoredThreads.reserveCapacity(cell.threads.count)

                for thread in cell.threads {
                    guard let exactState = RingFineState(thread.exactState),
                          let degreeAddress = DegreeAddress(rawValue: thread.degreeAddress),
                          degreeAddress == address,
                          exactState.coarseState.degree == degreeAddress.rawValue else {
                        throw HestiaPersistenceFailure.invalidTapestry
                    }

                    restoredThreads.append(
                        ClothoThread(
                            restoringGene: thread.gene,
                            exactState: exactState,
                            degreeAddress: degreeAddress
                        )
                    )
                }

                restoredCells.append(
                    DegreeCell(
                        restoringAddress: address,
                        threads: restoredThreads
                    )
                )
            }

            guard let grid = DegreeGrid(restoringCells: restoredCells) else {
                throw HestiaPersistenceFailure.invalidTapestry
            }

            return AtroposPackage(restoringGrid: grid)
        }
    }

    struct CellRecord: Codable {
        let address: Int
        let threads: [ThreadRecord]

        init(_ cell: DegreeCell) {
            address = cell.address.rawValue
            threads = cell.threads.map(ThreadRecord.init)
        }
    }

    struct ThreadRecord: Codable {
        let gene: AstroDNAGene
        let exactState: Int
        let degreeAddress: Int

        init(_ thread: ClothoThread) {
            gene = thread.gene
            exactState = thread.exactState.rawValue
            degreeAddress = thread.degreeAddress.rawValue
        }
    }
}
