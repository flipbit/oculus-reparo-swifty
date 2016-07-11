//
//  Position.swift
//  OculusReparo
//
//  Created by Chris on 10/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

extension OculusReparo {
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
        
        init(parent: UIView) {
            top = "0"
            left = "0"
            width = "100%"
            height = "100%"
            horizontalAlignment = HorizontalAlignment.Left
            verticalAlignment = VerticalAlignment.Top
            
            self.parent = parent
        }
        
        init(section: Reparo.Section, parent: UIView) {
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
            
            self.parent = parent
            
            if let alignment = section.getValue("align") {
                setAlignment(alignment)
            }
        }
        
        func toFrame() -> CGRect {
            // Get dimensions (absolute or percentage)
            var x = getDimension(left, parent: parent.frame.size.width)
            var y = getDimension(top, parent: parent.frame.size.height)
            let w = getDimension(width, parent: parent.frame.size.width)
            let h = getDimension(height, parent: parent.frame.size.height)
            
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
            
            return CGRect(x: x, y: y, width: w, height: h)
        }
        
        private func getDimension(dimension: String?, parent: CGFloat) -> CGFloat {
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
}