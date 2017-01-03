import UIKit

/**
 Parser to read Reparo configuration files
 */
open class Parser {
    open var variables: [String: AnyObject]
    open var directives: [String]
    open var transforms: [Transform]
    open var expansions: [Expansion]
    open var screenSize: CGSize
    open var reader: ReparoReader
    
    public init() {
        variables = [:]
        directives = []
        transforms = []
        expansions = []
        screenSize = CGSize.zero
        
        transforms.append(DirectiveTransform())
        transforms.append(DefineFunctionTransform())
        transforms.append(DefineVariableTransform())
        transforms.append(ReplaceVariableTransform())
        transforms.append(ReduceTransform())
        
        expansions.append(IncludeExpansion())
        expansions.append(FunctionExpansion())
        expansions.append(EachExpansion())
        
        reader = BundleReader()
    }
    
    public convenience init(reader: ReparoReader) {
        self.init()
        
        self.reader = reader
    }

    public convenience init(layout: Layout) {
        self.init()
        
        self.variables = layout.variables
        self.directives = layout.directives
        self.screenSize = layout.bounds
    }
    
    /**
     Parses the given file into a configuration document
     
     - Parameter filename:      The filename to parse
     - Parameter runTransforms: A flag indicating whether to run the configuration transforms
     
     - Throws:              Reparo.InvalidConfigurationLine if the configuration is invalid
     
     - Returns:             A configuration document object
     */
    open func parseFile(_ filename: String) throws -> Document {
        if let input = try reader.readFile(filename) {
            return try parseString(input, filename: filename)
        } else {
            throw ReparoError.missingConfigurationFile(filename)
        }
    }
    
    /**
     Parses the given string into a configuration document
     
     - Parameter input:      The string to parse
     - Parameter filename:   The filename of the string being parsed
     
     - Throws:               Reparo.InvalidConfigurationLine if the configuration is invalid
     
     - Returns:              A configuration document object
     */
    open func parseString(_ input: String, filename: String) throws -> Document {
        let scope = Scope(parser: self)
        return try parseString(input, filename: filename, scope: scope)
    }
    
    /**
     Parses the given string into a configuration document
     
     - Parameter input:      The string to parse
     - Parameter filename:   The filename of the string being parsed
     - Parameter transform:  Flag indicating whether to transform the configuration
     
     - Throws:               Reparo.InvalidConfigurationLine if the configuration is invalid
     
     - Returns:              A configuration document object
     */
    open func parseString(_ input: String, filename: String, scope: Scope) throws -> Document {
        var document = Document(filename: filename)
        
        let machine = StateMachine(input: input, filename: filename)
        
        var index = 1
        
        while !machine.empty {
            let data = try machine.read()
            
            if data.endOfSection {
                break
            }
            
            if var line = data.line {
                if let section = line as? Section {
                    line = try parseSection(section, machine: machine)
                }
                
                line.parent = document
                line.index = index
                
                document.lines.append(line)
                
                index += 1
            }
        }
        
        document = try transform(document, scope: scope)
        
        return document
    }
    
    fileprivate func parseSection(_ section: Section, machine: StateMachine) throws -> Section {
        var index = 1
        var seenEnd = false
        while !machine.empty {
            let data = try machine.read()

            if data.endOfSection {
                seenEnd = true
                break
            }

            if data.endOfDocument {
                throw ReparoError.missingSectionEnd("Section end is missing: \(section.key) Line: \(section.lineNumber)")
            }            
            
            if var line = data.line {
                if let section = line as? Section {
                    line = try parseSection(section, machine: machine)
                }
                
                line.parent = section
                line.index = index
                
                section.lines.append(line)
                index += 1
            }
        }
        
        if !seenEnd {
            if section.key != nil {
                throw ReparoError.missingSectionEnd("Section end is missing: \(section.key) Line: \(section.lineNumber)")
            } else {
                throw ReparoError.missingSectionEnd("Section end is missing: Line: \(section.lineNumber)")
            }
        }
        
        return section
    }
    
    func transform(_ document: Document, scope: Scope) throws -> Document {
        let result = Document(filename: document.filename)
        
        result.lines = try transform(document.lines, scope: scope)

        // Set parent & re-index
        if result.lines.count > 0 {
            for i in 0...(result.lines.count - 1) {
                result.lines[i].parent = result
                result.lines[i].index = i + 1
            }
        }
        
        return result
    }
    
    func transform(_ section: Section, scope: Scope) throws -> Section {
        let result = Section(line: section)
        
        result.lines = try transform(section.lines, scope: scope)
        
        // Set parent & re-index
        if result.lines.count > 0 {
            for i in 0...(result.lines.count - 1) {
                result.lines[i].parent = result
                result.lines[i].index = i + 1
            }
        }
        
        return result
    }
    
    func transform(_ lines: [Line], scope: Scope) throws -> [Line] {
        var result = [Line]()
        var local = scope
        
        local.depth += 1
        
        if local.depth > 255 {
            throw ReparoError.recursiveIncludeDetected
        }
        
        loop: for line in lines {
            var transformed: Line? = line
            
            for transform in transforms {
                let result = try transform.transform(transformed!, scope: local)
                
                local = result.scope
                
                if result.line == nil {
                    continue loop
                } else {
                    transformed = result.line
                }
            }

            if let section = line as? Section {
                transformed = try transform(section, scope: local)
            }
            
            let expanded = try expand(transformed!, scope: local)
            
            result.append(contentsOf: expanded)
        }
        
        return result
    }
    
    func expand(_ line: Line, scope: Scope) throws -> [Line] {
        for expansion in expansions {
            if let lines = try expansion.expand(line, scope: scope, parser: self) {
                return lines
            }
        }
        
        return [Line](arrayLiteral: line)
    }

}
