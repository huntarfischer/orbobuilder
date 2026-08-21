import Foundation
import XCTest
@testable import OrboCore

final class LoomStage0Tests: XCTestCase {
    func testFieldAddressAcceptsOnlyCanonicalGrid() {
        XCTAssertNil(FieldAddress(rawValue: -1))
        XCTAssertNotNil(FieldAddress(rawValue: 0))
        XCTAssertNotNil(FieldAddress(rawValue: 359))
        XCTAssertNil(FieldAddress(rawValue: 360))
    }

    func testCanonicalGridIsExactlyZeroThrough359() {
        let addresses = FieldAddress.canonicalOrder
        XCTAssertEqual(addresses.count, 360)
        XCTAssertEqual(addresses.map(\.rawValue), Array(0..<360))
        XCTAssertEqual(Set(addresses).count, 360)
    }

    func testLoomContainsExactlyOneCellAtEveryFieldAddress() {
        let loom = Loom()
        XCTAssertEqual(loom.constructionState, .construction)
        XCTAssertEqual(loom.cells.count, 360)
        XCTAssertEqual(loom.cells.map(\.address), FieldAddress.canonicalOrder)
        XCTAssertEqual(Set(loom.cells.map(\.address)).count, 360)
    }

    func testCellPersistsOnlyItsAddressAtStageZero() throws {
        let loom = Loom()
        let data = try loom.encoded()
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let cells = try XCTUnwrap(object["cells"] as? [[String: Any]])
        XCTAssertEqual(Set(cells[127].keys), Set(["address"]))
        XCTAssertEqual(cells[127]["address"] as? Int, 127)
    }

    func testEncodeDestroyDecodePreservesExactLoom() throws {
        let original = Loom()
        let data = try original.encoded()
        let decoded = try Loom.decode(data)
        XCTAssertEqual(decoded, original)
        XCTAssertEqual(try decoded.encoded(), data)
    }

    func testSameLoomAlwaysEncodesToSameBytes() throws {
        XCTAssertEqual(try Loom().encoded(), try Loom().encoded())
    }

    func testDecodeRejectsMissingOrDuplicateCells() throws {
        let data = try Loom().encoded()
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        var cells = try XCTUnwrap(object["cells"] as? [[String: Any]])

        cells.removeLast()
        object["cells"] = cells
        let missing = try JSONSerialization.data(withJSONObject: object)
        XCTAssertThrowsError(try Loom.decode(missing)) {
            XCTAssertEqual($0 as? LoomError, .invalidGrid)
        }

        cells = try XCTUnwrap((JSONSerialization.jsonObject(with: data) as? [String: Any])?["cells"] as? [[String: Any]])
        cells[359] = cells[358]
        object["cells"] = cells
        let duplicate = try JSONSerialization.data(withJSONObject: object)
        XCTAssertThrowsError(try Loom.decode(duplicate)) {
            XCTAssertEqual($0 as? LoomError, .invalidGrid)
        }
    }

    func testDecodeRejectsOutOfRangeAddressAndWrongCodec() throws {
        let data = try Loom().encoded()
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        var cells = try XCTUnwrap(object["cells"] as? [[String: Any]])
        cells[359]["address"] = 360
        object["cells"] = cells
        let badAddress = try JSONSerialization.data(withJSONObject: object)
        XCTAssertThrowsError(try Loom.decode(badAddress))

        object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        object["codec"] = Loom.codec + 1
        let badCodec = try JSONSerialization.data(withJSONObject: object)
        XCTAssertThrowsError(try Loom.decode(badCodec)) {
            XCTAssertEqual($0 as? LoomError, .unsupportedCodec(Loom.codec + 1))
        }
    }
}
