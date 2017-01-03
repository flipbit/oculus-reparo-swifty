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
    func debug(_ message: String)
    
    /**
     Prints the given info message to the console
     
     - Parameter message:   The information message
     */
    func info(_ message: String)
    
    /**
     Prints the given LayoutErrorInfo object to the console
     
     - Parameter info:       The layout error information
     */
    func error(_ info: LayoutErrorInfo)
}

/// Class to print layout information and errors to the console
open class ConsoleLayoutDebugger : LayoutDebugger {
    /**
     Determines whether to show debugging messages
     */
    open var showDebugMessages = false
    
    /**
     Determines whether to show informational messages
     */
    open var showInfoMessages = true

    /**
     Determines whether to show error messages
     */
    open var showErrorMessages = true
    
    public init() {
    }
    
    /**
     Prints the given debug message to the console
     
     - Parameter message:   The information message
     */
    open func debug(_ message: String) {
        if showDebugMessages {
            print(message)
        }
    }

    /**
     Prints the given info message to the console
     
     - Parameter message:   The information message
     */
    open func info(_ message: String) {
        if showInfoMessages {
            print(message)
        }
    }

    /**
     Prints the given LayoutErrorInfo object to the console
     
     - Parameter info:       The layout error information
     */
    open func error(_ info: LayoutErrorInfo) {
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
