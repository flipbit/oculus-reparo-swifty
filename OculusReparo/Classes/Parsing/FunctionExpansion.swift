public class FunctionExpansion : Expansion {
    public func expand(line: Line, scope: Scope, parser: Parser) throws -> [Line]? {
        // Line must have a key
        guard let key = line.key else {
            return nil
        }
        
        // Key must start with "@" symbol
        if !key.hasPrefix("@") {
            return nil
        }
        
        // Set function name
        let name = key.substringFromIndex(key.startIndex.advancedBy(1))
        
        // Check function exists
        guard let function = scope.functions[name] else {
            return nil
        }
        
        // Add function arguments
        if let arguments = line as? Section {
            for argument in arguments.lines {
                if let key = argument.key, value = argument.value {
                    scope.variables[key] = value
                }
            }
        }
        
        // Clone function
        var lines = [Line]()
        for line in function {
            lines.append(line.clone())
        }
        
        // Transform function
        return try parser.transform(lines, scope: scope)
    }
}