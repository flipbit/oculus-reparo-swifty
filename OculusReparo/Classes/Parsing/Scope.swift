import Foundation

open class Scope {
    open var variables: [String: AnyObject]
    open var directives: [String]
    open var functions: [String: [Line]]
    open var screenSize: CGSize
    var depth = 0
    
    public init() {
        variables = [:]
        directives = []
        functions = [:]
        screenSize = CGSize.zero
    }
    
    public init(parser: Parser) {
        variables = parser.variables
        directives = parser.directives
        functions = [:]
        screenSize = parser.screenSize
    }
    
    open func satisfiesDirectives(_ line: Line) throws -> Bool {
        var satisfied = true
        
        for directive in line.directives {
            
            // Resolution directive?
            if directive.isResolutionDirective {
                
                // Check if valid
                satisfied = try directive.satisfiedBy(screenSize)
            } else {
                
                // Check if directive found..
                satisfied = directives.contains(where: {$0.caseInsensitiveCompare(directive.name) == .orderedSame})
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
