public extension Mater {
    /// The complete consumer-facing Mater condition for one planetary coordinate.
    ///
    /// Qualification joins three things that already exist:
    /// - the reusable planet × sign Temper,
    /// - the one-field circuitry resolved by `FieldTemper`,
    /// - the few degree/sect qualifiers that cannot live on a sign Temper.
    ///
    /// No source kind is admitted here. Natal, mundane, electional, and later
    /// synchronic coordinates all enter through the same longitude field.
    struct QualifiedTemper: Hashable, Sendable {
        public let planet: Planet
        public let longitude: CelestialLongitude
        public let fieldTemper: FieldTemper

        // Sect is fixed-shape. Both are false when no sect is supplied.
        public let sectDay: Bool
        public let sectNight: Bool

        // Rulership channels remain distinguishable. A UI/read doctrine can
        // select or combine them without rebuilding this record.
        public let traditionalDomicile: Bool
        public let modernDomicile: Bool
        public let traditionalDetriment: Bool
        public let modernDetriment: Bool

        // The remaining immediate condition answers are always present.
        public let exaltation: Bool
        public let atExaltationDegree: Bool
        public let triplicity: Bool
        public let bound: Bool
        public let face: Bool
        public let fall: Bool

        /// `peregrine` is the current classical five-rung law. Modern planets
        /// are outside that law, so `peregrineApplies` is false for them rather
        /// than encoding "not applicable" as an accidental true peregrine.
        public let peregrineApplies: Bool
        public let peregrine: Bool

        // Whole-field condition, copied as an immediate boolean rather than
        // forcing a consumer to inspect reception details.
        public let mutualReception: Bool

        // Degree/sect provenance. These are lookups from the canonical Mater
        // tables, never a second doctrine implementation.
        public let boundRuler: Planet
        public let faceRuler: Planet
        public let triplicityDayRuler: Planet
        public let triplicityNightRuler: Planet
        public let triplicityParticipatingRuler: Planet
        public let triplicityOperativeRuler: Planet?

        public let mutualReceptionWith: [Planet]
        public let mutualReceptionKinds: [MutualReceptionKind]

        fileprivate init(
            planet: Planet,
            longitude: CelestialLongitude,
            fieldTemper: FieldTemper,
            sect: Sect?,
            bound: Bound,
            face: Face,
            triplicity: Triplicity
        ) {
            self.planet = planet
            self.longitude = longitude
            self.fieldTemper = fieldTemper

            sectDay = sect == .day
            sectNight = sect == .night

            traditionalDomicile = fieldTemper.temper.traditionalRulership.domicile
            modernDomicile = fieldTemper.temper.modernRulership.domicile
            traditionalDetriment = fieldTemper.temper.traditionalRulership.detriment
            modernDetriment = fieldTemper.temper.modernRulership.detriment

            exaltation = fieldTemper.temper.exaltation
            fall = fieldTemper.temper.fall

            let exactExaltation = Mater.exaltation(of: planet)
            atExaltationDegree = exactExaltation?.sign == longitude.sign
                && exactExaltation?.degree == longitude.degreeInSign

            let operativeTriplicity = triplicity.operativeRuler(for: sect)
            self.triplicity = operativeTriplicity == planet
                || triplicity.participatingRuler == planet
            self.bound = bound.ruler == planet
            self.face = face.ruler == planet

            peregrineApplies = planet.isClassical
            peregrine = planet.isClassical
                && !traditionalDomicile
                && !exaltation
                && !self.triplicity
                && !self.bound
                && !self.face

            mutualReception = fieldTemper.mutualReception

            boundRuler = bound.ruler
            faceRuler = face.ruler
            triplicityDayRuler = triplicity.dayRuler
            triplicityNightRuler = triplicity.nightRuler
            triplicityParticipatingRuler = triplicity.participatingRuler
            triplicityOperativeRuler = operativeTriplicity

            mutualReceptionWith = fieldTemper.mutualReceptionWith
            mutualReceptionKinds = fieldTemper.mutualReceptionKinds
        }
    }

    /// One exact ten-planet field qualified through Mater V2.
    ///
    /// Exact longitudes are retained for degree-sensitive reads, while the
    /// embedded `Field` proves the same sign Tempers and field circuitry remain
    /// the reusable substrate underneath them.
    struct QualifiedField: Sendable {
        public let longitudes: [Planet: CelestialLongitude]
        public let sect: Sect?
        public let field: Field
        public let tempers: [QualifiedTemper]
        public let byPlanet: [Planet: QualifiedTemper]

        fileprivate init(
            longitudes: [Planet: CelestialLongitude],
            sect: Sect?,
            field: Field,
            tempers: [QualifiedTemper]
        ) {
            self.longitudes = longitudes
            self.sect = sect
            self.field = field
            self.tempers = tempers
            byPlanet = Dictionary(uniqueKeysWithValues: tempers.map { ($0.planet, $0) })
        }

        public func temper(for planet: Planet) -> QualifiedTemper {
            byPlanet[planet]!
        }
    }

    /// Qualifies any exact ten-planet coordinate field through the same Mater
    /// machinery. The API deliberately has no natal/mundane/electional/
    /// synchronic mode because coordinate origin does not change Mater law.
    static func qualifyField(
        _ longitudes: [Planet: CelestialLongitude],
        sect: Sect?
    ) -> QualifiedField {
        precondition(
            Set(longitudes.keys) == Set(Planet.canonicalOrder),
            "Mater.qualifyField requires exactly the ten canonical planetary longitudes."
        )

        let placements = Dictionary(
            uniqueKeysWithValues: Planet.canonicalOrder.map { planet in
                (planet, longitudes[planet]!.sign)
            }
        )
        let field = resolveField(placements)

        let qualified = Planet.canonicalOrder.map { planet -> QualifiedTemper in
            let longitude = longitudes[planet]!
            let bound = Mater.bound(at: longitude)
            let face = Mater.face(at: longitude)
            let triplicity = Mater.triplicity(of: longitude.sign)

            return QualifiedTemper(
                planet: planet,
                longitude: longitude,
                fieldTemper: field.temper(for: planet),
                sect: sect,
                bound: bound,
                face: face,
                triplicity: triplicity
            )
        }

        return QualifiedField(
            longitudes: longitudes,
            sect: sect,
            field: field,
            tempers: qualified
        )
    }
}
