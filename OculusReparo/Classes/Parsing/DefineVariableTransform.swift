open class DefineVariableTransform : Transform {
    /**
     Performs variable substitution on the given configuration lines
     
     - Parameter lines:      The configuration to transform
     - Parameter parser:     The configuration parser the transform is being called from
     
     - Throws:               ReparoError if the configuration is invalid
     
     - Returns:              The transformed configuration lines
     */
    open func transform(_ line: Line, scope: Scope) throws -> (line: Line?, scope: Scope) {
        if let key = line.key {
            if key.hasPrefix("@set") && key.characters.count > 5 {
                var name = key.substring(from: key.characters.index(key.startIndex, offsetBy: 5))
                name = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                if let value = line.value {
                    scope.variables[name] = value as AnyObject?
                }
                
                return (nil, scope)
            }
        }
        
        return (line, scope)
    }
}
