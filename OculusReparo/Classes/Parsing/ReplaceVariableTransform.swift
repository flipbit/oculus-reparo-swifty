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
            if (value.containsString("@")) {
                let names = getVariableNames(value)
                for name in names {
                    var replacement = "@" + name
                    
                    if let range = name.rangeOfString(".") {
                        let top = name.substringToIndex(range.startIndex)
                        let tail = name.substringFromIndex(range.startIndex.advancedBy(1))
                        if let variable = scope.variables[top] {
                            replacement = try walk(tail, object: variable)
                        }
                    } else if scope.variables[name] != nil {
                        replacement = "\(scope.variables[name]!)"
                    }
                    
                    value = value.stringByReplacingOccurrencesOfString("@\(name)", withString: replacement)
                }
                
                line.value = value
            }
        }
        
        return (line, scope)
    }
    
    func getVariableNames(value: String) -> [String] {
        var names = [String]()

        var name = ""
        for character in value.characters {
            if character == " " && name != "" {
                names.append(name)
                name = ""
            } else if character == "@" && name != "" {
                names.append(name)
                name = ""
            } else if character == " " && name == "" {
                // nothing
            } else if character == "@" && name == "" {
                // nothing
            } else {
                name.append(character)
            }
        }
        
        if name != "" {
            names.append(name)
        }
        
        return names
    }
    
    func walk(path: String, object: AnyObject) throws -> String {
        let parts = path.componentsSeparatedByString(".")

        return try walk(parts, object: object)
    }
    
    func walk(path: [String], object: AnyObject) throws -> String {
        if path.count < 1 {
            throw ReparoError.InvalidConfigurationLine("Invalid object path!")
        }
        
        let top = path[0]
        var remaining = path
        remaining.removeAtIndex(0)
        
        guard let object = object as? NSObject else {
            throw ReparoError.InvalidConfigurationLine("Object not an NSObject: \(top)")
        }
        
        if !object.respondsToSelector(Selector(top)) {
            throw ReparoError.InvalidConfigurationLine("Object does not respond to: \(top)")
        }
        
        guard let value = object.valueForKey(top) else {
            throw ReparoError.InvalidConfigurationLine("Object didn't respond to: \(top)")
        }
        
        if remaining.count == 0 {
            return "\(value)"
        }
        
        return try walk(remaining, object: value)
    }
}

