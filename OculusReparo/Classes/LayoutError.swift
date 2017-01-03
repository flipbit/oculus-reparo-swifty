import Foundation

enum LayoutError: Error {
    case configurationError(LayoutErrorInfo)
    case missingRootView
    case missingModelProperty(String)
    case unknownFontWeight(String)
    case invalidInsetFormat(String)
    case invalidTextAlignment(String)
    case invalidConfiguration(String)
}

open class LayoutErrorInfo {
    var message: String
    let filename: String
    let lineNumber: Int
    
    init(message: String, filename: String, lineNumber: Int) {
        self.message = message
        self.filename = filename
        self.lineNumber = lineNumber
    }
    
    func append(_ line: String) {
        if message.characters.count > 0 {
            message = "\(message)\n"
        }
        
        message = "\(message)\(line)"
    }
}
