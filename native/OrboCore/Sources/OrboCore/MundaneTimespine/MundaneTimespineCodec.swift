import Foundation

internal enum MundaneTimespineCodec {
    private static let bodyMagic: [UInt8] = Array("ORBTBD04".utf8)

    private struct Manifest: Codable {
        struct Profile: Codable {
            let body: String
            let edgeSampleDays: Double
            let coreSampleDays: Double
        }

        struct BodyArtifact: Codable {
            let body: String
            let file: String
            let bytes: Int
            let sha256: String
            let stationCount: Int
            let knotCount: Int
            let unpackedPositionBytes: Int
        }

        let version: String
        let codec: Int
        let astroDNACodec: Int
        let representation: String
        let astronomicalSource: String
        let astronomicalSourceVersion: String
        let supportedStartJulianDay: Double
        let denseStartJulianDay: Double
        let denseEndJulianDay: Double
        let supportedEndJulianDay: Double
        let positionUnitsPerDegree: Int
        let profiles: [Profile]
        let bodies: [BodyArtifact]
    }

    static func encode(_ timespine: MundaneTimespine) -> MundaneTimespineArtifactSet {
        var bodyArtifacts: [MundaneBody: Data] = [:]
        var bodyRecords: [Manifest.BodyArtifact] = []

        for body in MundaneBody.canonicalOrder {
            guard let series = timespine.seriesByBody[body] else { continue }
            let data = encodeBody(series)
            let knotCount = series.regions.reduce(0) { $0 + $1.samples.count }
            bodyArtifacts[body] = data
            bodyRecords.append(.init(
                body: body.displayName,
                file: body.artifactFileName,
                bytes: data.count,
                sha256: sha256Hex(data),
                stationCount: series.motionChronology.stations.count,
                knotCount: knotCount,
                unpackedPositionBytes: knotCount * MemoryLayout<UInt32>.size
            ))
        }

        let manifest = Manifest(
            version: timespine.metadata.version,
            codec: MundaneTimespine.codec,
            astroDNACodec: AstroDNA.codec,
            representation: MundaneTimespine.representation,
            astronomicalSource: timespine.metadata.astronomicalSource,
            astronomicalSourceVersion: timespine.metadata.astronomicalSourceVersion,
            supportedStartJulianDay: timespine.metadata.supportedStart.value,
            denseStartJulianDay: timespine.metadata.denseStart.value,
            denseEndJulianDay: timespine.metadata.denseEnd.value,
            supportedEndJulianDay: timespine.metadata.supportedEnd.value,
            positionUnitsPerDegree: MundaneTimespine.positionUnitsPerDegree,
            profiles: timespine.metadata.profiles.map {
                .init(
                    body: $0.body.displayName,
                    edgeSampleDays: $0.edgeSampleDays,
                    coreSampleDays: $0.coreSampleDays
                )
            },
            bodies: bodyRecords
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let manifestData = try! encoder.encode(manifest) + Data([0x0a])
        return MundaneTimespineArtifactSet(
            manifest: manifestData,
            bodyArtifacts: bodyArtifacts,
            manifestChecksum: sha256Hex(manifestData)
        )
    }

    static func decode(
        manifest manifestData: Data,
        bodyArtifacts: [MundaneBody: Data]
    ) throws -> MundaneTimespine {
        let manifest: Manifest
        do {
            manifest = try JSONDecoder().decode(Manifest.self, from: manifestData)
        } catch {
            throw MundaneTimespineError.invalidManifest
        }

        guard manifest.codec == MundaneTimespine.codec,
              manifest.astroDNACodec == AstroDNA.codec,
              manifest.representation == MundaneTimespine.representation,
              manifest.positionUnitsPerDegree == MundaneTimespine.positionUnitsPerDegree,
              manifest.profiles.count == MundaneBody.canonicalOrder.count,
              manifest.bodies.count == MundaneBody.canonicalOrder.count,
              let supportedStart = JulianDay(manifest.supportedStartJulianDay),
              let denseStart = JulianDay(manifest.denseStartJulianDay),
              let denseEnd = JulianDay(manifest.denseEndJulianDay),
              let supportedEnd = JulianDay(manifest.supportedEndJulianDay) else {
            throw MundaneTimespineError.invalidManifest
        }

        var profiles: [MundaneTimespineProfile] = []
        var seriesByBody: [MundaneBody: MundaneTimespineSeries] = [:]

        for (index, body) in MundaneBody.canonicalOrder.enumerated() {
            let profileRecord = manifest.profiles[index]
            let bodyRecord = manifest.bodies[index]
            guard profileRecord.body == body.displayName,
                  bodyRecord.body == body.displayName,
                  bodyRecord.file == body.artifactFileName,
                  let profile = MundaneTimespineProfile(
                    body: body,
                    edgeSampleDays: profileRecord.edgeSampleDays,
                    coreSampleDays: profileRecord.coreSampleDays
                  ),
                  let data = bodyArtifacts[body],
                  data.count == bodyRecord.bytes else {
                throw MundaneTimespineError.invalidManifest
            }

            guard sha256Hex(data) == bodyRecord.sha256 else {
                throw MundaneTimespineError.checksumMismatch(body)
            }

            let series = try decodeBody(data, expectedBody: body, profile: profile)
            let knotCount = series.regions.reduce(0) { $0 + $1.samples.count }
            guard series.motionChronology.stations.count == bodyRecord.stationCount,
                  knotCount == bodyRecord.knotCount,
                  knotCount * MemoryLayout<UInt32>.size == bodyRecord.unpackedPositionBytes else {
                throw MundaneTimespineError.invalidManifest
            }

            profiles.append(profile)
            seriesByBody[body] = series
        }

        let metadata = MundaneTimespineMetadata(
            version: manifest.version,
            codec: manifest.codec,
            astroDNACodec: manifest.astroDNACodec,
            astronomicalSource: manifest.astronomicalSource,
            astronomicalSourceVersion: manifest.astronomicalSourceVersion,
            supportedStart: supportedStart,
            denseStart: denseStart,
            denseEnd: denseEnd,
            supportedEnd: supportedEnd,
            positionUnitsPerDegree: manifest.positionUnitsPerDegree,
            profiles: profiles
        )
        return try MundaneTimespine(metadata: metadata, seriesByBody: seriesByBody)
    }

    private static func encodeBody(_ series: MundaneTimespineSeries) -> Data {
        var writer = Writer()
        writer.append(bytes: bodyMagic)
        writer.append(UInt16(MundaneTimespine.codec))
        writer.append(series.profile.body.rawValue)
        writer.append(UInt8(series.regions.count))
        writer.append(UInt32(MundaneTimespine.positionUnitsPerDegree))
        writer.append(motionByte(series.motionChronology.initialMotion))
        writer.append(UInt32(series.motionChronology.stations.count))

        for station in series.motionChronology.stations {
            writer.append(station.julianDay.value)
            writer.append(motionByte(station.motionAfter))
        }

        for region in series.regions {
            writer.append(region.startJulianDay)
            writer.append(region.endJulianDay)
            writer.append(region.sampleDays)
            writer.append(UInt32(region.samples.count))
            appendPackedSamples(region.samples, to: &writer)
        }
        return writer.data
    }

    private static func decodeBody(
        _ data: Data,
        expectedBody: MundaneBody,
        profile: MundaneTimespineProfile
    ) throws -> MundaneTimespineSeries {
        var reader = Reader(data: data)
        guard try reader.readBytes(count: bodyMagic.count) == bodyMagic else {
            throw MundaneTimespineError.invalidArtifactMagic
        }

        let codec = Int(try reader.readUInt16())
        guard codec == MundaneTimespine.codec else {
            throw MundaneTimespineError.unsupportedCodec(codec)
        }

        guard let body = MundaneBody(rawValue: try reader.readUInt8()),
              body == expectedBody else {
            throw MundaneTimespineError.invalidManifest
        }

        let regionCount = Int(try reader.readUInt8())
        guard regionCount == 3,
              Int(try reader.readUInt32()) == MundaneTimespine.positionUnitsPerDegree,
              let initialMotion = motion(from: try reader.readUInt8()) else {
            throw MundaneTimespineError.invalidManifest
        }

        let stationCount = Int(try reader.readUInt32())
        guard stationCount <= reader.remainingBytes / 9 else {
            throw MundaneTimespineError.truncatedArtifact
        }

        var stations: [MundaneStation] = []
        stations.reserveCapacity(stationCount)
        for _ in 0..<stationCount {
            guard let julianDay = JulianDay(try reader.readDouble()),
                  let motionAfter = motion(from: try reader.readUInt8()) else {
                throw MundaneTimespineError.invalidManifest
            }
            stations.append(.init(julianDay: julianDay, motionAfter: motionAfter))
        }

        guard let motionChronology = MundaneMotionChronology(
            initialMotion: initialMotion,
            stations: stations
        ) else {
            throw MundaneTimespineError.invalidManifest
        }

        var regions: [MundaneTimespineRegion] = []
        regions.reserveCapacity(regionCount)
        for _ in 0..<regionCount {
            let start = try reader.readDouble()
            let end = try reader.readDouble()
            let sampleDays = try reader.readDouble()
            let sampleCount = Int(try reader.readUInt32())
            guard start < end, sampleDays > 0, sampleCount >= 2 else {
                throw MundaneTimespineError.invalidManifest
            }
            let samples = try readPackedSamples(count: sampleCount, from: &reader)
            regions.append(.init(
                startJulianDay: start,
                endJulianDay: end,
                sampleDays: sampleDays,
                samples: samples
            ))
        }

        guard reader.remainingBytes == 0 else {
            throw MundaneTimespineError.invalidManifest
        }
        return .init(
            profile: profile,
            motionChronology: motionChronology,
            regions: regions
        )
    }

    private static func appendPackedSamples(
        _ samples: [MundaneTimespineSample],
        to writer: inout Writer
    ) {
        precondition(samples.count >= 2)
        let circleUnits = Int64(360 * MundaneTimespine.positionUnitsPerDegree)
        writer.append(samples[0].positionUnits)

        var previousPosition = samples[0].positionUnits
        var previousDelta = circularDelta(
            from: previousPosition,
            to: samples[1].positionUnits,
            circleUnits: circleUnits
        )
        writer.appendSignedVarInt(previousDelta)
        previousPosition = samples[1].positionUnits

        if samples.count > 2 {
            for sample in samples.dropFirst(2) {
                let delta = circularDelta(
                    from: previousPosition,
                    to: sample.positionUnits,
                    circleUnits: circleUnits
                )
                writer.appendSignedVarInt(delta - previousDelta)
                previousDelta = delta
                previousPosition = sample.positionUnits
            }
        }
    }

    private static func readPackedSamples(
        count: Int,
        from reader: inout Reader
    ) throws -> [MundaneTimespineSample] {
        guard count >= 2 else { throw MundaneTimespineError.invalidManifest }
        let circleUnits = Int64(360 * MundaneTimespine.positionUnitsPerDegree)
        let first = try reader.readUInt32()
        guard Int64(first) < circleUnits else {
            throw MundaneTimespineError.invalidManifest
        }

        var samples = [MundaneTimespineSample(positionUnits: first)]
        samples.reserveCapacity(count)

        var previousPosition = first
        var previousDelta = try reader.readSignedVarInt()
        let second = try applyingCircularDelta(
            previousDelta,
            to: previousPosition,
            circleUnits: circleUnits
        )
        samples.append(.init(positionUnits: second))
        previousPosition = second

        if count > 2 {
            for _ in 2..<count {
                let secondDelta = try reader.readSignedVarInt()
                let (delta, overflow) = previousDelta.addingReportingOverflow(secondDelta)
                guard !overflow else { throw MundaneTimespineError.invalidManifest }
                let position = try applyingCircularDelta(
                    delta,
                    to: previousPosition,
                    circleUnits: circleUnits
                )
                samples.append(.init(positionUnits: position))
                previousDelta = delta
                previousPosition = position
            }
        }
        return samples
    }

    private static func circularDelta(
        from previous: UInt32,
        to current: UInt32,
        circleUnits: Int64
    ) -> Int64 {
        var delta = Int64(current) - Int64(previous)
        let halfCircle = circleUnits / 2
        if delta > halfCircle {
            delta -= circleUnits
        } else if delta < -halfCircle {
            delta += circleUnits
        }
        return delta
    }

    private static func applyingCircularDelta(
        _ delta: Int64,
        to previous: UInt32,
        circleUnits: Int64
    ) throws -> UInt32 {
        let (sum, overflow) = Int64(previous).addingReportingOverflow(delta)
        guard !overflow else { throw MundaneTimespineError.invalidManifest }
        var position = sum % circleUnits
        if position < 0 { position += circleUnits }
        guard position >= 0, position <= Int64(UInt32.max) else {
            throw MundaneTimespineError.invalidManifest
        }
        return UInt32(position)
    }

    private static func motionByte(_ motion: Motion) -> UInt8 {
        motion == .direct ? 0 : 1
    }

    private static func motion(from byte: UInt8) -> Motion? {
        switch byte {
        case 0: return .direct
        case 1: return .retrograde
        default: return nil
        }
    }

    static func sha256Hex(_ data: Data) -> String {
        sha256(Array(data)).map { String(format: "%02x", $0) }.joined()
    }

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
        while message.count % 64 != 56 { message.append(0) }
        for shift in stride(from: 56, through: 0, by: -8) {
            message.append(UInt8((bitLength >> UInt64(shift)) & 0xff))
        }

        var h: [UInt32] = [
            0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
            0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
        ]

        for chunk in stride(from: 0, to: message.count, by: 64) {
            var w = [UInt32](repeating: 0, count: 64)
            for i in 0..<16 {
                let j = chunk + i * 4
                w[i] = UInt32(message[j]) << 24 |
                    UInt32(message[j + 1]) << 16 |
                    UInt32(message[j + 2]) << 8 |
                    UInt32(message[j + 3])
            }
            for i in 16..<64 {
                let s0 = rotateRight(w[i - 15], 7) ^ rotateRight(w[i - 15], 18) ^ (w[i - 15] >> 3)
                let s1 = rotateRight(w[i - 2], 17) ^ rotateRight(w[i - 2], 19) ^ (w[i - 2] >> 10)
                w[i] = w[i - 16] &+ s0 &+ w[i - 7] &+ s1
            }

            var a = h[0]
            var b = h[1]
            var c = h[2]
            var d = h[3]
            var e = h[4]
            var f = h[5]
            var g = h[6]
            var hh = h[7]

            for i in 0..<64 {
                let s1 = rotateRight(e, 6) ^ rotateRight(e, 11) ^ rotateRight(e, 25)
                let choice = (e & f) ^ ((~e) & g)
                let temp1 = hh &+ s1 &+ choice &+ k[i] &+ w[i]
                let s0 = rotateRight(a, 2) ^ rotateRight(a, 13) ^ rotateRight(a, 22)
                let majority = (a & b) ^ (a & c) ^ (b & c)
                let temp2 = s0 &+ majority
                hh = g
                g = f
                f = e
                e = d &+ temp1
                d = c
                c = b
                b = a
                a = temp1 &+ temp2
            }

            h[0] &+= a
            h[1] &+= b
            h[2] &+= c
            h[3] &+= d
            h[4] &+= e
            h[5] &+= f
            h[6] &+= g
            h[7] &+= hh
        }

        var output: [UInt8] = []
        output.reserveCapacity(32)
        for value in h {
            output += [
                UInt8((value >> 24) & 0xff),
                UInt8((value >> 16) & 0xff),
                UInt8((value >> 8) & 0xff),
                UInt8(value & 0xff),
            ]
        }
        return output
    }

    private static func rotateRight(_ value: UInt32, _ amount: UInt32) -> UInt32 {
        (value >> amount) | (value << (32 - amount))
    }

    private struct Writer {
        var data = Data()

        mutating func append(bytes: [UInt8]) { data.append(contentsOf: bytes) }
        mutating func append(_ value: UInt8) { data.append(value) }
        mutating func append(_ value: UInt16) { appendLittleEndian(value) }
        mutating func append(_ value: UInt32) { appendLittleEndian(value) }
        mutating func append(_ value: Double) { appendLittleEndian(value.bitPattern) }

        mutating func appendSignedVarInt(_ value: Int64) {
            let bits = UInt64(bitPattern: value)
            appendVarUInt((bits << 1) ^ UInt64(bitPattern: value >> 63))
        }

        private mutating func appendVarUInt(_ value: UInt64) {
            var remaining = value
            while remaining >= 0x80 {
                data.append(UInt8(remaining & 0x7f) | 0x80)
                remaining >>= 7
            }
            data.append(UInt8(remaining))
        }

        private mutating func appendLittleEndian<T: FixedWidthInteger>(_ value: T) {
            var little = value.littleEndian
            Swift.withUnsafeBytes(of: &little) { data.append(contentsOf: $0) }
        }
    }

    private struct Reader {
        let bytes: [UInt8]
        var index = 0

        init(data: Data) { bytes = Array(data) }
        var remainingBytes: Int { bytes.count - index }

        mutating func readBytes(count: Int) throws -> [UInt8] {
            guard count >= 0, remainingBytes >= count else {
                throw MundaneTimespineError.truncatedArtifact
            }
            defer { index += count }
            return Array(bytes[index..<(index + count)])
        }

        mutating func readUInt8() throws -> UInt8 {
            guard remainingBytes >= 1 else { throw MundaneTimespineError.truncatedArtifact }
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

        mutating func readDouble() throws -> Double {
            Double(bitPattern: try readUInt64())
        }

        mutating func readSignedVarInt() throws -> Int64 {
            let raw = try readVarUInt()
            let magnitude = Int64(raw >> 1)
            return magnitude ^ -Int64(raw & 1)
        }

        private mutating func readVarUInt() throws -> UInt64 {
            var value: UInt64 = 0
            var shift: UInt64 = 0
            for _ in 0..<10 {
                let byte = try readUInt8()
                let payload = UInt64(byte & 0x7f)
                if shift == 63, payload > 1 {
                    throw MundaneTimespineError.invalidManifest
                }
                value |= payload << shift
                if byte & 0x80 == 0 { return value }
                shift += 7
            }
            throw MundaneTimespineError.invalidManifest
        }
    }
}
