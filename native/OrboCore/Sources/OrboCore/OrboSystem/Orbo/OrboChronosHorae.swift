/// Direct typed seams from Orbo to established system authorities.
///
/// Orbo asks; the addressed authority remains the owner of the answer.
/// Orbo retains neither authority and performs none of their derivation.
public extension Orbo {
    func askChronos(
        date: CivilDate,
        time: CivilClockTime,
        in timezone: TimezoneIdentifier
    ) -> ChronosResolution {
        Chronos.resolveCivilMoment(
            date: date,
            time: time,
            in: timezone
        )
    }

    func askHorae(
        _ intent: HoraeControlIntent,
        using horae: Horae
    ) throws -> HoraeOutput {
        try horae.respond(to: intent)
    }
}
