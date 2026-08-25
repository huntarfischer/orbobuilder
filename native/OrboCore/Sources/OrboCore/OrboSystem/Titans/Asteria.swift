/// Keeper of Arc.
///
/// Asteria does not reimplement half-arc geometry. She is the authoritative
/// entrance to the frozen Arc law. Her keeper verb is refract; Arc's proven
/// internal cast/compose vocabulary remains untouched.
public enum Asteria {
    public static func refract(_ anchor: ArcCoordinate) -> ArcField {
        Arc.cast(anchor)
    }

    public static func refract(
        _ anchor: ArcCoordinate,
        with partner: ArcCoordinate
    ) -> ArcComposite {
        Arc.compose(anchor, partner)
    }

    public static func refract(_ subject: ArcSubject) -> ArcSubjectCast {
        Arc.cast(subject)
    }

    public static func refract(_ subjects: [ArcSubject]) -> [ArcSubjectCast] {
        Arc.cast(subjects)
    }

    public static func refract(
        _ first: ArcSubject,
        with second: ArcSubject
    ) -> ArcSubjectComposition {
        Arc.compose(first, second)
    }

    public static func project(_ field: ArcField) -> ArcGrid {
        Arc.project(field)
    }
}
