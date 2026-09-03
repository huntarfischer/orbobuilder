import Foundation

/// Gears convert a hand's relative turn to a request. They never predict a planet's position.
public struct ApolloScrub: Hashable, Sendable {
    public let body: AstroDNAGene
    public let pickupRadius: Double
    public private(set) var rawJulianDay: Double
    private var lastAngle: Double
    public init(body: AstroDNAGene, julianDay: JulianDay, angle: Double, radius: Double) {
        self.body = body; self.rawJulianDay = julianDay.value
        self.lastAngle = angle; self.pickupRadius = max(60, radius)
    }
    public mutating func move(angle: Double, radius: Double, domain: HoraeControlDomain, exponent: Double = 2.75) -> JulianDay {
        guard angle.isFinite, radius.isFinite, exponent.isFinite else { return JulianDay(rawJulianDay)! }
        let delta = Apollo.wrappedAngle(angle - lastAngle)
        lastAngle = angle
        rawJulianDay += delta / 360 * Apollo.period(for: body) * pow(pickupRadius / max(60, radius), exponent)
        rawJulianDay = Apollo.bounded(rawJulianDay, to: domain).value
        return JulianDay(rawJulianDay)!
    }
}
public struct ApolloContact: Hashable, Sendable {
    public let left: AstroDNAGene
    public let right: AstroDNAGene
    public let mark: RingMark
    public let residual: Double
}
public struct ApolloAspectSettings: Hashable, Sendable {
    public var enabled: Set<RingMark> = [.conjunction, .sextile, .square, .trine, .opposition]
    public var orb: Double = 6
    public var showWeb = true
    public var magnetism: Double = 0.7
    public init() {}
    public func orb(for mark: RingMark) -> Double {
        let scale: Double
        switch mark {
        case .semisextile, .quincunx: scale = 0.5
        case .semisquare, .sesquiquadrate: scale = 0.45
        case .quintile, .biquintile: scale = 0.4
        default: scale = 1
        }
        return max(0, orb) * scale
    }
}
public extension Apollo {
    static func period(for gene: AstroDNAGene) -> Double {
        switch gene {
        case .ascendant: return 0.99727
        case .moon: return 27.32166
        case .mercury: return 87.9691
        case .venus: return 224.701
        case .sun: return 365.2564
        case .mars: return 686.98
        case .jupiter: return 4332.59
        case .saturn: return 10759.22
        case .uranus: return 30688.5
        case .neptune: return 60182
        case .pluto: return 90560
        case .northNode: return 6798.38
        }
    }
    static func wrappedAngle(_ angle: Double) -> Double {
        var result = angle.truncatingRemainder(dividingBy: 360)
        if result > 180 { result -= 360 }
        if result < -180 { result += 360 }
        return result
    }
    static func bounded(_ value: Double, to domain: HoraeControlDomain) -> JulianDay {
        JulianDay(min(domain.endExclusive.value.nextDown, max(domain.start.value, value)))!
    }
    static func contacts(in chart: AstrolabeChart, settings: ApolloAspectSettings) -> [ApolloContact] {
        var result: [ApolloContact] = []
        for (index, left) in chart.placements.enumerated() {
            for right in chart.placements.dropFirst(index + 1) {
                let separation = Oceanus.separation(from: left.longitude, to: right.longitude).degrees
                let arc = min(separation, 360 - separation)
                if let hit = nearestContact(arc: arc, settings: settings, cap: settings.orb) {
                    result.append(ApolloContact(left: left.gene, right: right.gene, mark: hit.mark, residual: hit.residual))
                }
            }
        }
        return result
    }
    private static func nearestContact(arc: Double, settings: ApolloAspectSettings, cap: Double) -> (mark: RingMark, residual: Double)? {
        var best: (mark: RingMark, residual: Double)?
        for mark in settings.enabled.sorted(by: { $0.rawValue < $1.rawValue }) {
            let residual = abs(arc - Double(mark.rawValue))
            guard residual <= min(cap, settings.orb(for: mark)), best == nil || residual < best!.residual - 1e-12 else { continue }
            best = (mark, residual)
        }
        return best
    }
    /// Uses two actual Spine samples, then adjusts the requested moment, never a drawn longitude.
    static func magneticMoment(raw: JulianDay, body: AstroDNAGene, first: ApolloAegis, second: ApolloAegis,
                               settings: ApolloAspectSettings, domain: HoraeControlDomain) -> JulianDay {
        let h = second.source.julianDay.value - first.source.julianDay.value
        guard first.source.julianDay == raw, settings.magnetism > 0, h > 0,
              let a = first.sky.placement(body), let b = second.sky.placement(body) else { return raw }
        var best: (delta: Double, residual: Double, window: Double)?
        func consider(_ x: Double, _ y: Double, window: Double) {
            let velocity = wrappedAngle(y - x) / h
            guard window > 0, abs(x) <= window, abs(velocity) > 1e-6 else { return }
            if best == nil || abs(x) < best!.residual { best = (-x / velocity, abs(x), window) }
        }
        func contact(_ x: CelestialLongitude, _ y: CelestialLongitude) {
            let one = wrappedAngle(a.longitude.degrees - x.degrees)
            let two = wrappedAngle(b.longitude.degrees - y.degrees)
            if let hit = nearestContact(arc: abs(one), settings: settings, cap: 1.5) {
                let signedMark = Double(hit.mark.rawValue) * (one < 0 ? -1 : 1)
                consider(wrappedAngle(one - signedMark), wrappedAngle(two - signedMark), window: min(1.5, settings.orb(for: hit.mark)))
            }
        }
        for other in first.sky.placements where other.gene != body {
            if let next = second.sky.placement(other.gene) { contact(other.longitude, next.longitude) }
        }
        for other in first.natal?.placements ?? [] { contact(other.longitude, other.longitude) }
        let boundary = (a.longitude.degrees / 30).rounded() * 30
        consider(wrappedAngle(a.longitude.degrees - boundary), wrappedAngle(b.longitude.degrees - boundary), window: 1.5)
        guard let best, abs(best.delta) <= period(for: body) * best.window / 360 * 8 else { return raw }
        let u = 1 - best.residual / best.window
        let weight = min(1, max(0, settings.magnetism)) * u * u * (3 - 2 * u)
        return bounded(raw.value + best.delta * weight, to: domain)
    }
}

public struct ApolloCrossContact: Hashable, Sendable {
    public let moving: AstroDNAGene
    public let natal: AstroDNAGene
    public let mark: RingMark
    public let residual: Double
}
public extension Apollo {
    static func contacts(from sky: AstrolabeChart, to natal: AstrolabeChart, settings: ApolloAspectSettings) -> [ApolloCrossContact] {
        var result: [ApolloCrossContact] = []
        for moving in sky.placements {
            for fixed in natal.placements {
                let separation = Oceanus.separation(from: moving.longitude, to: fixed.longitude).degrees
                if let hit = nearestContact(arc: min(separation, 360 - separation), settings: settings, cap: settings.orb) {
                    result.append(ApolloCrossContact(moving: moving.gene, natal: fixed.gene, mark: hit.mark, residual: hit.residual))
                }
            }
        }
        return result.sorted { $0.residual > $1.residual }
    }
}
