import UIKit

/// Protocol to report layout information and errors
public protocol LayoutDebugger {
    /**
     Determines whether to show debugging messages
     */
    var showDebugMessages: Bool { get set }

    /**
     Determines whether to show informational messages
     */
    var showInfoMessages: Bool { get set }

    /**
     Determines whether to show error messages
     */
    var showErrorMessages: Bool { get set }
    
    /**
     Prints the given debug message to the console
     
     - Parameter message:   The information message
     */
    func debug(message: String)
    
    /**
     Prints the given info message to the console
     
     - Parameter message:   The information message
     */
    func info(message: String)
    
    /**
     Prints the given LayoutErrorInfo object to the console
     
     - Parameter info:       The layout error information
     */
    func error(info: LayoutErrorInfo)
}

/// Class to print layout information and errors to the console
public class ConsoleLayoutDebugger : LayoutDebugger {
    /**
     Determines whether to show debugging messages
     */
    public var showDebugMessages = false
    
    /**
     Determines whether to show informational messages
     */
    public var showInfoMessages = true

    /**
     Determines whether to show error messages
     */
    public var showErrorMessages = true
    
    public init() {
    }
    
    /**
     Prints the given debug message to the console
     
     - Parameter message:   The information message
     */
    public func debug(message: String) {
        if showDebugMessages {
            print(message)
        }
    }

    /**
     Prints the given info message to the console
     
     - Parameter message:   The information message
     */
    public func info(message: String) {
        if showInfoMessages {
            print(message)
        }
    }

    /**
     Prints the given LayoutErrorInfo object to the console
     
     - Parameter info:       The layout error information
     */
    public func error(info: LayoutErrorInfo) {
        if showErrorMessages {
            print("")
            print("----------")
            print("")
            print("OculusReparo : Fatal Layout Error!")
            print("")
            print("\(info.message)")
            print("")
            print("Filename           : \(info.filename)")
            print("Line Number        : \(info.lineNumber)")
            print("")
            print("----------")
            print("")
        }
    }
}
