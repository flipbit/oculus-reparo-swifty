//
//  FunctionTransform.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

/**
 Declares and inserts configuration functions
 */
public class FunctionTransform : ReparoTransform {
    public func transform(lines: [Line], parser: Parser) throws -> [Line] {
        return transform(lines, parser: parser, functions: [String: [Line]]())
    }
    
    private func transform(lines: [Line], parser: Parser, functions: [String: [Line]]) -> [Line] {
        var transformed = [Line]()
        var scope = functions
        var count = 1
        
        for line in lines {
            scope = assign(line, functions: scope)
            
            line.index = count
            count += 1
            
            if isFunctionCall(line, functions: scope) {
                let substituted = substitute(line, functions: scope)
                for l in substituted {
                    l.index = count
                    l.parent = line.parent
                    transformed.append(l)
                    count += 1
                }
            } else if let section = line as? Section {
                section.lines = transform(section.lines, parser: parser, functions: scope)
                transformed.append(section)
            } else {
                transformed.append(line)
            }
        }
        
        return transformed
    }
    
    private func assign(line: Line, functions: [String: [Line]]) -> [String: [Line]] {
        var scope = functions
        if let key = line.key, name = line.value, function = line as? Section where key == "@define" {
            scope[name] = function.lines
        }
        
        return scope
    }

    private func isFunctionCall(line: Line, functions: [String: [Line]]) -> Bool {
        if let key = line.key where key.hasPrefix("@") {
            let name = key.substringFromIndex(key.startIndex.advancedBy(1))
            return functions[name] != nil
        }
        
        return false
    }
    
    private func substitute(line: Line, functions: [String: [Line]]) -> [Line] {
        if let key = line.key where key.hasPrefix("@") {
            let name = key.substringFromIndex(key.startIndex.advancedBy(1))
            if let function = functions[name] {
                var lines = [Line]()
                
                // Add function arguments
                if let arguments = line as? Section {
                    for argument in arguments.lines {
                        if let key = argument.key {
                            argument.key = "@set " + key
                            lines.append(argument)
                        }
                    }
                }
                
                for line in function {
                    lines.append(line.clone())
                }
                
                return lines
            }
        }
        
        return [Line] (arrayLiteral: line)
    }
}