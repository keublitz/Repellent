import Foundation

/// A debugging tool for printing simple and identifiable console logs.
@available(*, deprecated, message: "Use the shared 'console' object to call functions.")
@MainActor
public class Debugger {
    public static let shared = Debugger()
    
    /// The categories of log messages.
    private static var category: DebugCategory = .none
    
    /// The integer representing the number of console logs.
    private static var logCount: Int = 0
    
    /// Increments the console count by one.
    private static func incrementLog() {
        logCount += 1
    }
    
    /// The printed type of log message.
    private static var logType: String? {
        switch category {
        case .error: return "ERROR:"
        case .warning: return "WARNING:"
        case .info: return "INFO:"
        case .success: return "SUCCESS:"
        case .debug: return "DEBUG:"
        case .none: return nil
        }
    }
    
    /// The number of the current console log.
    private static var count: String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 3
        let count = formatter.string(from: NSNumber(value: logCount)) ?? String(logCount)
        return count
    }
    
    /// The time at which the current console log was printed.
    private static var date: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    /// A collection of type `Any` converted to string.
    private static func itemText(_ items: Any...) -> String {
        let text = items.map{ "\($0)" }.joined(separator: " ")
        return text
    }
    
    /// Sends a numerically identifiable and timestamped log to the console.
    ///
    ///
    public static func log(
        _ items: Any...,
        for operation: String = #function,
        at line: Int = #line,
        fileID: String = #fileID,
        type: DebugCategory = .none,
        simple: Bool = false
    ) {
        incrementLog()
        category = type
        
        var opr: String {
            let formattedOperation = operation.components(separatedBy: "(").first ?? operation
            let lhsFormattedFileID = fileID.components(separatedBy: ".swift").first ?? fileID
            let formattedFileID = lhsFormattedFileID.components(separatedBy: "Foster/").last ?? fileID
            
            return "[\(formattedFileID).\(formattedOperation).\(line)]"
        }
        
        if simple {
            print("\(count) | \(date) | ", itemText(items))
        } else {
            print("\(count) | \(date) | \(opr.suffixed)\(logType.suffixed)", itemText(items))
        }
    }
    
    /// Sends a numerically identifiable and timestamped log to the console.
    public static func log(
        _ message: String = "",
        _ items: Any...,
        for operation: String = #function,
        at line: Int = #line,
        fileID: String = #fileID,
        type: DebugCategory = .none,
        profile: Bool = false,
        simple: Bool = false
    ) {
        incrementLog()
        category = type
        
        var opr: String {
            let formattedOperation = operation.components(separatedBy: "(").first ?? operation
            let lhsFormattedFileID = fileID.components(separatedBy: ".swift").first ?? fileID
            let formattedFileID = lhsFormattedFileID.components(separatedBy: "Foster/").last ?? fileID
            
            if profile {
                return "[\(formattedFileID).\(formattedOperation)]"
            }
            return "[\(formattedFileID).\(formattedOperation).\(line)]"
        }
        
        if simple {
            if items.isEmpty {
                print("\(count) | \(date) | \(message)")
            } else {
                print("\(count) | \(date) | \(message)", itemText(items))
            }
        } else {
            if items.isEmpty {
                print("\(count) | \(date) | \(opr.suffixed)\(logType.suffixed)\(message)")
            } else {
                print("\(count) | \(date) | \(opr.suffixed)\(logType.suffixed)\(message)", itemText(items))
            }
        }
    }
    
    /// Profiles the total duration of an operation in milliseconds.
    public static func profile<T>(
        _ function: String = #function,
        fileID: String = #fileID,
        _ block: () -> T
    ) -> T {
        let start = CFAbsoluteTimeGetCurrent()
        defer {
            let end = CFAbsoluteTimeGetCurrent()
            let elapsed = (end - start) * 1000
            Debugger.log("*** Executed task in \(elapsed.shorten)ms ***", for: function, fileID: fileID, profile: true)
        }
        return block()
    }
    
    /// Sends a log to the console informing that a guard statement was not met.
    public static func guardBlocked(because reason: String? = nil, function: String = #function, at line: Int = #line, fileID: String = #fileID) {
        var reasonIfAny: String {
            if let reason = reason {
                return "BLOCKED: Function did not pass guard (\(reason))"
            } else {
                return "BLOCKED: Function did not pass guard"
            }
        }
        
        Debugger.log(reasonIfAny, for: function, at: line, fileID: fileID)
    }
    
    /// Sends a localized description of a caught error to the console, as well as additional information.
    public static func `catch`(_ error: any Error, context: Bool = true, for operation: String = #function, at line: Int = #line, fileID: String = #fileID) {
        Debugger.log(error.localizedDescription, for: operation, at: line, fileID: fileID, type: .error)
        if context {
            print("==> \(error)")
        }
    }
    
    public static func fatalError(
        _ message: String,
        _ items: Any...,
        for operation: String = #function,
        at line: Int = #line,
        fileID: String = #fileID
    ) -> Never {
        incrementLog()
        
        var opr: String {
            let formattedOperation = operation.components(separatedBy: "(").first ?? operation
            let lhsFormattedFileID = fileID.components(separatedBy: ".swift").first ?? fileID
            let formattedFileID = lhsFormattedFileID.components(separatedBy: "Foster/").last ?? fileID
            
            return "[\(formattedFileID).\(formattedOperation).\(line)]"
        }
        
        if !items.isEmpty {
            Debugger.log("FATAL ERROR: \(message)", items, for: operation, at: line, fileID: fileID)
        } else {
            Debugger.log("FATAL ERROR: \(message)", for: operation, at: line, fileID: fileID)
        }
        
        exit(1)
    }
}

public final class AsyncDebugger: @unchecked Sendable {
    fileprivate static let shared = AsyncDebugger()
    
    private let queue = DispatchQueue(label: "com.keublitz.debugger")
    
    /// The categories of log messages.
    private var category: DebugCategory = .none
    
    /// The integer representing the number of console logs.
    private var logCount: Int = 0
    
    /// Increments the console count by one.
    private func incrementLog() {
        logCount += 1
    }
    
    /// The printed type of log message.
    private var logType: String? {
        switch category {
        case .error: return "ERROR:"
        case .warning: return "WARNING:"
        case .info: return "INFO:"
        case .success: return "SUCCESS:"
        case .debug: return "DEBUG:"
        case .none: return nil
        }
    }
    
    /// The number of the current console log.
    private var count: String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 3
        let count = formatter.string(from: NSNumber(value: logCount)) ?? String(logCount)
        return count
    }
    
    /// The time at which the current console log was printed.
    private var date: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    /// A collection of type `Any` converted to string.
    private func itemText(_ items: Any...) -> String {
        let text = items.map{ "\($0)" }.joined(separator: " ")
        return text
    }
    
    /// Sends a numerically identifiable and timestamped log to the console.
    ///
    ///
    public func log(
        _ items: Any...,
        for operation: String = #function,
        at line: Int = #line,
        fileID: String = #fileID,
        type: DebugCategory = .none,
        simple: Bool = false
    ) {
        queue.sync {
            incrementLog()
        }
        
        category = type
        
        var opr: String {
            let formattedOperation = operation.components(separatedBy: "(").first ?? operation
            let lhsFormattedFileID = fileID.components(separatedBy: ".swift").first ?? fileID
            let formattedFileID = lhsFormattedFileID.components(separatedBy: "Foster/").last ?? fileID
            
            return "[\(formattedFileID).\(formattedOperation).\(line)]"
        }
        
        if simple {
            print("\(count) | \(date) | ", itemText(items))
        } else {
            print("\(count) | \(date) | \(opr.suffixed)\(logType.suffixed)", itemText(items))
        }
    }
    
    /// Sends a numerically identifiable and timestamped log to the console.
    public func log(
        _ message: String = "",
        _ items: Any...,
        for operation: String = #function,
        at line: Int = #line,
        fileID: String = #fileID,
        type: DebugCategory = .none,
        profile: Bool = false,
        simple: Bool = false
    ) {
        queue.sync {
            incrementLog()
        }
        
        category = type
        
        var opr: String {
            let formattedOperation = operation.components(separatedBy: "(").first ?? operation
            let lhsFormattedFileID = fileID.components(separatedBy: ".swift").first ?? fileID
            let formattedFileID = lhsFormattedFileID.components(separatedBy: "Foster/").last ?? fileID
            
            if profile {
                return "[\(formattedFileID).\(formattedOperation)]"
            }
            return "[\(formattedFileID).\(formattedOperation).\(line)]"
        }
        
        if simple {
            if items.isEmpty {
                print("\(count) | \(date) | \(message)")
            } else {
                print("\(count) | \(date) | \(message)", itemText(items))
            }
        } else {
            if items.isEmpty {
                print("\(count) | \(date) | \(opr.suffixed)\(logType.suffixed)\(message)")
            } else {
                print("\(count) | \(date) | \(opr.suffixed)\(logType.suffixed)\(message)", itemText(items))
            }
        }
    }
    
    /// Profiles the total duration of an operation in milliseconds.
    public func profile<T>(
        _ function: String = #function,
        fileID: String = #fileID,
        _ block: () -> T
    ) -> T {
        let start = CFAbsoluteTimeGetCurrent()
        defer {
            let end = CFAbsoluteTimeGetCurrent()
            let elapsed = (end - start) * 1000
            log("*** Executed task in \(elapsed.shorten)ms ***", for: function, fileID: fileID, profile: true)
        }
        return block()
    }
    
    /// Sends a log to the console informing that a guard statement was not met.
    public func guardBlocked(because reason: String? = nil, function: String = #function, at line: Int = #line, fileID: String = #fileID) {
        var reasonIfAny: String {
            if let reason = reason {
                return "BLOCKED: Function did not pass guard (\(reason))"
            } else {
                return "BLOCKED: Function did not pass guard"
            }
        }
        
        log(reasonIfAny, for: function, at: line, fileID: fileID)
    }
    
    /// Sends a localized description of a caught error to the console, as well as additional information.
    public func `catch`(_ error: any Error, context: Bool = true, for operation: String = #function, at line: Int = #line, fileID: String = #fileID) {
        log(error.localizedDescription, for: operation, at: line, fileID: fileID, type: .error)
        if context {
            print("==> \(error)")
        }
    }
    
    public func fatalError(
        _ message: String,
        _ items: Any...,
        for operation: String = #function,
        at line: Int = #line,
        fileID: String = #fileID
    ) -> Never {
        queue.sync {
            incrementLog()
        }
        
        var opr: String {
            let formattedOperation = operation.components(separatedBy: "(").first ?? operation
            let lhsFormattedFileID = fileID.components(separatedBy: ".swift").first ?? fileID
            let formattedFileID = lhsFormattedFileID.components(separatedBy: "Foster/").last ?? fileID
            
            return "[\(formattedFileID).\(formattedOperation).\(line)]"
        }
        
        if !items.isEmpty {
            log("FATAL ERROR: \(message)", items, for: operation, at: line, fileID: fileID)
        } else {
            log("FATAL ERROR: \(message)", for: operation, at: line, fileID: fileID)
        }
        
        exit(1)
    }
}

public let console = AsyncDebugger.shared

fileprivate extension BinaryFloatingPoint {
    var shorten: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        let formattedNumber = formatter.string(from: NSNumber(value: Double(self))) ?? ""
        return formattedNumber
    }
}

fileprivate extension String {
    var prefixed: String {
        isEmpty ? "" : " \(self)"
    }
    
    var suffixed: String {
        isEmpty ? "" : "\(self) "
    }
}

fileprivate extension Optional where Wrapped == String {
    var prefixed: String {
        self == nil ? "" : " \(self!)"
    }
    
    var suffixed: String {
        self == nil ? "" : "\(self!) "
    }
}
