//
//  ReparoTransform.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

/**
 A transform alters a collection configuration lines
 */
public protocol ReparoTransform {
    
    /**
     Transforms the given configuration lines
     
     - Parameter lines:      The configuration to transform
     - Parameter parser:     The configuration parser the transform is being called from
     
     - Throws:               ReparoError if the configuration is invalid
     
     - Returns:              The transformed configuration lines
     */
    func transform(lines: [Line], parser: Parser) throws -> [Line]
}