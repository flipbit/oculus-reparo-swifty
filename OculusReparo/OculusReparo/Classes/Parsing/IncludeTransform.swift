//
//  IncludeTransform.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public class IncludeTransform : ReparoTransform {
    var includeCount = 0
    var includeLimit = 0
    public func transform(lines: [Line], parser: Parser) throws -> [Line] {
        includeCount = 1
        includeLimit = 0
        
        var transformed: [Line] = lines
        while (includeCount > 0) {
            transformed = try expand(transformed, parser: parser)
            
            if (includeLimit > 255) {
                throw ReparoError.RecursiveIncludeDetected
            }
        }
        
        return transformed
    }
    
    private func expand (lines: [Line], parser: Parser) throws -> [Line] {
        includeCount = 0
        includeLimit = includeLimit + 1
        
        var transformed: [Line] = []
        
        for line in lines {
            if line.key != nil && line.key!.hasPrefix("@include") {
                if let filename = line.value {
                    
                    // Read include file
                    let input = try parser.reader.readIncludeFile(filename)
                    
                    // Check exists
                    if input == nil {
                        throw ReparoError.MissingConfigurationFile(filename)
                    }
                    
                    // Parse include
                    let include = try parser.parseString(input!, filename: filename, runTransforms: false)
                    
                    // Append child lines (include arguments)
                    if let section = line as? Section {
                        transformed.appendContentsOf(section.lines)
                    }
                    
                    // Append include
                    transformed.appendContentsOf(include.lines)
                    
                    includeCount = includeCount + 1
                }
            } else if let section = line as? Section {
                section.lines = try expand(section.lines, parser: parser)
                transformed.append(section)
            } else {
                transformed.append(line)
            }
        }
        
        return transformed
    }
}