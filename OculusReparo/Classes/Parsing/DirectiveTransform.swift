import Foundation

public class DirectiveTransform : Transform {
    public func transform(line: Line, scope: Scope) throws -> (line: Line?, scope: Scope) {
        if line.directives.count > 0 {
            var include = true
            
            for directive in line.directives {
                let matches = scope.directives.filter { d in d == directive.name }.count
                
                include = matches > 0
                
                if directive.not {
                    include = !include
                }
                
                if !include {
                    break
                }
            }
            
            if !include {
                return (nil, scope)
            }
        }
        
        return (line, scope)
    }
}