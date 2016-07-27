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
public protocol Transform {
    
    /**
     Transforms the given configuration lines
     
     - Parameter line:      The configuration line to transform
     - Parameter parser:    The configuration parser the transform is being called from
     
     - Throws:              ReparoError if the configuration is invalid
     
     - Returns:             The transformed configuration line
     */
    func transform(line: Line, scope: Scope) throws -> (line: Line?, scope: Scope)
}