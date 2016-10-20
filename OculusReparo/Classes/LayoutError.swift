import Foundation

enum LayoutError: ErrorType {
    case ConfigurationError(LayoutErrorInfo)
    case MissingRootView
    case MissingModelProperty(String)
    case UnknownFontWeight(String)
    case InvalidInsetFormat(String)
    case InvalidTextAlignment(String)
    case InvalidConfiguration(String)
}

public class LayoutErrorInfo {
    let message: String
    let filename: String
    let lineNumber: Int
    
    init(message: String, filename: String, lineNumber: Int) {
        self.message = message
        self.filename = filename
        self.lineNumber = lineNumber
    }
}
