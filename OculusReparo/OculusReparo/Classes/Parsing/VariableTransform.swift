//
//  VariableTransform.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

/**
 Performs variable substitution configuration
*/
public class VariableTransform : ReparoTransform {
    /**
     Performs variable substitution on the given configuration lines
     
     - Parameter lines:      The configuration to transform
     - Parameter parser:     The configuration parser the transform is being called from
     
     - Throws:               ReparoError if the configuration is invalid
     
     - Returns:              The transformed configuration lines
     */
    public func transform(lines: [Line], parser: Parser) throws -> [Line] {
        return try transform(lines, parser: parser, variables: parser.variables)
    }

    private func transform(lines: [Line], parser: Parser, variables: [String: String]) throws -> [Line] {
        var scope = variables
        for line in lines {
            scope = assign(line, variables: scope)
            line.value = substitute(line.value, variables: scope)
            
            if let section = line as? Section {
                try transform(section.lines, parser: parser, variables: scope)
            }
        }
        
        return lines
    }
    
    private func assign(line: Line, variables: [String: String]) -> [String: String] {
        var scope = variables
        if let key = line.key {
            if key.hasPrefix("@set") && key.characters.count > 5 {
                var name = key.substringFromIndex(key.startIndex.advancedBy(5))
                name = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if let value = line.value {
                    scope[name] = value
                }
            }
        }
        
        return scope
    }
    
    private func substitute(value: String?, variables: [String: String]) -> String? {
        if value != nil {
            var substituted = value!
            
            for key in variables.keys {
                if (value!.containsString("@\(key)")) {
                    substituted = substituted.stringByReplacingOccurrencesOfString("@\(key)", withString: variables[key]!)
                }
            }
            
            return substituted
        }
        
        return nil
    }
}