import Foundation

public enum DebugCategory: String, CaseIterable, Identifiable {
    /// A type of log that indicates an error occured during an operation.
    case error
    /// A type of log that indicates a warning.
    case warning
    /// A type of log that displays information regarding the operation.
    case info
    /// A type of log that indicates an operation succeeded.
    case success
    /// A type of log that prints for general debugging purposes.
    case debug
    /// No type is defined.
    case none
    
    public var id: String { self.rawValue }
}
