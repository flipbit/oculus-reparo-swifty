//
//  Position.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public class Position {
    public enum HorizontalAlignment : String {
        case Left = "left"
        case Center = "center"
        case Right = "right"
    }
    
    public enum VerticalAlignment : String {
        case Top = "top"
        case Middle = "middle"
        case Bottom = "bottom"
    }
    
    private var parent: UIView
    
    var top: String?
    var left: String?
    var width: String?
    var height: String?
    var horizontalAlignment: HorizontalAlignment
    var verticalAlignment: VerticalAlignment
    
    var paddingTop: String?
    var paddingLeft: String?
    var paddingRight: String?
    var paddingBottom: String?

    var offsetTop: String?
    var offsetLeft: String?
    var offsetWidth: String?
    var offsetHeight: String?
    
    init(parent: UIView) {
        top = "0"
        left = "0"
        width = "100%"
        height = "100%"
        horizontalAlignment = HorizontalAlignment.Left
        verticalAlignment = VerticalAlignment.Top
        
        self.parent = parent
    }
    
    init(section: Section, parent: UIView) throws {
        top = section.getValue("top", ifMissing: "0")
        left = section.getValue("left", ifMissing: "0")
        width = section.getValue("width", ifMissing: "100%")
        height = section.getValue("height", ifMissing: "100%")
        
        if let align = section.getValue("horizontal-align", ifMissing: "left") {
            horizontalAlignment = HorizontalAlignment(rawValue: align)!
        } else {
            horizontalAlignment = HorizontalAlignment.Left
        }
        
        if let align = section.getValue("vertical-align", ifMissing: "top") {
            verticalAlignment = VerticalAlignment(rawValue: align)!
        } else {
            verticalAlignment = VerticalAlignment.Top
        }
        
        if let padding = section.getValue("padding") {
            let padding = try Convert.getPadding(padding)
            
            paddingTop = padding.top
            paddingLeft = padding.left
            paddingBottom = padding.bottom
            paddingRight = padding.right
        }
        
        paddingTop = section.getValue("padding-top", ifMissing: paddingTop)
        paddingLeft = section.getValue("padding-left", ifMissing: paddingLeft)
        paddingRight = section.getValue("padding-right", ifMissing: paddingRight)
        paddingBottom = section.getValue("padding-bottom", ifMissing: paddingBottom)

        if let offset = section.getValue("offset") {
            let offset = try Convert.getOffset(offset)
            
            offsetTop = offset.top
            offsetLeft = offset.left
            offsetWidth = offset.width
            offsetHeight = offset.height
        }
        
        offsetTop = section.getValue("offset-top", ifMissing: offsetTop)
        offsetLeft = section.getValue("offset-left", ifMissing: offsetLeft)
        offsetWidth = section.getValue("offset-width", ifMissing: offsetWidth)
        offsetHeight = section.getValue("offset-height", ifMissing: offsetHeight)
        
        self.parent = parent
        
        if let alignment = section.getValue("align") {
            setAlignment(alignment)
        }
    }
    
    func toFrame() -> CGRect {
        // Get dimensions (absolute or percentage)
        var x = getDimension(left, parent: parent.frame.size.width)
        var y = getDimension(top, parent: parent.frame.size.height)
        var w = getDimension(width, parent: parent.frame.size.width)
        var h = getDimension(height, parent: parent.frame.size.height)
        
        // Set relative x value
        if left != nil && left!.hasPrefix("+") {
            for child in parent.subviews.reverse() {
                if child.hidden {
                    continue;
                }
                
                x = x + child.frame.origin.x + child.frame.width;
                
                break;
            }
        }
        
        // Set relative y value
        if top != nil && top!.hasPrefix("+") {
            for child in parent.subviews.reverse() {
                if child.hidden {
                    continue;
                }
                
                y = y + child.frame.origin.y + child.frame.height;
                
                break;
            }
        }
        
        // Set fills
        if width == "fill" {
            w = parent.frame.width - x
        }        
        if height == "fill" {
            h = parent.frame.height - y
        }
        
        // Set horizontal alignment
        switch horizontalAlignment {
        case HorizontalAlignment.Left:
            break;
        case HorizontalAlignment.Center:
            x = (parent.frame.size.width / 2) - (w / 2);
            break;
        case HorizontalAlignment.Right:
            x = parent.frame.width - w - x;
            break;
        }
        
        // Set vertical alignment
        switch (verticalAlignment) {
        case VerticalAlignment.Top:
            break;
        case VerticalAlignment.Middle:
            y = (parent.frame.height / 2) - (h / 2);
            break;
        case VerticalAlignment.Bottom:
            y = parent.frame.height - y - h;
            break;
        }
        
        // Set padding
        let paddingTop = getDimension(self.paddingTop, parent: parent.frame.size.height)
        let paddingLeft = getDimension(self.paddingLeft, parent: parent.frame.size.width)
        let paddingRight = getDimension(self.paddingRight, parent: parent.frame.size.width)
        let paddingBottom = getDimension(self.paddingBottom, parent: parent.frame.size.height)

        // Top
        y += paddingTop
        h -= paddingTop
    
        // Left
        x += paddingLeft
        w -= paddingLeft
    
        // Right
        w -= paddingRight
    
        // Bottom
        h -= paddingBottom

        // Set offsets
        let offsetTop = getDimension(self.offsetTop, parent: parent.frame.size.height)
        let offsetLeft = getDimension(self.offsetLeft, parent: parent.frame.size.width)
        let offsetWidth = getDimension(self.offsetWidth, parent: parent.frame.size.width)
        let offsetHeight = getDimension(self.offsetHeight, parent: parent.frame.size.height)
        
        y += offsetTop
        x += offsetLeft
        w += offsetWidth
        h += offsetHeight
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    public func getDimension(dimension: String?, parent: CGFloat) -> CGFloat {
        var result: CGFloat = 0
        
        if dimension != nil {
            var cleaned = dimension!.stringByReplacingOccurrencesOfString("+", withString: "")
            
            if cleaned.hasSuffix("%") {
                cleaned = dimension!.stringByReplacingOccurrencesOfString("%", withString: "")
                let percent = toFloat(cleaned)
                result = (parent / CGFloat(100.0)) * percent
            } else {
                result = toFloat(cleaned)
            }
        }
        
        return result
    }
    
    private func setAlignment(alignment: String) {
        let lower = alignment.lowercaseString
        if lower.rangeOfString("left") != nil {
            horizontalAlignment = HorizontalAlignment.Left
        }
        if lower.rangeOfString("center") != nil {
            horizontalAlignment = HorizontalAlignment.Center
        }
        if lower.rangeOfString("right") != nil {
            horizontalAlignment = HorizontalAlignment.Right
        }
        if lower.rangeOfString("top") != nil {
            verticalAlignment = VerticalAlignment.Top
        }
        if lower.rangeOfString("middle") != nil {
            verticalAlignment = VerticalAlignment.Middle
        }
        if lower.rangeOfString("bottom") != nil {
            verticalAlignment = VerticalAlignment.Bottom
        }
    }
    
    private func toFloat(input: String?) -> CGFloat {
        if input != nil {
            if let n = NSNumberFormatter().numberFromString(input!) {
                return CGFloat(n)
            }
        }
        
        return CGFloat(0)
    }
}
