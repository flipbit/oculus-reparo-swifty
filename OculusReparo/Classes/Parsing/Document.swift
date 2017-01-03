//
//  Document.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

open class Document : Section {
    override open var path: String {
        return ""
    }
    
    open override func toString(_ pad: Int = 0) -> String {
        var string = ""
        
        for line in lines {
            string += "\(line.toString())\n"
        }
        
        return string
    }
    
    open func debug() {
        let lines = toString().components(separatedBy: "\n")
        
        for line in lines {
            print(line)
        }
    }
}
