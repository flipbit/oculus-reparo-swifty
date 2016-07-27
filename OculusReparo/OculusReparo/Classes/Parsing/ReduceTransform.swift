import Foundation

public class ReduceTransform : ReparoTransform {
    public func transform(lines: [Line], parser: Parser) throws -> [Line] {
        var transformed: [Line] = []
        var reduced: [Line] = []
        for line in lines {            
            if let section = line as? Section {
                section.lines = try transform(section.lines, parser: parser)
                
                if section.directives.count > 0 && section.key == nil {
                    reduced.appendContentsOf(section.lines)
                }
                
                transformed.append(section)
            } else {
                transformed.append(line)
            }
        }
        
        for reduce in reduced {
            if let key = reduce.key {
                transformed = removeKeys(transformed, key: key)
            }
            
            transformed.append(reduce)
        }
        
        return transformed
    }
    
    func removeKeys(lines: [Line], key: String) -> [Line] {
        return lines.filter { line in line.key != key }
    }
}

public class ReduceSectionTransform : ReparoTransform {
    public func transform(lines: [Line], parser: Parser) throws -> [Line] {
        var transformed: [Line] = []
        
        for line in lines {
            // Don't include duplicate sections if they have directives
            if hasMultipleKeys(lines, key: line.key) {
                if line.directives.count < maxDirectiveCount(lines, key: line.key) {
                    continue
                }
            }
            
            if let section = line as? Section {
                section.lines = try transform(section.lines, parser: parser)
                
                transformed.append(section)
            } else {
                transformed.append(line)
            }
        }
        
        return transformed
    }
    
    func hasMultipleKeys(lines: [Line], key: String?) -> Bool {
        guard let key = key else {
            return false
        }
        
        var count = 0
        
        for line in lines {
            if line.key == key {
                count += 1
            }
        }
        
        return count > 1
    }
    
    func maxDirectiveCount(lines: [Line], key: String?) -> Int {
        guard let key = key else {
            return 0
        }
        
        var count = 0
        
        for line in lines {
            if line.key == key {
                if line.directives.count > count {
                    count = line.directives.count
                }
            }
        }
        
        return count
    }
}