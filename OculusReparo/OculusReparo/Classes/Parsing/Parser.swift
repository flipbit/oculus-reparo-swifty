//
//  Parser.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation



/**
 Parser to read Reparo configuration files
 */
public class Parser {
    var variables: [String: String]
    var directives: [String]
    var transforms: [ReparoTransform]
    var reader: ReparoReader
    
    init() {
        variables = [:]
        directives = []
        transforms = []
        
        transforms.append(IncludeTransform())
        transforms.append(FunctionTransform())
        transforms.append(VariableTransform())
        transforms.append(DirectiveTransform())
        transforms.append(ReduceTransform())
        transforms.append(ReduceSectionTransform())
        
        reader = BundleReader()
    }
    
    convenience init(reader: ReparoReader) {
        self.init()
        
        self.reader = reader
    }
    
    /**
     Parses the given file into a configuration document
     
     - Parameter filename:  The filename to parse
     
     - Throws:              Reparo.InvalidConfigurationLine if the configuration is invalid
     
     - Returns:             A configuration document object
     */
    public func parseFile(filename: String) throws -> Document {
        return try parseFile(filename, runTransforms: true)
    }
    
    /**
     Parses the given file into a configuration document
     
     - Parameter filename:      The filename to parse
     - Parameter runTransforms: A flag indicating whether to run the configuration transforms
     
     - Throws:              Reparo.InvalidConfigurationLine if the configuration is invalid
     
     - Returns:             A configuration document object
     */
    public func parseFile(filename: String, runTransforms: Bool) throws -> Document {
        if let input = try reader.readFile(filename) {
            return try parseString(input, filename: filename, runTransforms: runTransforms)
        } else {
            throw ReparoError.MissingConfigurationFile(filename)
        }
    }
    
    /**
     Parses the given string into a configuration document
     
     - Parameter input:      The string to parse
     - Parameter filename:   The filename of the string being parsed
     
     - Throws:               Reparo.InvalidConfigurationLine if the configuration is invalid
     
     - Returns:              A configuration document object
     */
    public func parseString(input: String, filename: String) throws -> Document {
        return try parseString(input, filename: filename, runTransforms: true)
    }
    
    /**
     Parses the given string into a configuration document
     
     - Parameter input:      The string to parse
     - Parameter filename:   The filename of the string being parsed
     - Parameter transform:  Flag indicating whether to transform the configuration
     
     - Throws:               Reparo.InvalidConfigurationLine if the configuration is invalid
     
     - Returns:              A configuration document object
     */
    public func parseString(input: String, filename: String, runTransforms: Bool) throws -> Document {
        var document = Document(filename: filename)
        
        let machine = StateMachine(input: input, filename: filename)
        
        var index = 1
        
        while !machine.empty {
            var line = try machine.read()
            
            if line == nil {
                break
            }
            
            if let section = line as? Section {
                line = try parseSection(section, machine: machine)
            }
            
            line!.parent = document
            line!.index = index
            
            document.lines.append(line!)
            
            index += 1
        }
                
        if (runTransforms) {
            document = try transform(document)
        }
        
        return document
    }
    
    private func parseSection(section: Section, machine: StateMachine) throws -> Section {
        var index = 1
        var seenEnd = false
        while !machine.empty {
            var line = try machine.read()
            
            if line == nil {
                throw ReparoError.MissingSectionEnd("Section end is missing: \(section.key) Line: \(section.lineNumber)")
            }
            
            if line!.isEndOfSection {
                seenEnd = true
                break
            }
            
            if let section = line as? Section {
                line = try parseSection(section, machine: machine)
            }
            
            line!.parent = section
            line!.index = index
            
            section.lines.append(line!)
            index += 1
        }
        
        if !seenEnd {
            if section.key != nil {
                throw ReparoError.MissingSectionEnd("Section end is missing: \(section.key) Line: \(section.lineNumber)")
            } else {
                throw ReparoError.MissingSectionEnd("Section end is missing: Line: \(section.lineNumber)")
            }
        }
        
        return section
    }
    
    public func transform(document: Document) throws -> Document {
        let transformed = document
        if transformed.lines.count > 0 {
            for transform in transforms {
                transformed.lines = try transform.transform(transformed.lines, parser: self)
                
                if transformed.lines.count == 0 {
                    throw ReparoError.InvalidConfigurationLine("oops")
                }
            }
        }
        
        return transformed
    }
}
