//
//  Directive.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

open class Directive {
    open var name: String
    open var not: Bool
    
    public init(name: String) {
        self.name = name
        self.not = false
    }
    
    public init(name: String, not: Bool) {
        self.name = name
        self.not = not
    }
    
    open func clone() -> Directive {
        return Directive(name: name, not: not)
    }
    
    open var isResolutionDirective: Bool {
        let trimmed = trim(name).lowercased()
        let hasEquality = trimmed.contains("=") || trimmed.contains("<") || trimmed.contains(">")
        
        if trimmed.hasPrefix("width") {
            return hasEquality
        }
        
        if trimmed.hasPrefix("height") {
            return hasEquality
        }
        
        return false
    }
    
    open func getResolutionParts() throws -> (dimension: Dimension, equality: Equality, value: CGFloat) {
        var dimension: Dimension
        var equality: Equality
        var value: CGFloat
        
        var toProcess = trim(name.lowercased())

        // Width?
        if toProcess.hasPrefix("width") {
            dimension = Dimension.width
            toProcess = toProcess.substring(from: toProcess.characters.index(toProcess.startIndex, offsetBy: 5))
        }
        
        // Height?
        else if name.hasPrefix("height") {
            dimension = Dimension.height
            toProcess = toProcess.substring(from: toProcess.characters.index(toProcess.startIndex, offsetBy: 6))
        }
        
        else {
            throw LayoutError.invalidConfiguration("Invalid resolution directive: \(name)\nDimension must be either 'width' or 'height'")
        }
        
        toProcess = trim(toProcess)

        // Equals
        if toProcess.hasPrefix("==") {
            equality = Equality.equal
            toProcess = toProcess.substring(from: toProcess.characters.index(toProcess.startIndex, offsetBy: 2))
        }
        else if toProcess.hasPrefix("=") {
            equality = Equality.equal
            toProcess = toProcess.substring(from: toProcess.characters.index(toProcess.startIndex, offsetBy: 1))
        }

        // Greater than or equal
        else if toProcess.hasPrefix(">=") {
            equality = Equality.greaterThanOrEqual
            toProcess = toProcess.substring(from: toProcess.characters.index(toProcess.startIndex, offsetBy: 2))
        }
            
        // Greater than
        else if toProcess.hasPrefix(">") {
            equality = Equality.greaterThan
            toProcess = toProcess.substring(from: toProcess.characters.index(toProcess.startIndex, offsetBy: 1))
        }
            
        // Less than or equal
        else if toProcess.hasPrefix("<=") {
            equality = Equality.lessThanOrEqual
            toProcess = toProcess.substring(from: toProcess.characters.index(toProcess.startIndex, offsetBy: 2))
        }
            
        // Less than
        else if toProcess.hasPrefix("<") {
            equality = Equality.lessThan
            toProcess = toProcess.substring(from: toProcess.characters.index(toProcess.startIndex, offsetBy: 1))
        }

        else {
            throw LayoutError.invalidConfiguration("Invalid resolution directive: \(name)\nEquality must be either '=', '>', '>=', '<' or '<='")
        }

        toProcess = trim(toProcess)

        let numerics = keepNumerics(toProcess)
        
        if numerics != toProcess {
            throw LayoutError.invalidConfiguration("Invalid resolution directive: \(name)\nValue must be a positive numeric value")
        }
        
        if let converted = Convert.toCGFloat(numerics) {
            value = converted
        } else {
            throw LayoutError.invalidConfiguration("Invalid resolution directive: \(name)\nUnable to convert value to a numeric value")
        }
        
        return (dimension, equality, value)
    }
    
    open func satisfiedBy(_ screenSize: CGSize) throws -> Bool {
        let parts = try getResolutionParts()
        
        var toCompare: CGFloat
        
        if parts.dimension == Dimension.height {
            toCompare = screenSize.height
        } else {
            toCompare = screenSize.width
        }
        
        switch parts.equality {
        case Equality.equal:
            return toCompare == parts.value
        case Equality.lessThan:
            return toCompare < parts.value
        case Equality.lessThanOrEqual:
            return toCompare <= parts.value
        case Equality.greaterThan:
            return toCompare > parts.value
        case Equality.greaterThanOrEqual:
            return toCompare >= parts.value
        }
    }
    
    func trim(_ value: String) -> String {
        return value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    func keepNumerics(_ value: String) -> String {
        return value.trimmingCharacters(in: CharacterSet(charactersIn: "1234567890.").inverted)
    }
    
    public enum Dimension {
        case width
        case height
    }
    
    public enum Equality {
        case equal
        case lessThan
        case lessThanOrEqual
        case greaterThan
        case greaterThanOrEqual
    }
}
