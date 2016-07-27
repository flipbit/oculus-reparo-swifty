//
//  Directive.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public class Directive {
    public var name: String
    public var not: Bool
    
    public init(name: String) {
        self.name = name
        self.not = false
    }
    
    public init(name: String, not: Bool) {
        self.name = name
        self.not = not
    }
    
    public func clone() -> Directive {
        return Directive(name: name, not: not)
    }
}