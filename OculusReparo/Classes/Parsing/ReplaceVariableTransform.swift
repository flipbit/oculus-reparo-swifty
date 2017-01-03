/**
 Performs variable substitution configuration
*/
open class ReplaceVariableTransform : Transform {
    /**
     Performs variable substitution on the given configuration lines
     
     - Parameter lines:      The configuration to transform
     - Parameter parser:     The configuration parser the transform is being called from
     
     - Throws:               ReparoError if the configuration is invalid
     
     - Returns:              The transformed configuration lines
     */
    open func transform(_ line: Line, scope: Scope) throws -> (line: Line?, scope: Scope) {
        if var value = line.value, !line.quoted {
            if (value.contains("@")) {
                let names = getVariableNames(value)
                for name in names {
                    var replacement = "@" + name
                    
                    if let range = name.range(of: ".") {
                        let top = name.substring(to: range.lowerBound)
                        let tail = name.substring(from: name.index(range.lowerBound, offsetBy: 1))
                        if let variable = scope.variables[top] {
                            replacement = try walk(tail, object: variable)
                        }
                    } else if scope.variables[name] != nil {
                        replacement = "\(scope.variables[name]!)"
                    }
                    
                    value = value.replacingOccurrences(of: "@\(name)", with: replacement)
                }
                
                line.value = value
            }
        }
        
        return (line, scope)
    }
    
    func getVariableNames(_ value: String) -> [String] {
        var names = [String]()

        var name = ""
        for character in value.characters {
            if character == " " && name != "" {
                names.append(name)
                name = ""
            } else if character == "@" && name != "" {
                names.append(name)
                name = ""
            } else if character == "_" && name != "" {
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
    
    func walk(_ path: String, object: AnyObject) throws -> String {
        let parts = path.components(separatedBy: ".")

        return try walk(parts, object: object)
    }
    
    func walk(_ path: [String], object: AnyObject) throws -> String {
        if path.count < 1 {
            throw ReparoError.invalidConfigurationLine("Invalid object path!")
        }
        
        let top = path[0]
        var remaining = path
        remaining.remove(at: 0)
        
        guard let object = object as? NSObject else {
            throw ReparoError.invalidConfigurationLine("Object not an NSObject: \(top)")
        }
        
        if !object.responds(to: Selector(top)) {
            throw ReparoError.invalidConfigurationLine("Object does not respond to: \(top)")
        }
        
        guard let value = object.value(forKey: top) else {
            throw ReparoError.invalidConfigurationLine("Object didn't respond to: \(top)")
        }
        
        if remaining.count == 0 {
            return "\(value)"
        }
        
        return try walk(remaining, object: value as AnyObject)
    }
}

