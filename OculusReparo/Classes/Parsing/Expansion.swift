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

public class EachExpansion : Expansion {
    public func expand(line: Line, scope: Scope, parser: Parser) throws -> [Line]? {
        // Line must have a key
        guard let key = line.key else {
            return nil
        }
        
        // Key must be "@each"
        if key.caseInsensitiveCompare("@each") != NSComparisonResult.OrderedSame {
            return nil
        }

        // Line must have a value
        guard let value = line.value else {
            return nil
        }
        
        // Must be a section
        guard let section = line as? Section else {
            return nil
        }

        // Get variable
        guard let variable = scope.variables[value] else {
            throw ReparoError.InvalidConfigurationLine("Missing variable for each loop: \(value)")
        }

        // Cast to array
        guard let list = variable as? [AnyObject] else {
            throw ReparoError.InvalidConfigurationLine("Each variable must be an array: \(value)")
        }

        // Set variable name
        var name = value
        //if name.hasSuffix("es") && name.characters.count > 2 {
        //    name = name.substringToIndex(name.endIndex.advancedBy(-2))
        //} else
        if name.hasSuffix("s") && name.characters.count > 2 {
            name = name.substringToIndex(name.endIndex.advancedBy(-1))
        }
        
        var expanded = [Line]()

        // Iterate array
        for item in list {
            var lines = [Line]()
            
            // Set scope
            scope.variables[name] = item
            
            // Iterate each section contents
            for line in section.lines {
                
                // Add cloned line
                lines.append(line.clone())
            }

            // Transform loop iteration
            lines = try parser.transform(lines, scope: scope)
            
            expanded.appendContentsOf(lines)
        }
        
        return expanded
    }
}