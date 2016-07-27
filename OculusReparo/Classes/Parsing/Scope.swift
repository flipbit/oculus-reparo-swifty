import Foundation

public class Scope {
    var variables: [String: String]
    var directives: [String]
    var functions: [String: [Line]]
    var depth = 0
    
    public init() {
        variables = [:]
        directives = []
        functions = [:]
    }
    
    public init(parser: Parser) {
        variables = parser.variables
        directives = parser.directives
        functions = [:]
    }
}