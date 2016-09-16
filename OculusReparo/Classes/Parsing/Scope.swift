import Foundation

public class Scope {
    public var variables: [String: AnyObject]
    public var directives: [String]
    public var functions: [String: [Line]]
    public var screenSize: CGSize
    var depth = 0
    
    public init() {
        variables = [:]
        directives = []
        functions = [:]
        screenSize = CGSizeZero
    }
    
    public init(parser: Parser) {
        variables = parser.variables
        directives = parser.directives
        functions = [:]
        screenSize = parser.screenSize
    }
    
    public func satisfiesDirectives(line: Line) throws -> Bool {
        var satisfied = true
        
        for directive in line.directives {
            
            // Resolution directive?
            if directive.isResolutionDirective {
                
                // Check if valid
                satisfied = try directive.satisfiedBy(screenSize)
            } else {
                
                // Check if directive found..
                satisfied = directives.contains({$0.caseInsensitiveCompare(directive.name) == .OrderedSame})
            }
            
            // ..flip NOT directives
            if directive.not {
                satisfied = !satisfied
            }
            
            // Break if not satisfied
            if !satisfied {
                break
            }
        }
        
        return satisfied
    }
}