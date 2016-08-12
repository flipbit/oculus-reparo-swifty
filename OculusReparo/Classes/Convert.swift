import Foundation
import UIKit

public class Convert {
    static func toFloat(input: String?) -> Float? {
        if let input = input {
            if let n = NSNumberFormatter().numberFromString(input) {
                return Float(n)
            }
        }
        
        return nil
    }
    
    static func toFloat(input: String?, ifMissing: Float) -> Float {
        if let input = input {
            if let n = NSNumberFormatter().numberFromString(input) {
                return Float(n)
            }
        }
        
        return ifMissing
    }
    
    static func toCGFloat(input: String?) -> CGFloat? {
        if let input = input {
            if let n = NSNumberFormatter().numberFromString(input) {
                return CGFloat(n)
            }
        }
        
        return nil
    }
    
    static func toCGFloat(input: String?, ifMissing: CGFloat) -> CGFloat {
        if let input = input {
            if let n = NSNumberFormatter().numberFromString(input) {
                return CGFloat(n)
            }
        }
        
        return ifMissing
    }
    
    static func toUIColor(input: String?) throws -> UIColor {
        if (input == nil) {
            return UIColor.clearColor()
        }
        
        let hex = input!.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        var int = UInt32()
        NSScanner(string: hex).scanHexInt(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            throw ReparoError.InvalidColorString("\(input!) is an invalid hex color string.")
        }
        
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    public static func getFontWeight(weight: String?) throws -> CGFloat {
        guard let name = weight?.lowercaseString else {
            return UIFontWeightRegular
        }
        
        switch name {
        case "ultra-light": return UIFontWeightUltraLight;
        case "thin": return UIFontWeightThin;
        case "light": return UIFontWeightLight;
        case "regular": return UIFontWeightRegular;
        case "medium": return UIFontWeightMedium;
        case "semi-bold": return UIFontWeightSemibold;
        case "bold": return UIFontWeightBold;
        case "heavy": return UIFontWeightHeavy;
        default:
            throw LayoutError.UnknownFontWeight("Unknown font weight: \(name)")
        }
    }
    
    public static func getTextAlignment(alignment: String?) throws -> NSTextAlignment {
        return try getTextAlignment(alignment, or: NSTextAlignment.Center)
    }
    
    public static func getTextAlignment(alignment: String?, or: NSTextAlignment) throws -> NSTextAlignment {
        guard let alignment = alignment?.lowercaseString else {
            return or
        }
        
        switch alignment {
        case "left": return NSTextAlignment.Left
        case "center": return NSTextAlignment.Center
        case "right": return NSTextAlignment.Right
        case "justified": return NSTextAlignment.Justified
        case "natural": return NSTextAlignment.Natural
        default:
            throw LayoutError.InvalidTextAlignment("Unknown alignment: '\(alignment)'\nValid values are: 'left', 'center', 'right', 'justified' and 'natural''")
        }

    }

    public static func getPadding(input: String?) throws -> (top: String, left: String, bottom: String, right: String) {
        return try getPadding(input, type: "Padding", format: "(top) (left) (bottom) (right)'")
    }
    
    public static func getOffset(input: String?) throws -> (top: String, left: String, width: String, height: String) {
        let offsets = try getPadding(input, type: "Offset", format: "(top) (left) (width) (height)'")
        
        return (offsets.top, offsets.left, offsets.bottom, offsets.right)
    }
    
    private static func getPadding(input: String?, type: String, format: String) throws -> (top: String, left: String, bottom: String, right: String) {
        guard let input = input else {
            return ("0", "0", "0", "0")
        }
        
        let parts = input.componentsSeparatedByString(" ")
        
        var top: String = ""
        var left: String = ""
        var bottom: String = ""
        var right: String = ""
        
        if parts.count == 4 {
            top = parts[0]
            left = parts[1]
            bottom = parts[2]
            right = parts[3]
        } else if parts.count == 3 {
            top = parts[0]
            left = parts[1]
            bottom = parts[2]
            right = parts[1]
        } else if parts.count == 2 {
            top = parts[0]
            left = parts[1]
            bottom = parts[0]
            right = parts[1]
        } else if parts.count == 1 {
            top = parts[0]
            left = parts[0]
            bottom = parts[0]
            right = parts[0]
        } else {
            throw LayoutError.InvalidInsetFormat("\(type) invalid: '\(input)'.  \(type) must be in the format '\(format))'")
        }
        
        return (top, left, bottom, right)
    }
    
    public static func getEdgeInsets(input: String?) throws -> UIEdgeInsets? {
        guard let input = input else {
            return nil
        }
        
        let parts = input.componentsSeparatedByString(" ")
        
        if parts.count != 4 {
            throw LayoutError.InvalidInsetFormat("Invalid insets: '\(input)'.  Insets must be in the format '0 0 0 0'")
        }
        
        let top = Convert.toCGFloat(parts[0], ifMissing: 0)
        let left = Convert.toCGFloat(parts[1], ifMissing: 0)
        let bottom = Convert.toCGFloat(parts[2], ifMissing: 0)
        let right = Convert.toCGFloat(parts[3], ifMissing: 0)
        
        return UIEdgeInsetsMake(top, left, bottom, right)
    }

    public static func getHexColor(color: UIColor) -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
}