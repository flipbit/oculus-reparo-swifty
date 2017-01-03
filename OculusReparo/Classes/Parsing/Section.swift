//
//  Section.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

open class Section : Line {
    open var lines: [Line]
    
    override open var isASection: Bool {
        return true
    }
    
    public init(line: Line)
    {
        lines = []
        
        super.init(filename: line.filename, lineNumber: line.lineNumber)
        
        key = line.key
        value = line.value
        index = line.index
        directives.append(contentsOf: line.directives)
    }
    
    public init(filename: String)
    {
        lines = []
        
        super.init(filename: filename, lineNumber: 0)
    }
    
    public init(filename: String, lines: [Line])
    {
        self.lines = lines
        
        super.init(filename: filename, lineNumber: 0)
    }
    
    override open var path: String {
        if let id = getString("id") {
            return "#" + id
        } else {
            return super.path
        }
    }
    
    override open var sections: [Section] {
        var results: [Section] = []
        
        for line in lines {
            if let section = line as? Section {
                results.append(section)
            }
        }
        
        return results
    }
    
    override open func toString(_ pad: Int = 0) -> String {
        var string = String(repeating: String((" " as Character)), count: pad)
        
        if key != nil {
            string += key!
        } else {
            string += "(nil)"
        }
        
        string += ":"
        
        if value != nil {
            string += value!
        }
        
        if directives.count > 0 {
            string += " @if "
            for directive in directives {
                if directive.not {
                    string += "!"
                }
                string += directive.name
            }
        }
        
        string += " {  --> \(path)\n"
        
        for line in lines {
            string += "\(line.toString(pad + 4))\n"
        }
        
        string += String(repeating: String((" " as Character)), count: pad) + "}"
        
        return string
    }
    
    override open func clone() -> Line {
        let clone = Section(line: super.clone())

        for line in lines {
            let c = line.clone()
            
            c.parent = clone
            
            clone.lines.append(c)
        }
        
        return clone
    }
    
    open func addLine(_ line: Line) {
        line.parent = self
        line.index = lines.count + 1
        
        lines.append(line)
    }

    open func hasValue(_ name: String) -> Bool {
        for line in lines {
            if line.key == name {
                return true
            }
        }
        
        return false
    }

    open func getLine(_ names: String...) -> Line? {
        for name in names {
            for line in lines {
                if line.key == name {
                    return line
                }
            }
        }
        return nil
    }
    
    open func getString(_ name: String) -> String? {
        return getString(name, ifMissing: nil)
    }
    
    open func getString(_ name: String, ifMissing: String?) -> String? {
        for line in lines {
            if line.key == name {
                return line.value
            }
        }
        return ifMissing
    }

    open func getLineNumber(_ name: String) -> Int {
        for line in lines {
            if line.key == name {
                return line.lineNumber
            }
        }

        return 0
    }

    open func getFilename(_ name: String) -> String? {
        for line in lines {
            if line.key == name {
                return line.filename
            }
        }
        
        return nil
    }
    
    open func getFloat(_ name: String) -> Float? {
        let value = getString(name)
        
        return Convert.toFloat(value)
    }
    
    open func getFloat(_ name: String, ifMissing: Float) -> Float {
        let value = getString(name)
        
        return Convert.toFloat(value, ifMissing: ifMissing)
    }
    
    open func getCGFloat(_ name: String) -> CGFloat? {
        let value = getString(name)
        
        return Convert.toCGFloat(value)
    }
    
    open func getCGFloat(_ name: String, ifMissing: CGFloat) -> CGFloat {
        let value = getString(name)
        
        return Convert.toCGFloat(value, ifMissing: ifMissing)
    }
    
    open func getUIColor(_ name: String) throws -> UIColor? {
        return try getUIColor(name, ifMissing: nil)
    }
    
    open func getUIColor(_ name: String, ifMissing: UIColor?) throws -> UIColor? {
        if let value = getString(name) {
            return try Convert.toUIColor(value)
        }
        
        return ifMissing
    }
    
    open func getCGColor(_ name: String) throws -> CGColor? {
        return try getUIColor(name, ifMissing: UIColor.clear)?.cgColor
    }
    
    open func getCGColor(_ name: String, ifMissing: UIColor?) throws -> CGColor? {
        if let value = getString(name) {
            return try Convert.toUIColor(value).cgColor
        }
        
        return ifMissing?.cgColor
    }

    open func getBool(_ name: String) throws -> Bool? {
        if hasValue(name) {
            return try getBool(name, or: false)
        }
        
        return nil
    }
    
    open func getBool(_ name: String, or: Bool) throws -> Bool {
        if hasValue(name) {
            if let value = getString(name) {
                switch value.lowercased() {
                case "true": return true
                case "false": return false
                case "1": return true
                case "0": return false
                default: throw ReparoError.invalidColorString("Invalid boolean value: '\(value)'")
                }
            } else {
                return true                     // if empty, return true
            }
        } else if hasValue("!" + name) {
            return false                        // check for "!" value
        } else {
            return or
        }
    }
    
    open func getSection(_ name: String) -> Section? {
        return getSection(name, recurse: false)
    }
    
    open func getSection(_ name: String, recurse: Bool) -> Section? {
        var results = getSections(name, recurse: recurse)
        
        if results.count > 0 {
            return results[0]
        } else {
            return nil
        }
    }
    
    open func getSections(_ name: String) -> [Section] {
        return getSections(name, recurse: false)
    }
    
    open func getSections(_ name: String, recurse: Bool) -> [Section] {
        return getSections(name, recurse: recurse, search: lines)
    }
    
    fileprivate func getSections(_ name: String, recurse: Bool, search: [Line]) -> [Section] {
        var results: [Section] = []
        
        for line in search {
            if let section = line as? Section {
                if (section.key == name) {
                    results.append(section)
                }
                
                if recurse {
                    let children = getSections(name, recurse: recurse, search: section.lines)
                    
                    results.append(contentsOf: children)
                }
            }
        }
        
        return results
    }
}
