import Foundation
import UIKit

open class Convert {
    static func toFloat(_ input: String?) -> Float? {
        if let input = input {
            if let n = NumberFormatter().number(from: input) {
                return Float(n)
            }
        }
        
        return nil
    }
    
    static func toFloat(_ input: String?, ifMissing: Float) -> Float {
        if let input = input {
            if let n = NumberFormatter().number(from: input) {
                return Float(n)
            }
        }
        
        return ifMissing
    }
    
    static func toCGFloat(_ input: String?) -> CGFloat? {
        if let input = input {
            if let n = NumberFormatter().number(from: input) {
                return CGFloat(n)
            }
        }
        
        return nil
    }
    
    static func toCGFloat(_ input: String?, ifMissing: CGFloat) -> CGFloat {
        if let input = input {
            if let n = NumberFormatter().number(from: input) {
                return CGFloat(n)
            }
        }
        
        return ifMissing
    }
    
    static func toUIColor(_ input: String?) throws -> UIColor {
        if (input == nil) {
            return UIColor.clear
        }
        
        let hex = input!.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            throw ReparoError.invalidColorString("\(input!) is an invalid hex color string.")
        }
        
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    open static func getFontWeight(_ section: Section, key: String) throws -> CGFloat {
        let weight = section.getString(key)
        
        guard let name = weight?.lowercased() else {
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
                let message = "Unknown font weight: \(name)\n\nValid values are: 'ultra-light', 'thin', 'light', 'regular', 'medium', 'semi-bold', 'bold' and 'heavy'"
                let filename = section.getFilename(key) ?? ""
                let lineNumber = section.getLineNumber(key)
                let info = LayoutErrorInfo(message: message, filename: filename, lineNumber: lineNumber)
                
                throw LayoutError.configurationError(info)
        }
    }
    
    open static func getTextAlignment(_ alignment: String?) throws -> NSTextAlignment {
        return try getTextAlignment(alignment, or: NSTextAlignment.center)
    }
    
    open static func getTextAlignment(_ alignment: String?, or: NSTextAlignment) throws -> NSTextAlignment {
        guard let alignment = alignment?.lowercased() else {
            return or
        }
        
        switch alignment {
        case "left": return NSTextAlignment.left
        case "center": return NSTextAlignment.center
        case "right": return NSTextAlignment.right
        case "justified": return NSTextAlignment.justified
        case "natural": return NSTextAlignment.natural
        default:
            throw LayoutError.invalidTextAlignment("Unknown alignment: '\(alignment)'\nValid values are: 'left', 'center', 'right', 'justified' and 'natural''")
        }

    }

    open static func getReturnKeyType(_ line: Line) throws -> UIReturnKeyType {
        let type = (line.value ?? "").lowercased()
        switch type {
        case "continue":                return .continue
        case "default":                 return .default
        case "done":                    return .done
        case "emergencycall":           return .emergencyCall
        case "go":                      return .go
        case "google":                  return .google
        case "join":                    return .join
        case "next":                    return .next
        case "route":                   return .route
        case "search":                  return .search
        case "send":                    return .send
        case "yahoo":                   return .yahoo
        default:
            let message = "Unknown UIReturnKeyType: \(type)\n\nValid values are:\n\n - Continue\n - Default\n - Done\n - EmergencyCall\n - Go\n - Google\n -Join\n -Next\n -Route\n -Search\n -Send\n -Yahoo'"
            let filename = line.filename
            let lineNumber = line.lineNumber
            let info = LayoutErrorInfo(message: message, filename: filename, lineNumber: lineNumber)
            
            throw LayoutError.configurationError(info)
        }
    }

    open static func getUITextAutocapitalizationType(_ line: Line) throws -> UITextAutocapitalizationType {
        let type = (line.value ?? "").lowercased()
        switch type {
        case "all":                     return .allCharacters
        case "none":                    return .none
        case "sentances":               return .sentences
        case "words":                   return .words
        default:
            let message = "Unknown UITextAutocapitalizationType: \(type)\n\nValid values are:\n\n - All\n - None\n - Sentances\n - Words"
            let filename = line.filename
            let lineNumber = line.lineNumber
            let info = LayoutErrorInfo(message: message, filename: filename, lineNumber: lineNumber)
            
            throw LayoutError.configurationError(info)
        }
    }
    
    open static func getUIKeyboardType(_ line: Line) throws -> UIKeyboardType {
        let type = (line.value ?? "").lowercased()
        switch type {
        case "ascii-capable":               return .asciiCapable
        case "ascii-capable-number":
            if #available(iOS 10.0, *) {
                return .asciiCapableNumberPad
            } else {
                return .asciiCapable
            }
        case "decimal":                     return .decimalPad
        case "default":                     return .default
        case "email-address":               return .emailAddress
        case "name-phone":                  return .namePhonePad
        case "number":                      return .numberPad
        case "numbers-and-punctuation":     return .numbersAndPunctuation
        case "phone":                       return .phonePad
        case "twitter":                     return .twitter
        case "url":                         return .URL
        case "web-search":                  return .webSearch
        default:
            let message = "Unknown UIKeyboardType: \(type)"
            let filename = line.filename
            let lineNumber = line.lineNumber
            let info = LayoutErrorInfo(message: message, filename: filename, lineNumber: lineNumber)
            info.append("")
            info.append("Valid values are:")
            info.append("")
            info.append("- ascii-capable")
            info.append("- ascii-capable-number")
            info.append("- decimal")
            info.append("- default")
            info.append("- email-address")
            info.append("- name-phone")
            info.append("- number")
            info.append("- numbers-and-punctuation")
            info.append("- phone")
            info.append("- twitter")
            info.append("- url")
            info.append("- web-search")
            
            throw LayoutError.configurationError(info)
        }
    }
    
    open static func getUITextSpellCheckingType(_ line: Line) throws -> UITextSpellCheckingType {
        let type = (line.value ?? "").lowercased()
        switch type {
        case "ascii-capable":               return .default
        case "decimal":                     return .no
        case "default":                     return .yes
        default:
            let message = "Unknown UITextSpellCheckingType: \(type)"
            let filename = line.filename
            let lineNumber = line.lineNumber
            let info = LayoutErrorInfo(message: message, filename: filename, lineNumber: lineNumber)
            info.append("")
            info.append("Valid values are:")
            info.append("")
            info.append("- default")
            info.append("- yes")
            info.append("- no")
            
            throw LayoutError.configurationError(info)
        }
    }

    open static func getUIViewContentMode(_ line: Line) throws -> UIViewContentMode {
        let type = (line.value ?? "").lowercased()
        switch type {
        case "bottom":                      return .bottom
        case "bottom-left":                 return .bottomLeft
        case "bottom-right":                return .bottomRight
        case "center":                      return .center
        case "left":                        return .left
        case "redraw":                      return .redraw
        case "right":                       return .right
        case "scale-aspect-fill":           return .scaleAspectFill
        case "scale-aspect-fit":            return .scaleAspectFit
        case "scale-to-fill":               return .scaleToFill
        case "top":                         return .top
        case "top-left":                    return .topLeft
        case "top-right":                   return .topRight
        default:
            let message = "Unknown UIViewContentMode: \(type)"
            let filename = line.filename
            let lineNumber = line.lineNumber
            let info = LayoutErrorInfo(message: message, filename: filename, lineNumber: lineNumber)
            info.append("")
            info.append("Valid values are:")
            info.append("")
            info.append("- bottom")
            info.append("- bottom-left")
            info.append("- bottom-right")
            info.append("- center")
            info.append("- left")
            info.append("- redraw")
            info.append("- right")
            info.append("- scale-aspect-fill")
            info.append("- scale-aspect-fit")
            info.append("- scale-to-fill")
            info.append("- top")
            info.append("- top-left")
            info.append("- top-right")
            
            throw LayoutError.configurationError(info)
        }
    }
    
    open static func getPadding(_ input: String?) throws -> (top: String, left: String, bottom: String, right: String) {
        return try getPadding(input, type: "Padding", format: "(top) (left) (bottom) (right)'")
    }
    
    open static func getOffset(_ input: String?) throws -> (top: String, left: String, width: String, height: String) {
        let offsets = try getPadding(input, type: "Offset", format: "(top) (left) (width) (height)'")
        
        return (offsets.top, offsets.left, offsets.bottom, offsets.right)
    }
    
    fileprivate static func getPadding(_ input: String?, type: String, format: String) throws -> (top: String, left: String, bottom: String, right: String) {
        guard let input = input else {
            return ("0", "0", "0", "0")
        }
        
        let parts = input.components(separatedBy: " ")
        
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
            throw LayoutError.invalidInsetFormat("\(type) invalid: '\(input)'.  \(type) must be in the format '\(format))'")
        }
        
        return (top, left, bottom, right)
    }
    
    open static func getEdgeInsets(_ input: String?) throws -> UIEdgeInsets? {
        guard let input = input else {
            return nil
        }
        
        let parts = input.components(separatedBy: " ")
        
        if parts.count != 4 {
            throw LayoutError.invalidInsetFormat("Invalid insets: '\(input)'.  Insets must be in the format '0 0 0 0'")
        }
        
        let top = Convert.toCGFloat(parts[0], ifMissing: 0)
        let left = Convert.toCGFloat(parts[1], ifMissing: 0)
        let bottom = Convert.toCGFloat(parts[2], ifMissing: 0)
        let right = Convert.toCGFloat(parts[3], ifMissing: 0)
        
        return UIEdgeInsetsMake(top, left, bottom, right)
    }

    open static func getHexColor(_ color: UIColor) -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
    
    open static func getViewIdAndAnchor(_ input: String?, defaultIdView: String, defaultAnchor: LayoutAnchorType) throws -> (viewId: String, anchor: LayoutAnchorType) {
        // nil check
        guard let input = input else {
            return (defaultIdView, defaultAnchor)
        }
        
        // check if anchor supplied
        guard let index = input.range(of: ".") else {
            return (input, defaultAnchor)
        }
        
        let viewId = input.substring(to: index.lowerBound)
        var anchorRaw = input.substring(from: index.upperBound).lowercased()
        
        if anchorRaw.contains("center") == false {
            anchorRaw = "anchor-" + anchorRaw
        }
        
        if let anchor = LayoutAnchorType(rawValue: anchorRaw) {
            return (viewId, anchor)
        } else {
            throw LayoutError.invalidConfiguration("Invalid Anchor Type: \(anchorRaw)")
        }
        
        
    }
}
