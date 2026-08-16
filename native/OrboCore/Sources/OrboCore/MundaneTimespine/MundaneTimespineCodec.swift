import Foundation

internal enum MundaneTimespineCodec {
    private static let magic: [UInt8] = Array("ORBTSP01".utf8)

    static func encode(_ timespine: MundaneTimespine) -> Data {
        var writer = Writer()
        writer.append(bytes: magic)
        writer.append(UInt16(MundaneTimespine.codec))
        writer.append(string: timespine.metadata.version)
        writer.append(UInt16(timespine.metadata.astroDNACodec))
        writer.append(string: timespine.metadata.astronomicalSource)
        writer.append(string: timespine.metadata.astronomicalSourceVersion)
        writer.append(timespine.metadata.supportedStart.value)
        writer.append(timespine.metadata.supportedEnd.value)
        writer.append(UInt32(timespine.metadata.coefficientScale))
        writer.append(UInt8(MundaneBody.canonicalOrder.count))

        for body in MundaneBody.canonicalOrder {
            guard let series = timespine.seriesByBody[body] else { continue }
            writer.append(body.rawValue)
            writer.append(UInt8(series.profile.polynomialDegree))
            writer.append(series.profile.segmentDays)
            writer.append(UInt32(series.segmentCount))
            for coefficient in series.coefficients {
                writer.append(coefficient)
            }
        }
        return writer.data
    }

    static func decode(_ data: Data) throws -> MundaneTimespine {
        var reader = Reader(data: data)
        guard try reader.readBytes(count: magic.count) == magic else {
            throw MundaneTimespineError.invalidArtifactMagic
        }

        let codec = Int(try reader.readUInt16())
        guard codec == MundaneTimespine.codec else {
            throw MundaneTimespineError.unsupportedCodec(codec)
        }

        let version = try reader.readString()
        let astroDNACodec = Int(try reader.readUInt16())
        let source = try reader.readString()
        let sourceVersion = try reader.readString()
        guard let supportedStart = JulianDay(try reader.readDouble()),
              let supportedEnd = JulianDay(try reader.readDouble()) else {
            throw MundaneTimespineError.malformedMetadata
        }
        let coefficientScale = Int(try reader.readUInt32())
        let bodyCount = Int(try reader.readUInt8())
        guard bodyCount == MundaneBody.canonicalOrder.count else {
            throw MundaneTimespineError.malformedMetadata
        }

        var profiles: [MundaneTimespineProfile] = []
        var seriesByBody: [MundaneBody: MundaneTimespineSeries] = [:]
        profiles.reserveCapacity(bodyCount)

        for expectedBody in MundaneBody.canonicalOrder {
            let rawBody = try reader.readUInt8()
            guard let body = MundaneBody(rawValue: rawBody), body == expectedBody else {
                throw MundaneTimespineError.malformedMetadata
            }
            let degree = Int(try reader.readUInt8())
            let segmentDays = try reader.readDouble()
            let segmentCount = Int(try reader.readUInt32())
            guard let profile = MundaneTimespineProfile(
                body: body,
                polynomialDegree: degree,
                segmentDays: segmentDays
            ), segmentCount > 0 else {
                throw MundaneTimespineError.malformedSeries(body)
            }

            let coefficientCount = segmentCount.multipliedReportingOverflow(by: degree + 1)
            guard !coefficientCount.overflow,
                  coefficientCount.partialValue <= reader.remainingBytes / MemoryLayout<Int32>.size else {
                throw MundaneTimespineError.truncatedArtifact
            }

            var coefficients: [Int32] = []
            coefficients.reserveCapacity(coefficientCount.partialValue)
            for _ in 0..<coefficientCount.partialValue {
                coefficients.append(try reader.readInt32())
            }

            profiles.append(profile)
            seriesByBody[body] = MundaneTimespineSeries(
                profile: profile,
                startJulianDay: supportedStart.value,
                segmentCount: segmentCount,
                coefficients: coefficients
            )
        }

        guard reader.remainingBytes == 0 else {
            throw MundaneTimespineError.malformedMetadata
        }

        let metadata = MundaneTimespineMetadata(
            version: version,
            codec: codec,
            astroDNACodec: astroDNACodec,
            astronomicalSource: source,
            astronomicalSourceVersion: sourceVersion,
            supportedStart: supportedStart,
            supportedEnd: supportedEnd,
            coefficientScale: coefficientScale,
            profiles: profiles
        )
        return try MundaneTimespine(metadata: metadata, seriesByBody: seriesByBody)
    }

    static func sha256Hex(_ data: Data) -> String {
        sha256(Array(data)).map { String(format: "%02x", $0) }.joined()
    }

    // Small self-contained SHA-256 implementation so artifact identity does not depend on
    // CryptoKit availability or UI/platform frameworks.
    private static func sha256(_ input: [UInt8]) -> [UInt8] {
        let k: [UInt32] = [
            0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
            0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
            0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
            0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
            0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
            0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
            0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
            0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
            0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
            0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
            0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
            0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
            0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
            0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
            0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
            0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
        ]

        var message = input
        let bitLength = UInt64(message.count) * 8
        message.append(0x80)
        while message.count % 64 != 56 {
            message.append(0)
        }
        for shift in stride(from: 56, through: 0, by: -8) {
            message.append(UInt8((bitLength >> UInt64(shift)) & 0xff))
        }

        var h0: UInt32 = 0x6a09e667
        var h1: UInt32 = 0xbb67ae85
        var h2: UInt32 = 0x3c6ef372
        var h3: UInt32 = 0xa54ff53a
        var h4: UInt32 = 0x510e527f
        var h5: UInt32 = 0x9b05688c
        var h6: UInt32 = 0x1f83d9ab
        var h7: UInt32 = 0x5be0cd19

        for chunkStart in stride(from: 0, to: message.count, by: 64) {
            var w = [UInt32](repeating: 0, count: 64)
            for i in 0..<16 {
                let j = chunkStart + i * 4
                w[i] = UInt32(message[j]) << 24 |
                    UInt32(message[j + 1]) << 16 |
                    UInt32(message[j + 2]) << 8 |
                    UInt32(message[j + 3])
            }
            for i in 16..<64 {
                let s0 = rotateRight(w[i - 15], by: 7) ^ rotateRight(w[i - 15], by: 18) ^ (w[i - 15] >> 3)
                let s1 = rotateRight(w[i - 2], by: 17) ^ rotateRight(w[i - 2], by: 19) ^ (w[i - 2] >> 10)
                w[i] = w[i - 16] &+ s0 &+ w[i - 7] &+ s1
            }

            var a = h0
            var b = h1
            var c = h2
            var d = h3
            var e = h4
            var f = h5
            var g = h6
            var h = h7

            for i in 0..<64 {
                let s1 = rotateRight(e, by: 6) ^ rotateRight(e, by: 11) ^ rotateRight(e, by: 25)
                let choice = (e & f) ^ ((~e) & g)
                let temp1 = h &+ s1 &+ choice &+ k[i] &+ w[i]
                let s0 = rotateRight(a, by: 2) ^ rotateRight(a, by: 13) ^ rotateRight(a, by: 22)
                let majority = (a & b) ^ (a & c) ^ (b & c)
                let temp2 = s0 &+ majority

                h = g
                g = f
                f = e
                e = d &+ temp1
                d = c
                c = b
                b = a
                a = temp1 &+ temp2
            }

            h0 = h0 &+ a
            h1 = h1 &+ b
            h2 = h2 &+ c
            h3 = h3 &+ d
            h4 = h4 &+ e
            h5 = h5 &+ f
            h6 = h6 &+ g
            h7 = h7 &+ h
        }

        var digest: [UInt8] = []
        digest.reserveCapacity(32)
        for value in [h0, h1, h2, h3, h4, h5, h6, h7] {
            digest.append(UInt8((value >> 24) & 0xff))
            digest.append(UInt8((value >> 16) & 0xff))
            digest.append(UInt8((value >> 8) & 0xff))
            digest.append(UInt8(value & 0xff))
        }
        return digest
    }

    private static func rotateRight(_ value: UInt32, by amount: UInt32) -> UInt32 {
        (value >> amount) | (value << (32 - amount))
    }

    private struct Writer {
        var data = Data()

        mutating func append(bytes: [UInt8]) {
            data.append(contentsOf: bytes)
        }

        mutating func append(_ value: UInt8) {
            data.append(value)
        }

        mutating func append(_ value: UInt16) {
            appendLittleEndian(value)
        }

        mutating func append(_ value: UInt32) {
            appendLittleEndian(value)
        }

        mutating func append(_ value: Int32) {
            appendLittleEndian(UInt32(bitPattern: value))
        }

        mutating func append(_ value: Double) {
            appendLittleEndian(value.bitPattern)
        }

        mutating func append(string: String) {
            let bytes = Array(string.utf8)
            precondition(bytes.count <= Int(UInt16.max))
            append(UInt16(bytes.count))
            append(bytes: bytes)
        }

        private mutating func appendLittleEndian<T: FixedWidthInteger>(_ value: T) {
            var little = value.littleEndian
            Swift.withUnsafeBytes(of: &little) { raw in
                data.append(contentsOf: raw)
            }
        }
    }

    private struct Reader {
        let bytes: [UInt8]
        var index = 0

        init(data: Data) {
            bytes = Array(data)
        }

        var remainingBytes: Int {
            bytes.count - index
        }

        mutating func readBytes(count: Int) throws -> [UInt8] {
            guard count >= 0, remainingBytes >= count else {
                throw MundaneTimespineError.truncatedArtifact
            }
            defer { index += count }
            return Array(bytes[index..<(index + count)])
        }

        mutating func readUInt8() throws -> UInt8 {
            guard remainingBytes >= 1 else {
                throw MundaneTimespineError.truncatedArtifact
            }
            defer { index += 1 }
            return bytes[index]
        }

        mutating func readUInt16() throws -> UInt16 {
            let raw = try readBytes(count: 2)
            return UInt16(raw[0]) | UInt16(raw[1]) << 8
        }

        mutating func readUInt32() throws -> UInt32 {
            let raw = try readBytes(count: 4)
            return UInt32(raw[0]) |
                UInt32(raw[1]) << 8 |
                UInt32(raw[2]) << 16 |
                UInt32(raw[3]) << 24
        }

        mutating func readUInt64() throws -> UInt64 {
            let raw = try readBytes(count: 8)
            var value: UInt64 = 0
            for offset in 0..<8 {
                value |= UInt64(raw[offset]) << UInt64(offset * 8)
            }
            return value
        }

        mutating func readInt32() throws -> Int32 {
            Int32(bitPattern: try readUInt32())
        }

        mutating func readDouble() throws -> Double {
            Double(bitPattern: try readUInt64())
        }

        mutating func readString() throws -> String {
            let length = Int(try readUInt16())
            let raw = try readBytes(count: length)
            guard let string = String(bytes: raw, encoding: .utf8) else {
                throw MundaneTimespineError.invalidUTF8
            }
            return string
        }
    }
}
