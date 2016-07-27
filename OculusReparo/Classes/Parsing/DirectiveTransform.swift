//
//  DirectiveTransform.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public class DirectiveTransform : ReparoTransform {
    public func transform(lines: [Line], parser: Parser) throws -> [Line] {
        var transformed: [Line] = []
        for line in lines {
            if line.directives.count > 0 {
                var include = true
                
                for directive in line.directives {
                    let matches = parser.directives.filter { d in d == directive.name }.count
                    
                    include = matches > 0
                    
                    if directive.not {
                        include = !include
                    }
                    
                    if !include {
                        break
                    }
                }
                
                if !include {
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
}