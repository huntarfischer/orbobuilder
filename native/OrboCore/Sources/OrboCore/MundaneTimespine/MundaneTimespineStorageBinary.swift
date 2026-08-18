import Foundation

struct MundaneTimespineBinaryWriter {
    var data = Data()

    mutating func byte(_ value: UInt8) { data.append(value) }
    mutating func bytes(_ values: [UInt8]) { data.append(contentsOf: values) }

    mutating func u16(_ value: UInt16) {
        bytes([UInt8(value & 0xff), UInt8((value >> 8) & 0xff)])
    }

    mutating func u32(_ value: UInt32) {
        for shift in stride(from: 0, through: 24, by: 8) { byte(UInt8((value >> UInt32(shift)) & 0xff)) }
    }

    mutating func u64(_ value: UInt64) {
        for shift in stride(from: 0, through: 56, by: 8) { byte(UInt8((value >> UInt64(shift)) & 0xff)) }
    }

    mutating func f64(_ value: Double) { u64(value.bitPattern) }

    mutating func varUInt(_ value: UInt64) {
        var v = value
        repeat {
            var b = UInt8(v & 0x7f)
            v >>= 7
            if v != 0 { b |= 0x80 }
            byte(b)
        } while v != 0
    }

    mutating func varInt(_ value: Int64) {
        let bits = UInt64(bitPattern: value)
        let zigzag = (bits << 1) ^ UInt64(bitPattern: value >> 63)
        varUInt(zigzag)
    }

    mutating func string(_ value: String) {
        let utf8 = Array(value.utf8)
        varUInt(UInt64(utf8.count))
        bytes(utf8)
    }
}

struct MundaneTimespineBinaryReader {
    let data: Data
    var offset: Int = 0
    let end: Int

    init(data: Data) {
        self.data = data
        self.end = data.count
    }

    init(data: Data, range: Range<Int>) throws {
        guard range.lowerBound >= 0, range.upperBound <= data.count, range.lowerBound <= range.upperBound else {
            throw MundaneTimespineStorageError.truncated
        }
        self.data = data
        self.offset = range.lowerBound
        self.end = range.upperBound
    }

    mutating func byte() throws -> UInt8 {
        guard offset < end else { throw MundaneTimespineStorageError.truncated }
        defer { offset += 1 }
        return data[offset]
    }

    mutating func bytes(_ count: Int) throws -> [UInt8] {
        guard count >= 0, offset + count <= end else { throw MundaneTimespineStorageError.truncated }
        let result = Array(data[offset..<(offset + count)])
        offset += count
        return result
    }

    mutating func u16() throws -> UInt16 {
        UInt16(try byte()) | (UInt16(try byte()) << 8)
    }

    mutating func u32() throws -> UInt32 {
        var value: UInt32 = 0
        for shift in stride(from: 0, through: 24, by: 8) { value |= UInt32(try byte()) << UInt32(shift) }
        return value
    }

    mutating func u64() throws -> UInt64 {
        var value: UInt64 = 0
        for shift in stride(from: 0, through: 56, by: 8) { value |= UInt64(try byte()) << UInt64(shift) }
        return value
    }

    mutating func f64() throws -> Double { Double(bitPattern: try u64()) }

    mutating func varUInt() throws -> UInt64 {
        var value: UInt64 = 0
        var shift: UInt64 = 0
        for _ in 0..<10 {
            let b = try byte()
            let payload = UInt64(b & 0x7f)
            guard shift < 64, !(shift == 63 && payload > 1) else {
                throw MundaneTimespineStorageError.integerOverflow
            }
            value |= payload << shift
            if b & 0x80 == 0 { return value }
            shift += 7
        }
        throw MundaneTimespineStorageError.integerOverflow
    }

    mutating func varInt() throws -> Int64 {
        let raw = try varUInt()
        return Int64(raw >> 1) ^ -Int64(raw & 1)
    }

    mutating func string() throws -> String {
        let length = try int(try varUInt())
        let raw = try bytes(length)
        guard let value = String(bytes: raw, encoding: .utf8) else {
            throw MundaneTimespineStorageError.malformedArtifact
        }
        return value
    }

    func int(_ value: UInt64) throws -> Int {
        guard value <= UInt64(Int.max) else { throw MundaneTimespineStorageError.integerOverflow }
        return Int(value)
    }

    var isAtEnd: Bool { offset == end }
}

enum MundaneTimespineStorageSectionKind: UInt8 {
    case metadata = 1
    case body = 2
    case relationships = 3
    case eclipses = 4
}

struct MundaneTimespineStorageSection {
    let kind: MundaneTimespineStorageSectionKind
    let body: MundaneBody?
    let offset: Int
    let length: Int
    let recordCount: Int
}
