public protocol Expansion {    
    /**
     Transforms the given configuration lines
     
     - Parameter line:      The configuration line to transform
     - Parameter parser:    The configuration parser the transform is being called from
     
     - Throws:              ReparoError if the configuration is invalid
     
     - Returns:             The transformed configuration line
     */
    func expand(line: Line, scope: Scope, parser: Parser) throws -> [Line]?
}