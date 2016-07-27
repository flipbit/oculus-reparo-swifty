//
//  Section.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public class Section : Line {
    public var lines: [Line]
    
    override public var isASection: Bool {
        return true
    }
    
    init(line: Line)
    {
        lines = []
        
        super.init(filename: line.filename, lineNumber: line.lineNumber)
        
        key = line.key
        value = line.value
        index = line.index
        directives.appendContentsOf(line.directives)
    }
    
    init(filename: String)
    {
        lines = []
        
        super.init(filename: filename, lineNumber: 0)
    }
    
    init(filename: String, lines: [Line])
    {
        self.lines = lines
        
        super.init(filename: filename, lineNumber: 0)
    }
    
    override public var path: String {
        if let id = getValue("id") {
            return "#" + id
        } else {
            return super.path
        }
    }
    
    override public var sections: [Section] {
        var results: [Section] = []
        
        for line in lines {
            if let section = line as? Section {
                results.append(section)
            }
        }
        
        return results
    }
    
    override public func toString(pad: Int = 0) -> String {
        var string = String(count: pad, repeatedValue: (" " as Character))
        
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
        
        string += String(count: pad, repeatedValue: (" " as Character)) + "}"
        
        return string
    }
    
    override public func clone() -> Line {
        let clone = Section(line: super.clone())

        for line in lines {
            let c = line.clone()
            
            c.parent = clone
            
            clone.lines.append(c)
        }
        
        return clone
    }

    func hasValue(name: String) -> Bool {
        for line in lines {
            if line.key == name {
                return true
            }
        }
        
        return false
    }
    
    func getValue(name: String) -> String? {
        return getValue(name, ifMissing: nil)
    }
    
    func getValue(name: String, ifMissing: String?) -> String? {
        for line in lines {
            if line.key == name {
                return line.value
            }
        }
        return ifMissing
    }
    
    func getFloat(name: String) -> Float? {
        let value = getValue(name)
        
        return Convert.toFloat(value)
    }
    
    func getFloat(name: String, ifMissing: Float) -> Float {
        let value = getValue(name)
        
        return Convert.toFloat(value, ifMissing: ifMissing)
    }
    
    func getCGFloat(name: String) -> CGFloat? {
        let value = getValue(name)
        
        return Convert.toCGFloat(value)
    }
    
    func getCGFloat(name: String, ifMissing: CGFloat) -> CGFloat {
        let value = getValue(name)
        
        return Convert.toCGFloat(value, ifMissing: ifMissing)
    }
    
    func getUIColor(name: String) throws -> UIColor? {
        return try getUIColor(name, ifMissing: UIColor.clearColor())
    }
    
    func getUIColor(name: String, ifMissing: UIColor?) throws -> UIColor? {
        if let value = getValue(name) {
            return try Convert.toUIColor(value)
        }
        
        return ifMissing
    }
    
    func getCGColor(name: String) throws -> CGColor? {
        return try getUIColor(name, ifMissing: UIColor.clearColor())?.CGColor
    }
    
    func getCGColor(name: String, ifMissing: UIColor?) throws -> CGColor? {
        if let value = getValue(name) {
            return try Convert.toUIColor(value).CGColor
        }
        
        return ifMissing?.CGColor
    }

    func getBool(name: String) throws -> Bool {
        return try getBool(name, ifMissing: false)
    }
    
    func getBool(name: String, ifMissing: Bool) throws -> Bool {
        if hasValue(name) {
            if let value = getValue(name) {
                switch value.lowercaseString {
                case "true": return true
                case "false": return false
                case "1": return true
                case "0": return false
                default: throw ReparoError.InvalidColorString("Invalid boolean value: '\(value)'")
                }
            } else {
                return true                     // if empty, return true
            }
        } else if hasValue("!" + name) {
            return false                        // check for "!" value
        } else {
            return ifMissing
        }
    }
    
    public func getSection(name: String) -> Section? {
        return getSection(name, recurse: false)
    }
    
    public func getSection(name: String, recurse: Bool) -> Section? {
        var results = getSections(name, recurse: recurse)
        
        if results.count > 0 {
            return results[0]
        } else {
            return nil
        }
    }
    
    public func getSections(name: String) -> [Section] {
        return getSections(name, recurse: false)
    }
    
    public func getSections(name: String, recurse: Bool) -> [Section] {
        return getSections(name, recurse: recurse, search: lines)
    }
    
    private func getSections(name: String, recurse: Bool, search: [Line]) -> [Section] {
        var results: [Section] = []
        
        for line in search {
            if let section = line as? Section {
                if (section.key == name) {
                    results.append(section)
                }
                
                if recurse {
                    let children = getSections(name, recurse: recurse, search: section.lines)
                    
                    results.appendContentsOf(children)
                }
            }
        }
        
        return results
    }
}