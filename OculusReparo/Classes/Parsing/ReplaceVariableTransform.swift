/**
 Performs variable substitution configuration
*/
public class ReplaceVariableTransform : Transform {
    /**
     Performs variable substitution on the given configuration lines
     
     - Parameter lines:      The configuration to transform
     - Parameter parser:     The configuration parser the transform is being called from
     
     - Throws:               ReparoError if the configuration is invalid
     
     - Returns:              The transformed configuration lines
     */
    public func transform(line: Line, scope: Scope) throws -> (line: Line?, scope: Scope) {
        if var value = line.value where !line.quoted {
            for key in scope.variables.keys {
                if (value.containsString("@\(key)")) {
                    value = value.stringByReplacingOccurrencesOfString("@\(key)", withString: scope.variables[key]!)
                }
            }
            
            line.value = value
        }
        
        return (line, scope)
    }
}

