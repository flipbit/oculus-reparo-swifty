//
//  Document.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public class Document : Section {
    override public var path: String {
        return ""
    }
    
    public override func toString(pad: Int = 0) -> String {
        var string = ""
        
        for line in lines {
            string += "\(line.toString())\n"
        }
        
        return string
    }
    
    public func debug() {
        let lines = toString().componentsSeparatedByString("\n")
        
        for line in lines {
            print(line)
        }
    }
}
