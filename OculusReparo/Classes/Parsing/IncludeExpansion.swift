public class IncludeExpansion : Expansion {
    public func expand(line: Line, scope: Scope, parser: Parser) throws -> [Line]? {
        // Line must have a key
        guard let key = line.key else {
            return nil
        }
        
        // Key must be "@include"
        if key.caseInsensitiveCompare("@include") != NSComparisonResult.OrderedSame {
            return nil
        }

        // Line must have a value
        guard let filename = line.value else {
            return nil
        }

        // Read include file
        let include = try parser.reader.readIncludeFile(filename)
        
        // Check exists
        if include == nil {
            throw ReparoError.MissingConfigurationFile(filename)
        }
        
        // Parse include
        let document = try parser.parseString(include!, filename: filename, scope: scope)

        // Transform include
        return document.lines
    }
}
