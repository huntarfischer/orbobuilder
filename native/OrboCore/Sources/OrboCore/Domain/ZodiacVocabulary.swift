public enum Element: String, CaseIterable, Codable, Hashable, Sendable {
    case fire
    case earth
    case air
    case water
}

public enum Modality: String, CaseIterable, Codable, Hashable, Sendable {
    case cardinal
    case fixed
    case mutable
}

public enum Motion: String, CaseIterable, Codable, Hashable, Sendable {
    case direct
    case retrograde
}

public enum Sect: String, CaseIterable, Codable, Hashable, Sendable {
    case day
    case night
}
