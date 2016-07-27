//
//  Line.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public class Line {
    public var key: String?
    public var value: String?
    public var filename: String
    public var lineNumber: Int
    public var directives: [Directive]
    public var parent: Section?
    public var index: Int
    public var quoted: Bool
    
    public var isASection: Bool {
        return false
    }
        
    public init(filename: String, lineNumber: Int) {
        directives = []
        index = 0
        quoted =  false
        
        self.filename = filename
        self.lineNumber = lineNumber
    }
    
    public var sections: [Section] {
        return []
    }
    
    public var path: String {
        let key = self.key ?? ""
        
        if (parent != nil) {
            return parent!.path + "/\(key)[\(index)]"
        }
        
        return "/\(key)[\(index)]"
    }
    
    public func clone() -> Line {
        let clone = Line(filename: filename, lineNumber: lineNumber)
        
        clone.key = key
        clone.value = value
        clone.parent = parent
        clone.index = index
        
        for directive in directives {
            clone.directives.append(directive.clone())
        }
        
        return clone
    }
    
    public func toString(pad: Int = 0) -> String {
        var string = String(count: pad, repeatedValue: (" " as Character))
        
        if key != nil {
            string += key!
        } else {
            string += "(nil)"
        }
        
        string += ":"
        
        if value != nil {
            string += value!
        } else {
            string += "(nil)"
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

        string += ";  -> \(path)"
        
        return string
    }
}