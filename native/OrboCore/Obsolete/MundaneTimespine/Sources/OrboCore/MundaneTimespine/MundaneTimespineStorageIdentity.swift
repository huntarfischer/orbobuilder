import Foundation

public extension MundaneTimespineStorageFormat {
    /// Human-readable identity of the exact bytes written into the native storage header.
    static var identifier: String {
        String(decoding: magic, as: UTF8.self)
    }
}
