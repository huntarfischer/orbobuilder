public extension Mater {
    struct SignFlags: Hashable, Sendable {
        public let aries: Bool
        public let taurus: Bool
        public let gemini: Bool
        public let cancer: Bool
        public let leo: Bool
        public let virgo: Bool
        public let libra: Bool
        public let scorpio: Bool
        public let sagittarius: Bool
        public let capricorn: Bool
        public let aquarius: Bool
        public let pisces: Bool

        fileprivate init(sign: Sign) {
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

    struct ElementFlags: Hashable, Sendable {
        public let fire: Bool
        public let earth: Bool
        public let air: Bool
        public let water: Bool

        fileprivate init(element: Element) {
            fire = element == .fire
            earth = element == .earth
            air = element == .air
            water = element == .water
        }
    }

    struct ModalityFlags: Hashable, Sendable {
        public let cardinal: Bool
        public let fixed: Bool
        public let mutable: Bool

        fileprivate init(modality: Modality) {
            cardinal = modality == .cardinal
            fixed = modality == .fixed
            mutable = modality == .mutable
        }
    }

    struct RulershipFlags: Hashable, Sendable {
        public let domicile: Bool
        public let detriment: Bool

        fileprivate init(domicile: Bool, detriment: Bool) {
            self.domicile = domicile
            self.detriment = detriment
        }
    }

    /// Reusable sign-resolution Mater truth for one planet.
    ///
    /// Only facts that are fully knowable from planet + sign + frozen Mater
    /// doctrine are stamped here. Degree-sensitive and whole-field facts are
    /// resolved by later Mater V2 passes without changing this reusable form.
    struct Temper: Hashable, Sendable {
        public let planet: Planet
        public let sign: Sign

        public let signFlags: SignFlags
        public let element: Element
        public let elementFlags: ElementFlags
        public let modality: Modality
        public let modalityFlags: ModalityFlags

        public let traditionalRulership: RulershipFlags
        public let modernRulership: RulershipFlags

        public let exaltation: Bool
        public let fall: Bool

        /// Precomputed triplicity possibilities. A resolved chart's sect only
        /// selects between these two already-stamped answers.
        public let triplicityDay: Bool
        public let triplicityNight: Bool

        fileprivate init(
            planet: Planet,
            sign: Sign,
            element: Element,
            modality: Modality,
            traditionalRulership: RulershipFlags,
            modernRulership: RulershipFlags,
            exaltation: Bool,
            fall: Bool,
            triplicityDay: Bool,
            triplicityNight: Bool
        ) {
            self.planet = planet
            self.sign = sign
            signFlags = SignFlags(sign: sign)
            self.element = element
            elementFlags = ElementFlags(element: element)
            self.modality = modality
            modalityFlags = ModalityFlags(modality: modality)
            self.traditionalRulership = traditionalRulership
            self.modernRulership = modernRulership
            self.exaltation = exaltation
            self.fall = fall
            self.triplicityDay = triplicityDay
            self.triplicityNight = triplicityNight
        }
    }

    /// Planet-as-header container. Each canonical planet owns exactly twelve
    /// reusable Tempers in canonical zodiac order.
    struct PlanetTempers: Hashable, Sendable {
        public let planet: Planet
        public let tempers: [Temper]

        fileprivate init(planet: Planet, tempers: [Temper]) {
            self.planet = planet
            self.tempers = tempers
        }

        public func temper(in sign: Sign) -> Temper {
            tempers[sign.rawValue]
        }
    }

    /// Ten canonical planetary headers, each carrying twelve sign Tempers.
    static var planetTempers: [PlanetTempers] {
        canonicalMaterPlanetTempers
    }

    static func tempers(for planet: Planet) -> PlanetTempers {
        canonicalMaterPlanetTempersByPlanet[planet]!
    }

    static func temper(of planet: Planet, in sign: Sign) -> Temper {
        tempers(for: planet).temper(in: sign)
    }
}

private let modernDomicileByPlanet: [Planet: Sign] = [
    .pluto: .scorpio,
    .uranus: .aquarius,
    .neptune: .pisces,
]

private let modernDetrimentByPlanet: [Planet: Sign] = [
    .pluto: .taurus,
    .uranus: .leo,
    .neptune: .virgo,
]

private let canonicalMaterPlanetTempers: [Mater.PlanetTempers] = Planet.canonicalOrder.map { planet in
    let tempers = Sign.canonicalOrder.map { sign -> Mater.Temper in
        let element = Mater.element(of: sign)
        let modality = Mater.modality(of: sign)
        let triplicity = Mater.triplicity(of: sign)

        return Mater.Temper(
            planet: planet,
            sign: sign,
            element: element,
            modality: modality,
            traditionalRulership: Mater.RulershipFlags(
                domicile: Mater.domicileRuler(of: sign) == planet,
                detriment: Mater.detrimentRuler(in: sign) == planet
            ),
            modernRulership: Mater.RulershipFlags(
                domicile: modernDomicileByPlanet[planet] == sign,
                detriment: modernDetrimentByPlanet[planet] == sign
            ),
            exaltation: Mater.exaltation(in: sign)?.planet == planet,
            fall: Mater.fallRuler(in: sign) == planet,
            triplicityDay: triplicity.dayRuler == planet || triplicity.participatingRuler == planet,
            triplicityNight: triplicity.nightRuler == planet || triplicity.participatingRuler == planet
        )
    }

    precondition(tempers.count == Sign.canonicalOrder.count)
    precondition(tempers.map(\.sign) == Sign.canonicalOrder)

    return Mater.PlanetTempers(planet: planet, tempers: tempers)
}

private let canonicalMaterPlanetTempersByPlanet: [Planet: Mater.PlanetTempers] = {
    precondition(canonicalMaterPlanetTempers.count == Planet.canonicalOrder.count)
    precondition(canonicalMaterPlanetTempers.map(\.planet) == Planet.canonicalOrder)

    return Dictionary(
        uniqueKeysWithValues: canonicalMaterPlanetTempers.map { ($0.planet, $0) }
    )
}()
