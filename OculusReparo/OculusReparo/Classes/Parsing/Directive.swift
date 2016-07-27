//
//  Directive.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public class Directive {
    var name: String
    var not: Bool
    
    init(name: String) {
        self.name = name
        self.not = false
    }
    
    init(name: String, not: Bool) {
        self.name = name
        self.not = not
    }
    
    func clone() -> Directive {
        return Directive(name: name, not: not)
    }
}