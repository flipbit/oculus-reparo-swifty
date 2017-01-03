//
//  Line.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

open class Line {
    open var key: String?
    open var value: String?
    open var filename: String
    open var lineNumber: Int
    open var directives: [Directive]
    open var parent: Section?
    open var index: Int
    open var quoted: Bool
    
    open var isASection: Bool {
        return false
    }
    
    public convenience init() {
        self.init(filename: "", lineNumber: 0)
    }
    
    public init(filename: String, lineNumber: Int) {
        directives = []
        index = 0
        quoted =  false
        
        self.filename = filename
        self.lineNumber = lineNumber
    }
    
    open var sections: [Section] {
        return []
    }
    
    open var path: String {
        let key = self.key ?? ""
        
        if (parent != nil) {
            return parent!.path + "/\(key)[\(index)]"
        }
        
        return "/\(key)[\(index)]"
    }
    
    open func clone() -> Line {
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
    
    open func toString(_ pad: Int = 0) -> String {
        var string = String(repeating: String((" " as Character)), count: pad)
        
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
