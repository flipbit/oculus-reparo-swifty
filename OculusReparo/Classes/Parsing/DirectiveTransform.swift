import Foundation

open class DirectiveTransform : Transform {
    open func transform(_ line: Line, scope: Scope) throws -> (line: Line?, scope: Scope) {
        let satisfied = try scope.satisfiesDirectives(line)
        
        // return nil if line not satisfied
        if !satisfied {
            return (nil, scope)
        }
        
        return (line, scope)
    }
}
