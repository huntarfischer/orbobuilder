import XCTest
@testable import OrboCore

final class OrboSpineLibraryTests: XCTestCase {
    func testLibraryIsPortIIAndCatalogsExactlyTheForgedCoreStructures() {
        let library = OrboSpineLibraryCatalog()

        XCTAssertEqual(OrboSpineLibraryCatalog.port, .library)
        XCTAssertEqual(library.coreShelves, [
            .retrogradePassages,
            .stations,
            .ringChronology,
            .eclipses,
            .frame,
            .revolt,
            .wave,
            .zeitgeist,
        ])
        XCTAssertEqual(Set(library.coreShelves), Set(OrboSpineLibraryShelf.allCases))
    }

    func testLibraryShelfNamesAreStableCatalogAddressesNotConsumerNames() {
        XCTAssertEqual(OrboSpineLibraryShelf.retrogradePassages.rawValue, "retrograde-passages")
        XCTAssertEqual(OrboSpineLibraryShelf.stations.rawValue, "stations")
        XCTAssertEqual(OrboSpineLibraryShelf.ringChronology.rawValue, "ring-chronology")
        XCTAssertEqual(OrboSpineLibraryShelf.eclipses.rawValue, "eclipses")
        XCTAssertEqual(OrboSpineLibraryShelf.frame.rawValue, "frame")
        XCTAssertEqual(OrboSpineLibraryShelf.revolt.rawValue, "revolt")
        XCTAssertEqual(OrboSpineLibraryShelf.wave.rawValue, "wave")
        XCTAssertEqual(OrboSpineLibraryShelf.zeitgeist.rawValue, "zeitgeist")

        let names = OrboSpineLibraryShelf.allCases.map(\.rawValue).joined(separator: " ")
        XCTAssertFalse(names.localizedCaseInsensitiveContains("chronos"))
        XCTAssertFalse(names.localizedCaseInsensitiveContains("horae"))
        XCTAssertFalse(names.localizedCaseInsensitiveContains("clotho"))
    }

    func testD2LeavesStackSmeldSeamEmpty() {
        let library = OrboSpineLibraryCatalog()

        XCTAssertNil(library.stackSmeld)
        for shelf in OrboSpineLibraryShelf.allCases {
            XCTAssertTrue(library.contains(shelf))
        }
    }
}
