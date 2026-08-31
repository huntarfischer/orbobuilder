/// The collective Moirai boundary for one Engraving stop on Hermes's itinerary.
///
/// Clotho gathers, Lachesis allots, and Atropos verifies and seals. The same
/// Hermes package identity is returned with the canonical work attached. The
/// Engraving remains unfinished until Hestia hangs it on the Hearth.
public enum Moirai {
    public static func process<Port: ClothoPortI>(
        _ package: HermesPackage<Engraving>,
        through portI: inout Port
    ) throws -> HermesPackage<Engraving> {
        let clotho = try Clotho.spin(package.contents, through: &portI)
        let lachesis = Lachesis.receive(clotho.packet)
        let placement = Lachesis.allot(lachesis.packet, into: Tapestry())
        let tapestry = Lachesis.allot(lachesis.titanPass, into: placement)
        let sealed = try Atropos.inspect(
            packet: lachesis.packet,
            titanPass: lachesis.titanPass,
            tapestry: tapestry
        ).get()

        let workedEngraving = clotho.engraving
            .resolving(sect: clotho.packet.sect)
            .resolving(tapestry: sealed)
        return HermesPackage(
            packageID: package.packageID,
            subjectID: package.subjectID,
            sender: package.sender,
            kind: package.kind,
            addresses: package.addresses,
            contents: workedEngraving
        )!
    }
}
