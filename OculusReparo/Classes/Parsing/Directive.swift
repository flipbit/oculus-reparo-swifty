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
    
    public var isResolutionDirective: Bool {
        let trimmed = trim(name).lowercaseString
        let hasEquality = trimmed.containsString("=") || trimmed.containsString("<") || trimmed.containsString(">")
        
        if trimmed.hasPrefix("width") {
            return hasEquality
        }
        
        if trimmed.hasPrefix("height") {
            return hasEquality
        }
        
        return false
    }
    
    public func getResolutionParts() throws -> (dimension: Dimension, equality: Equality, value: CGFloat) {
        var dimension: Dimension
        var equality: Equality
        var value: CGFloat
        
        var toProcess = trim(name.lowercaseString)

        // Width?
        if toProcess.hasPrefix("width") {
            dimension = Dimension.Width
            toProcess = toProcess.substringFromIndex(toProcess.startIndex.advancedBy(5))
        }
        
        // Height?
        else if name.hasPrefix("height") {
            dimension = Dimension.Height
            toProcess = toProcess.substringFromIndex(toProcess.startIndex.advancedBy(6))
        }
        
        else {
            throw LayoutError.InvalidConfiguration("Invalid resolution directive: \(name)\nDimension must be either 'width' or 'height'")
        }
        
        toProcess = trim(toProcess)

        // Equals
        if toProcess.hasPrefix("==") {
            equality = Equality.Equal
            toProcess = toProcess.substringFromIndex(toProcess.startIndex.advancedBy(2))
        }
        else if toProcess.hasPrefix("=") {
            equality = Equality.Equal
            toProcess = toProcess.substringFromIndex(toProcess.startIndex.advancedBy(1))
        }

        // Greater than or equal
        else if toProcess.hasPrefix(">=") {
            equality = Equality.GreaterThanOrEqual
            toProcess = toProcess.substringFromIndex(toProcess.startIndex.advancedBy(2))
        }
            
        // Greater than
        else if toProcess.hasPrefix(">") {
            equality = Equality.GreaterThan
            toProcess = toProcess.substringFromIndex(toProcess.startIndex.advancedBy(1))
        }
            
        // Less than or equal
        else if toProcess.hasPrefix("<=") {
            equality = Equality.LessThanOrEqual
            toProcess = toProcess.substringFromIndex(toProcess.startIndex.advancedBy(2))
        }
            
        // Less than
        else if toProcess.hasPrefix("<") {
            equality = Equality.LessThan
            toProcess = toProcess.substringFromIndex(toProcess.startIndex.advancedBy(1))
        }

        else {
            throw LayoutError.InvalidConfiguration("Invalid resolution directive: \(name)\nEquality must be either '=', '>', '>=', '<' or '<='")
        }

        toProcess = trim(toProcess)

        let numerics = keepNumerics(toProcess)
        
        if numerics != toProcess {
            throw LayoutError.InvalidConfiguration("Invalid resolution directive: \(name)\nValue must be a positive numeric value")
        }
        
        if let converted = Convert.toCGFloat(numerics) {
            value = converted
        } else {
            throw LayoutError.InvalidConfiguration("Invalid resolution directive: \(name)\nUnable to convert value to a numeric value")
        }
        
        return (dimension, equality, value)
    }
    
    public func satisfiedBy(screenSize: CGRect) throws -> Bool {
        let parts = try getResolutionParts()
        
        var toCompare: CGFloat
        
        if parts.dimension == Dimension.Height {
            toCompare = screenSize.height
        } else {
            toCompare = screenSize.width
        }
        
        switch parts.equality {
        case Equality.Equal:
            return toCompare == parts.value
        case Equality.LessThan:
            return toCompare < parts.value
        case Equality.LessThanOrEqual:
            return toCompare <= parts.value
        case Equality.GreaterThan:
            return toCompare > parts.value
        case Equality.GreaterThanOrEqual:
            return toCompare >= parts.value
        }
    }
    
    func trim(value: String) -> String {
        return value.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }

    func keepNumerics(value: String) -> String {
        return value.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "1234567890.").invertedSet)
    }
    
    public enum Dimension {
        case Width
        case Height
    }
    
    public enum Equality {
        case Equal
        case LessThan
        case LessThanOrEqual
        case GreaterThan
        case GreaterThanOrEqual
    }
}