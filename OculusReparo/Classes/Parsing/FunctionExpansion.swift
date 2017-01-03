open class FunctionExpansion : Expansion {
    open func expand(_ line: Line, scope: Scope, parser: Parser) throws -> [Line]? {
        // Line must have a key
        guard let key = line.key else {
            return nil
        }
        
        // Key must start with "@" symbol
        if !key.hasPrefix("@") {
            return nil
        }
        
        // Set function name
        let name = key.substring(from: key.characters.index(key.startIndex, offsetBy: 1))
        
        // Check function exists
        guard let function = scope.functions[name] else {
            return nil
        }
        
        // Add function arguments
        if let arguments = line as? Section {
            for argument in arguments.lines {
                if let key = argument.key, let value = argument.value {
                    scope.variables[key] = value as AnyObject?
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
