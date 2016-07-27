/**
 Declares resuable function blocks
 */
public class DefineFunctionTransform : Transform {
    public func transform(line: Line, scope: Scope) throws -> (line: Line?, scope: Scope) {
        
        // Line must be a section
        guard let section = line as? Section else {
            return (line, scope)
        }
        
        // Line must have a key
        guard let key = section.key else {
            return (line, scope)
        }

        // Key must be "@define"
        if key.caseInsensitiveCompare("@define") != NSComparisonResult.OrderedSame {
            return (line, scope)
        }

        // Section must have a value
        guard let value = section.value else {
            throw ReparoError.InvalidConfigurationLine("Function doesn't have a name: \(section.lineNumber)")
        }

        // Assign function to scope
        scope.functions[value] = section.lines
        
        // Return scope only
        return (nil, scope)
    }
}

