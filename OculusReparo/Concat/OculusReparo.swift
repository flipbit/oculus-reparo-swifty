//
// OculusReparo View Layouts
//
// For usage see:
//
// https://github.com/flipbit/oculus-reparo-swifty
//
// This file was auto generated on: Jul 21, 2016, 2:27 PM
//
import Foundation
import UIKit


public protocol BuilderProtocol {
    func canBuild(layout: Section) -> Bool
    
    func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView
}



public class Layout {
    static var builders: [BuilderProtocol] = []
    static private var initialized = false

    public var views: [String: UIView]
    public var variables: [String: String]
    public var directives: [String]
    public var model: NSObject?
    public var eventTarget: AnyObject?
    public var view: UIView?
    public var filename: String?
    
    init() {
        variables = [:]
        directives = []
        views = [:]
        
        // append default builders
        if !Layout.initialized {
            Layout.builders.append(UIViewBuilder())
            Layout.builders.append(UILabelBuilder())
            Layout.builders.append(UISliderBuilder())
            Layout.builders.append(UIButtonBuilder())
            Layout.builders.append(UIImageViewBuilder())
            Layout.builders.append(UITableViewBuilder())
            Layout.builders.append(UIScrollViewBuilder())
            Layout.initialized = true
        }
        
        // append default directives
        directives.append("device:" + Hardware.device.rawValue)
        directives.append("device-type:" + Hardware.deviceType.rawValue)
        directives.append("screen:" + Hardware.screenSize.rawValue)
        directives.append(Hardware.orientation)
    }

    convenience init(filename: String, view: UIView) {
        self.init()
        
        self.view = view
        self.eventTarget = view
        self.filename = filename
    }
    
    convenience init(filename: String, controller: UIViewController) {
        self.init()
        
        self.view = controller.view
        self.eventTarget = controller
        self.filename = filename
    }
    
    convenience init(filename: String) {
        self.init()
        
        self.filename = filename
    }

    public func apply() throws {
        try apply(filename!)
    }
    
    public func apply(filename: String) throws {
        guard let view = view else {
            throw LayoutError.MissingRootView
        }
        
        self.filename = filename
        
        let parser = Parser()
        parser.directives = directives
        parser.variables = variables
        
        let layout = try parser.parseFile(filename)
        
        debug(layout)
        
        try setProperties(layout, view: view)
        
        for section in layout.sections {
            try build(section, parent: view)
        }
    }
    
    func debug(layout: Document) {
        let lines = layout.toString().componentsSeparatedByString("\n")
        
        print("")
        print("Layout: \(lines.count) lines.")
        print("")
        print("----------")
        

        for line in lines {
            print(line)
        }
        
        print("")
        print("----------")
        print("")
    }
    
    /*
    public func animateIn(filename: String, state: ViewState) throws -> ViewState {
        let parser = Reparo.Parser()
        parser.directives = state.directives
        let layout = try parser.parseFile(filename)
        
        try animateIn(layout.sections, state: state)
        
        return state
    }
    
    private func animateIn(layout: [Reparo.Section], state: ViewState) throws -> ViewState {
        for section in layout {
            if let view = state.findView(section) {
                Animation().animateIn(section, view: view)
            }
            
            try animateIn(section.sections, state: state)
        }
        
        return state
    }
    */
    
    public func clearDirective(directive: String) {
        let index = directives.indexOf(directive)
        if let index = index {
            directives.removeAtIndex(index)
        }
    }

    public func clearVariable(name: String) {
        let index = variables.indexForKey(name)
        if let index = index {
            variables.removeAtIndex(index)
        }
    }
    
    public func addVariable(name: String, value: String) {
        variables[name] = value
    }
    
    public func addVariable(name: String, value: UIColor) {
        variables[name] = Convert.getHexColor(value)
    }
    
    public func addVariable(name: String, value: Int) {
        variables[name] = String(value)
    }
    
    public func addVariable(name: String, value: Float) {
        variables[name] = String(value)
    }
    
    public func findView(viewId: String) -> UIView? {
        if views[viewId] != nil {
            return views[viewId]
        }
        
        return nil
    }
    
    public func hasView(viewId: String) -> Bool {
        return views[viewId] != nil
    }
    
    public func handleLayoutError(message: String) {
        if let view = view {
            for subview in view.subviews {
                subview.removeFromSuperview()
            }

            view.backgroundColor = UIColor.whiteColor()

            let header = UIView()
            header.backgroundColor = UIColor.redColor()
            header.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
            view.addSubview(header)
            
            let title = UILabel()
            title.frame = CGRect(x: 8, y: 30, width: view.frame.width - 16, height: 30)
            title.textColor = UIColor.whiteColor()
            title.backgroundColor = UIColor.redColor()
            title.text = "Error Processing Layout"
            title.font = UIFont.boldSystemFontOfSize(17)
            header.addSubview(title)
            
            let label = UILabel()
            label.frame = CGRect(x: 8, y: 68, width: view.frame.width - 16, height: view.frame.height - 68)
            label.textColor = UIColor.redColor()
            label.backgroundColor = UIColor.whiteColor()
            label.text = message
            label.font = UIFont(name: "Courier", size: 15)
            label.numberOfLines = 100
            label.sizeToFit()
            view.addSubview(label)
        } else {
            print(message)
        }
    }
    
    static public func generateErrorMessage(layout: Section, key: String?) -> String {
        var message = "\n\nError occured at:\n\n"
        
        if let key = layout.key {
            message.appendContentsOf("Section name      : \(key)\n")
        }
        
        if let key = key {
            for line in layout.lines {
                if line.key == key {
                    message.appendContentsOf("Line path         : \(line.path)\n")
                    message.appendContentsOf("Line key          : \(key)\n")
                    
                    if let value = line.value {
                        message.appendContentsOf("Line value        : \(value)\n")
                    }
                    
                    message.appendContentsOf("Filename          : \(line.filename)\n")
                    message.appendContentsOf("Line number       : \(line.lineNumber)\n\n")
                }
            }
        }
        
        return message
    }

    /**
     Registers the given builder
    */
    static public func register(builder: BuilderProtocol) {
        Layout.builders.append(builder)
    }
    
    public func enableAutorotation() {
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self, selector: #selector(rotate), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    @objc private func rotate() throws {
        clearDirective("landscape")
        clearDirective("portrait")
        directives.append(Hardware.orientation)
        
        if let filename = filename {
            try apply(filename)
        }
    }    
    
    private func setProperties(layout: Section, view: UIView) throws {
        if let properties = layout.getSection("layout") {
            view.backgroundColor = try properties.getUIColor("background-color")
        }
    }
    
    private func build(layout: Section, parent: UIView) throws {
        for builder in Layout.builders {
            if (builder.canBuild(layout)) {
                let view = try builder.build(layout, instance: self, parent: parent)
                
                for section in layout.sections {
                    try build(section, parent: view)
                }
                    
                break
            }
        }
    }
}




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




public class Hardware {
    public enum Device : String {
        case iPodTouch5 = "iPod Touch 5"
        case iPodTouch6 = "iPod Touch 6"
        case iPhone4 = "iPhone 4"
        case iPhone4s = "iPhone 4s"
        case iPhone5 = "iPhone 5"
        case iPhone5c = "iPhone 5c"
        case iPhone5s = "iPhone 5s"
        case iPhone6 = "iPhone 6"
        case iPhone6Plus = "iPhone 6 Plus"
        case iPhone6s = "iPhone 6s"
        case iPhone6sPlus = "iPhone 6s Plus"
        case iPhoneSE = "iPhone SE"
        case iPad2 = "iPad 2"
        case iPad3 = "iPad 3"
        case iPad4 = "iPad 4"
        case iPadAir = "iPad Air"
        case iPadAir2 = "iPad Air 2"
        case iPadMini = "iPad Mini"
        case iPadMini2 = "iPad Mini 2"
        case iPadMini3 = "iPad Mini 3"
        case iPadMini4 = "iPad Mini 4"
        case iPadPro = "iPad Pro"
        case AppleTV = "Apple TV"
        case Simulator = "Simulator"
        case Unknown = "Unknown"
    }
    
    public enum DeviceType : String {
        case iPodTouch = "iPodTouch"
        case iPhone = "iPhone"
        case iPad = "iPad"
        case AppleTV = "Apple TV"
        case Simulator = "Simulator"
        case Unknown = "Unknown"
    }
    
    public enum ScreenSize : String {
        case iPhone = "iPhone"
        case iPhone5 = "iPhone5"
        case iPhone6 = "iPhone6"
        case iPhone6Plus = "iPhone6Plus"
        case iPad = "ipad"
        case iPadPro = "iPadPro"
        case AppleTV = "AppleTV"
        case Simulator = "Simulator"
        case Unknown = "Unknown"
    }
    
    static private var deviceInstance: Device?
    
    static var device: Device {
        if deviceInstance != nil {
            return deviceInstance!
        }
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 deviceInstance = Device.iPodTouch5; break
        case "iPod7,1":                                 deviceInstance = Device.iPodTouch6; break
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     deviceInstance = Device.iPhone4; break
        case "iPhone4,1":                               deviceInstance = Device.iPhone4s; break
        case "iPhone5,1", "iPhone5,2":                  deviceInstance = Device.iPhone5; break
        case "iPhone5,3", "iPhone5,4":                  deviceInstance = Device.iPhone5c; break
        case "iPhone6,1", "iPhone6,2":                  deviceInstance = Device.iPhone5s; break
        case "iPhone7,2":                               deviceInstance = Device.iPhone6; break
        case "iPhone7,1":                               deviceInstance = Device.iPhone6Plus; break
        case "iPhone8,1":                               deviceInstance = Device.iPhone6s; break
        case "iPhone8,2":                               deviceInstance = Device.iPhone6sPlus; break
        case "iPhone8,4":                               deviceInstance = Device.iPhoneSE; break
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":deviceInstance = Device.iPad2; break
        case "iPad3,1", "iPad3,2", "iPad3,3":           deviceInstance = Device.iPad3; break
        case "iPad3,4", "iPad3,5", "iPad3,6":           deviceInstance = Device.iPad4; break
        case "iPad4,1", "iPad4,2", "iPad4,3":           deviceInstance = Device.iPadAir; break
        case "iPad5,3", "iPad5,4":                      deviceInstance = Device.iPadAir2; break
        case "iPad2,5", "iPad2,6", "iPad2,7":           deviceInstance = Device.iPadMini; break
        case "iPad4,4", "iPad4,5", "iPad4,6":           deviceInstance = Device.iPadMini2; break
        case "iPad4,7", "iPad4,8", "iPad4,9":           deviceInstance = Device.iPadMini3; break
        case "iPad5,1", "iPad5,2":                      deviceInstance = Device.iPadMini4; break
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":deviceInstance = Device.iPadPro; break
        case "AppleTV5,3":                              deviceInstance = Device.AppleTV; break
        case "i386", "x86_64":                          deviceInstance = Device.Simulator; break
        default:                                        deviceInstance = Device.Unknown; break
        }
        
        return deviceInstance!
    }
    static var deviceType: DeviceType {
        switch device {
        case Device.AppleTV:                return DeviceType.AppleTV
        case Device.iPad2:                  return DeviceType.iPad
        case Device.iPad3:                  return DeviceType.iPad
        case Device.iPad4:                  return DeviceType.iPad
        case Device.iPadAir:                return DeviceType.iPad
        case Device.iPadAir2:               return DeviceType.iPad
        case Device.iPadMini:               return DeviceType.iPad
        case Device.iPadMini2:              return DeviceType.iPad
        case Device.iPadMini3:              return DeviceType.iPad
        case Device.iPadMini4:              return DeviceType.iPad
        case Device.iPadPro:                return DeviceType.iPad
        case Device.iPhone4:                return DeviceType.iPhone
        case Device.iPhone4s:               return DeviceType.iPhone
        case Device.iPhone5:                return DeviceType.iPhone
        case Device.iPhone5c:               return DeviceType.iPhone
        case Device.iPhone5s:               return DeviceType.iPhone
        case Device.iPhone6:                return DeviceType.iPhone
        case Device.iPhone6Plus:            return DeviceType.iPhone
        case Device.iPhone6s:               return DeviceType.iPhone
        case Device.iPhone6sPlus:           return DeviceType.iPhone
        case Device.Simulator:              return DeviceType.Simulator
        default:                            return DeviceType.Unknown
        }
    }
    
    static var screenSize: ScreenSize {
        let size = UIScreen.mainScreen().bounds
        var width = size.width
        var height = size.height
        
        if width > height {
            width = size.height
            height = size.width
        }
        
        if (width == 320 && height == 480) {
            return ScreenSize.iPhone
        }
        
        if (width == 320 && height == 568) {
            return ScreenSize.iPhone5
        }
        
        if (width == 375 && height == 667) {
            return ScreenSize.iPhone6
        }
        
        if (width == 414 && height == 736) {
            return ScreenSize.iPhone6Plus
        }
        
        if (width == 768 && height == 1024) {
            return ScreenSize.iPad
        }
        
        if (width == 1024 && height == 1366) {
            return ScreenSize.iPadPro
        }
        
        return ScreenSize.Unknown
    }
    
    static var orientation: String {
        if UIDevice.currentDevice().orientation.isPortrait {
            return "portait"
        } else {
            return "landscape"
        }
    }
}



/*
extension OculusReparo {
    
    public class Animation {
        public func animateIn(layout: Reparo.Section, view: UIView) {
            animate(layout, view: view, direction: "animate-in")
        }
        
        public func animateOut(layout: Reparo.Section, view: UIView) {
            animate(layout, view: view, direction: "animate-out")
        }
        
        private func animate(layout: Reparo.Section, view: UIView, direction: String) {
            if let section = layout.getSection(direction) {
                UIView.animateWithDuration(1, animations: {
                    let opacity = section.getFloat("opacity", ifMissing: -1)
                    if opacity > -1 {
                        view.layer.opacity = opacity
                    }
                })
            }
        }
    }
}
 */



public extension Convert {
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
        guard let alignment = alignment?.lowercaseString else {
            return NSTextAlignment.Center
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



enum LayoutError: ErrorType {
    case MissingViewPosition(String)
    case MissingRootView
    case MissingModelProperty(String)
    case UnknownFontWeight(String)
    case InvalidInsetFormat(String)
    case InvalidTextAlignment(String)
}




public class Builder {
    public func initialize<T: UIView>(layout: Section, instance: Layout, parent: UIView) throws -> T {
        var view: T
        
        var viewId = layout.path
        if layout.hasValue("view-id") {
            viewId = layout.getValue("view-id")!
        }
        
        if instance.hasView(viewId) {
            view = instance.findView(viewId) as! T
        } else {
            view = T()
            instance.views[viewId] = view
            
            if let id = layout.getValue("id") where instance.model != nil {
                if instance.model!.respondsToSelector(Selector("\(id)")) {
                    instance.model!.setValue(view, forKey: id)
                } else {
                    let message = Layout.generateErrorMessage(layout, key: "id")
                    
                    throw LayoutError.MissingModelProperty("The property '\(id)' is missing on the model.\(message)")
                }
            }
        }
        
        view.frame = try getFrame(layout, parent: parent)
        view.backgroundColor = try layout.getUIColor("background-color")
        view.layer.zPosition = layout.getCGFloat("z-position", ifMissing: 0)
        view.layer.cornerRadius = layout.getCGFloat("corner-radius", ifMissing: 0)
        view.layer.borderColor = try layout.getCGColor("border-color")
        view.layer.borderWidth = layout.getCGFloat("border-width", ifMissing: 0)
        view.layer.opacity = layout.getFloat("opacity", ifMissing: 1)
        view.clipsToBounds = try layout.getBool("clips-to-bounds")
        view.hidden = try layout.getBool("hidden")
        view.userInteractionEnabled = try layout.getBool("user-interaction-enabled", ifMissing: true)
        view.accessibilityIdentifier = layout.getValue("accessibility-identifier")
        
        if view.superview == nil {
            parent.addSubview(view)
        }
        
        return view
    }

    public func getPosition(layout: Section, parent: UIView) throws -> Position {
        let config = layout.getSection("position")
        
        if config == nil {
            throw LayoutError.MissingViewPosition("[\(layout.key) is missing a Position section (line: \(layout.lineNumber))")
        }
        
        return try Position(section: config!, parent: parent)
    }
    
    public func getFrame(layout: Section, parent: UIView) throws -> CGRect {
        return try getPosition(layout, parent: parent).toFrame()
    }        
}




public class UIViewBuilder : Builder, BuilderProtocol {
    public func canBuild(layout: Section) -> Bool {
        return layout.key == "view"
    }
    
    public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let view: UIView = try initialize(layout, instance: instance, parent: parent)
        
        return view;
    }
}




public class UILabelBuilder : Builder, BuilderProtocol {
    public func canBuild(layout: Section) -> Bool {
        return layout.key == "label"
    }
    
    public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let label: UILabel = try initialize(layout, instance: instance, parent: parent)
        let size = layout.getCGFloat("font-size", ifMissing: 17)
        let weight = try Convert.getFontWeight(layout.getValue("font-weight"))
        
        label.text = layout.getValue("text")
        label.textColor = try layout.getUIColor("text-color")
        label.font = UIFont.systemFontOfSize(size, weight: weight)
        label.textAlignment = try Convert.getTextAlignment(layout.getValue("text-alignment"))
        
        return label;
    }
}



public class UISliderBuilder : Builder, BuilderProtocol {
    public func canBuild(layout: Section) -> Bool {
        return layout.key == "slider"
    }
    
    public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let slider: UISlider = try initialize(layout, instance: instance, parent: parent)
        
        slider.minimumValue = layout.getFloat("minimum-value", ifMissing: 0)
        slider.maximumValue = layout.getFloat("maximum-value", ifMissing: 100)
        slider.value = layout.getFloat("value", ifMissing: 0)
        slider.continuous = try layout.getBool("continuous", ifMissing: false)
        
        if let color = try layout.getUIColor("tint-color") {
                slider.tintColor = color
        }
        
        if let changed = layout.getValue("changed"), eventTarget = instance.eventTarget {
            slider.addTarget(eventTarget, action: Selector(changed), forControlEvents: UIControlEvents.ValueChanged)
        }
        
        if let changed = layout.getValue("touch-up-inside"), eventTarget = instance.eventTarget {
            slider.addTarget(eventTarget, action: Selector(changed), forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        if let changed = layout.getValue("touch-up-outside"), eventTarget = instance.eventTarget {
            slider.addTarget(eventTarget, action: Selector(changed), forControlEvents: UIControlEvents.TouchUpOutside)
        }
        
        return slider;
    }
}




public class UIButtonBuilder : Builder, BuilderProtocol {
    public func canBuild(layout: Section) -> Bool {
        return layout.key == "button"
    }
    
    public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let button: UIButton = try initialize(layout, instance: instance, parent: parent)
        
        // Font
        let size = layout.getCGFloat("font-size", ifMissing: 17)
        let weight = try Convert.getFontWeight(layout.getValue("font-weight"))
        button.titleLabel?.font = UIFont.systemFontOfSize(size, weight: weight)
        
        if let title = layout.getValue("title") {
            button.setTitle(title, forState: UIControlState.Normal)
        }

        if let bundle = layout.getValue("image-bundle") {
            if let image = UIImage(named: bundle)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate) {
                button.setImage(image, forState: UIControlState.Normal)
            }
        }
        
        if let color = try layout.getUIColor("tint-color") {
            button.setTitleColor(color, forState: UIControlState.Normal)
            button.tintColor = color
        }
        
        if let touched = layout.getValue("touched"), eventTarget = instance.eventTarget {
            button.addTarget(eventTarget, action: Selector(touched), forControlEvents: UIControlEvents.TouchUpInside)
            button.addTarget(eventTarget, action: Selector(touched), forControlEvents: UIControlEvents.TouchUpOutside)
        }
        
        if let insets = try Convert.getEdgeInsets(layout.getValue("title-edge-insets")) {
            button.titleEdgeInsets = insets
        }
        
        if let align = layout.getValue("align") {
            switch align {
            case "left":
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            default:
                break;
            }
        }
        
        return button;
    }
}




public class UIImageViewBuilder : Builder, BuilderProtocol {
    public func canBuild(layout: Section) -> Bool {
        return layout.key == "image"
    }
    
    public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let imageView: UIImageView = try initialize(layout, instance: instance, parent: parent)
        
        let color = try layout.getUIColor("tint-color")
        
        if let bundle = layout.getValue("image-bundle") {
            if var image = UIImage(named: bundle) {
                if color != nil {
                    imageView.tintColor = color
                    
                    image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                }
                
                imageView.image = image
            }
        }
        
        return imageView;
    }
}



public class UITableViewBuilder : Builder, BuilderProtocol {
    public func canBuild(layout: Section) -> Bool {
        return layout.key == "table"
    }
    
    public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let table: UITableView = try initialize(layout, instance: instance, parent: parent)
        
        table.bounces = try layout.getBool("bounces", ifMissing: true)
        table.scrollEnabled = try layout.getBool("scroll-enabled", ifMissing: true)
        
        return table;
    }
}



public class UIScrollViewBuilder : Builder, BuilderProtocol {
    public func canBuild(layout: Section) -> Bool {
        return layout.key == "scroll"
    }
    
    public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let scroll: UIScrollView = try initialize(layout, instance: instance, parent: parent)
        
        scroll.bounces = try layout.getBool("bounces", ifMissing: true)
        scroll.scrollEnabled = try layout.getBool("scroll-enabled", ifMissing: true)
        scroll.pagingEnabled = try layout.getBool("paging-enabled")
        scroll.showsVerticalScrollIndicator = try layout.getBool("shows-vertical-scroll-indicator", ifMissing: true)
        scroll.showsHorizontalScrollIndicator = try layout.getBool("shows-horizontal-scroll-indicator", ifMissing: true)
        
        let position = try getPosition(layout, parent: parent)
        
        let width = layout.getValue("content-width", ifMissing: "100%")
        let w = position.getDimension(width, parent: parent.frame.width)
        
        let height = layout.getValue("content-height", ifMissing: "100%")
        let h = position.getDimension(height, parent: parent.frame.height)
        
        scroll.contentSize = CGSize(width: w, height: h)
        
        return scroll;
    }
}



extension UIViewController {
    /**
     Layouts the view using the given filename
     
     - Parameter filename:   The name of the file containing the view
     
     - Returns:              An Layout instance
     */
    public func createLayout(filename: String) -> Layout {
        let oculus = Layout(filename: filename, controller: self)
        
        return oculus
    }
    
    public func createLayout(filename: String, model: NSObject) -> Layout {
        let oculus = Layout(filename: filename, controller: self)
        
        oculus.model = model        
    
        return oculus
    }
    
    public func createLayout(filename: String, model: NSObject, eventTarget: AnyObject) -> Layout {
        let oculus = Layout(filename: filename, controller: self)
        
        oculus.model = model
        oculus.eventTarget = eventTarget
        
        return oculus
    }
    
    public func applyLayout(layout: Layout) -> Bool {
        return UIView.applyLayout(layout)
    }
}

extension UIView {
    /**
     Layouts the view using the given filename
     
     - Parameter filename:   The name of the file containing the view
     
     - Returns:              An Layout instance
     */
    public func createLayout(filename: String) -> Layout {
        let oculus = Layout(filename: filename, view: self)
        
        return oculus
    }
    
    public func createLayout(filename: String, model: NSObject) -> Layout {
        let oculus = Layout(filename: filename, view: self)
        
        oculus.model = model
        
        return oculus
    }
    
    public func createLayout(filename: String, model: NSObject, eventTarget: AnyObject) -> Layout {
        let oculus = Layout(filename: filename, view: self)
        
        oculus.model = model
        oculus.eventTarget = eventTarget
        
        return oculus
    }

    public func applyLayout(layout: Layout) -> Bool {
        return UIView.applyLayout(layout)
    }
    
    public static func applyLayout(layout: Layout) -> Bool {
        var result = false
        do {
            try layout.apply()
            
            result = true
        } catch LayoutError.MissingRootView {
            layout.handleLayoutError("Controller root view is not set")
        } catch LayoutError.MissingViewPosition(let message) {
            layout.handleLayoutError(message)
        } catch LayoutError.MissingModelProperty(let message) {
            layout.handleLayoutError(message)
        } catch ReparoError.InvalidColorString(let message) {
            layout.handleLayoutError(message)
        } catch ReparoError.InvalidConfigurationLine(let message) {
            layout.handleLayoutError(message)
        } catch ReparoError.MissingConfigurationFile(let message) {
            layout.handleLayoutError(message)
        } catch ReparoError.RecursiveIncludeDetected {
            layout.handleLayoutError("Recursive include file detected.")
        } catch let error as NSError {
            layout.handleLayoutError(error.localizedDescription)
        }
        
        return result
    }
    
}


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

public class Line {
    public var key: String?
    public var value: String?
    public var filename: String
    public var lineNumber: Int
    public var directives: [Directive]
    public var parent: Section?
    public var index: Int
    
    public var isASection: Bool {
        return false
    }
    
    public var isEndOfSection: Bool {
        return key == "}"
    }    
    
    init(filename: String, lineNumber: Int) {
        directives = []
        index = 0
        
        self.filename = filename
        self.lineNumber = lineNumber
    }
    
    public var sections: [Section] {
        return []
    }
    
    public var path: String {
        let key = self.key ?? ""
        
        if (parent != nil) {
            return parent!.path + "/\(key)[\(index)]"
        }
        
        return "/\(key)[\(index)]"
    }
    
    public func clone() -> Line {
        let clone = Line(filename: filename, lineNumber: lineNumber)
        
        clone.key = key
        clone.value = value
        clone.parent = parent
        clone.index = index
        
        for directive in directives {
            clone.directives.append(directive.clone())
        }
        
        return clone
    }
    
    public func toString(pad: Int = 0) -> String {
        var string = String(count: pad, repeatedValue: (" " as Character))
        
        if key != nil {
            string += key!
        } else {
            string += "(nil)"
        }
        
        string += ":"
        
        if value != nil {
            string += value!
        } else {
            string += "(nil)"
        }
        
        if directives.count > 0 {
            string += " @if "
            for directive in directives {
                if directive.not {
                    string += "!"
                }
                string += directive.name
            }
        }

        string += ";  -> \(path)"
        
        return string
    }
}

public class Section : Line {
    public var lines: [Line]
    
    override public var isASection: Bool {
        return true
    }
    
    init(line: Line)
    {
        lines = []
        
        super.init(filename: line.filename, lineNumber: line.lineNumber)
        
        key = line.key
        value = line.value
        index = line.index
        directives.appendContentsOf(line.directives)
    }
    
    init(filename: String)
    {
        lines = []
        
        super.init(filename: filename, lineNumber: 0)
    }
    
    init(filename: String, lines: [Line])
    {
        self.lines = lines
        
        super.init(filename: filename, lineNumber: 0)
    }
    
    override public var path: String {
        if let id = getValue("id") {
            return "#" + id
        } else {
            return super.path
        }
    }
    
    override public var sections: [Section] {
        var results: [Section] = []
        
        for line in lines {
            if let section = line as? Section {
                results.append(section)
            }
        }
        
        return results
    }
    
    override public func toString(pad: Int = 0) -> String {
        var string = String(count: pad, repeatedValue: (" " as Character))
        
        if key != nil {
            string += key!
        } else {
            string += "(nil)"
        }
        
        string += ":"
        
        if value != nil {
            string += value!
        }
        
        if directives.count > 0 {
            string += " @if "
            for directive in directives {
                if directive.not {
                    string += "!"
                }
                string += directive.name
            }
        }
        
        string += " {  --> \(path)\n"
        
        for line in lines {
            string += "\(line.toString(pad + 4))\n"
        }
        
        string += String(count: pad, repeatedValue: (" " as Character)) + "}"
        
        return string
    }
    
    override public func clone() -> Line {
        let clone = Section(line: super.clone())

        for line in lines {
            let c = line.clone()
            
            c.parent = clone
            
            clone.lines.append(c)
        }
        
        return clone
    }

    func hasValue(name: String) -> Bool {
        for line in lines {
            if line.key == name {
                return true
            }
        }
        
        return false
    }
    
    func getValue(name: String) -> String? {
        return getValue(name, ifMissing: nil)
    }
    
    func getValue(name: String, ifMissing: String?) -> String? {
        for line in lines {
            if line.key == name {
                return line.value
            }
        }
        return ifMissing
    }
    
    func getFloat(name: String) -> Float? {
        let value = getValue(name)
        
        return Convert.toFloat(value)
    }
    
    func getFloat(name: String, ifMissing: Float) -> Float {
        let value = getValue(name)
        
        return Convert.toFloat(value, ifMissing: ifMissing)
    }
    
    func getCGFloat(name: String) -> CGFloat? {
        let value = getValue(name)
        
        return Convert.toCGFloat(value)
    }
    
    func getCGFloat(name: String, ifMissing: CGFloat) -> CGFloat {
        let value = getValue(name)
        
        return Convert.toCGFloat(value, ifMissing: ifMissing)
    }
    
    func getUIColor(name: String) throws -> UIColor? {
        return try getUIColor(name, ifMissing: UIColor.clearColor())
    }
    
    func getUIColor(name: String, ifMissing: UIColor?) throws -> UIColor? {
        if let value = getValue(name) {
            return try Convert.toUIColor(value)
        }
        
        return ifMissing
    }
    
    func getCGColor(name: String) throws -> CGColor? {
        return try getUIColor(name, ifMissing: UIColor.clearColor())?.CGColor
    }
    
    func getCGColor(name: String, ifMissing: UIColor?) throws -> CGColor? {
        if let value = getValue(name) {
            return try Convert.toUIColor(value).CGColor
        }
        
        return ifMissing?.CGColor
    }

    func getBool(name: String) throws -> Bool {
        return try getBool(name, ifMissing: false)
    }
    
    func getBool(name: String, ifMissing: Bool) throws -> Bool {
        if hasValue(name) {
            if let value = getValue(name) {
                switch value.lowercaseString {
                case "true": return true
                case "false": return false
                case "1": return true
                case "0": return false
                default: throw ReparoError.InvalidColorString("Invalid boolean value: '\(value)'")
                }
            } else {
                return true                     // if empty, return true
            }
        } else if hasValue("!" + name) {
            return false                        // check for "!" value
        } else {
            return ifMissing
        }
    }
    
    public func getSection(name: String) -> Section? {
        return getSection(name, recurse: false)
    }
    
    public func getSection(name: String, recurse: Bool) -> Section? {
        var results = getSections(name, recurse: recurse)
        
        if results.count > 0 {
            return results[0]
        } else {
            return nil
        }
    }
    
    public func getSections(name: String) -> [Section] {
        return getSections(name, recurse: false)
    }
    
    public func getSections(name: String, recurse: Bool) -> [Section] {
        return getSections(name, recurse: recurse, search: lines)
    }
    
    private func getSections(name: String, recurse: Bool, search: [Line]) -> [Section] {
        var results: [Section] = []
        
        for line in search {
            if let section = line as? Section {
                if (section.key == name) {
                    results.append(section)
                }
                
                if recurse {
                    let children = getSections(name, recurse: recurse, search: section.lines)
                    
                    results.appendContentsOf(children)
                }
            }
        }
        
        return results
    }
}

public class Document : Section {
    override public var path: String {
        return ""
    }
    
    public override func toString(pad: Int = 0) -> String {
        var string = ""
        
        for line in lines {
            string += "\(line.toString())\n"
        }
        
        return string
    }
}

public protocol ReparoReader {
    func readFile(filename: String) throws -> String?
    
    func readIncludeFile(filename: String) throws -> String?
}

public class BundleReader : ReparoReader {
    public func readFile(filename: String) throws -> String? {
        let path = getPath(filename)
        return try read(path)
    }
    
    public func readIncludeFile(filename: String) throws -> String? {
        let path = getPath(filename)
        return try read(path)
    }
    
    private func getPath(filename: String) -> String {
        let bundlePath = NSBundle(forClass: self.dynamicType).resourcePath!
        let url = NSURL(fileURLWithPath: bundlePath)
        return url.URLByAppendingPathComponent(filename).path!
    }
    
    private func read(filename: String) throws -> String? {
        return try NSString(contentsOfFile: filename, encoding: NSUTF8StringEncoding) as String
    }
}

/**
 Parser to read Reparo configuration files
 */
public class Parser {
    var variables: [String: String]
    var directives: [String]
    var transforms: [ReparoTransform]
    var reader: ReparoReader
    
    init() {
        variables = [:]
        directives = []
        transforms = []
        
        transforms.append(IncludeTransform())
        transforms.append(FunctionTransform())
        transforms.append(VariableTransform())
        transforms.append(DirectiveTransform())
        transforms.append(ReduceTransform())
        transforms.append(ReduceSectionTransform())
        
        reader = BundleReader()
    }
    
    convenience init(reader: ReparoReader) {
        self.init()
        
        self.reader = reader
    }
    
    /**
     Parses the given file into a configuration document
     
     - Parameter filename:  The filename to parse
     
     - Throws:              Reparo.InvalidConfigurationLine if the configuration is invalid
     
     - Returns:             A configuration document object
     */
    public func parseFile(filename: String) throws -> Document {
        return try parseFile(filename, runTransforms: true)
    }
    
    /**
     Parses the given file into a configuration document
     
     - Parameter filename:      The filename to parse
     - Parameter runTransforms: A flag indicating whether to run the configuration transforms
     
     - Throws:              Reparo.InvalidConfigurationLine if the configuration is invalid
     
     - Returns:             A configuration document object
     */
    public func parseFile(filename: String, runTransforms: Bool) throws -> Document {
        if let input = try reader.readFile(filename) {
            return try parseString(input, filename: filename, runTransforms: runTransforms)
        } else {
            throw ReparoError.MissingConfigurationFile(filename)
        }
    }
    
    /**
     Parses the given string into a configuration document
     
     - Parameter input:      The string to parse
     - Parameter filename:   The filename of the string being parsed
     
     - Throws:               Reparo.InvalidConfigurationLine if the configuration is invalid
     
     - Returns:              A configuration document object
     */
    public func parseString(input: String, filename: String) throws -> Document {
        return try parseString(input, filename: filename, runTransforms: true)
    }
    
    /**
     Parses the given string into a configuration document
     
     - Parameter input:      The string to parse
     - Parameter filename:   The filename of the string being parsed
     - Parameter transform:  Flag indicating whether to transform the configuration
     
     - Throws:               Reparo.InvalidConfigurationLine if the configuration is invalid
     
     - Returns:              A configuration document object
     */
    public func parseString(input: String, filename: String, runTransforms: Bool) throws -> Document {
        var document = Document(filename: filename)
        
        let machine = StateMachine(input: input, filename: filename)
        
        var index = 1
        
        while !machine.empty {
            var line = try machine.read()
            
            if line == nil {
                break
            }
            
            if let section = line as? Section {
                line = try parseSection(section, machine: machine)
            }
            
            line!.parent = document
            line!.index = index
            
            document.lines.append(line!)
            
            index += 1
        }
                
        if (runTransforms) {
            document = try transform(document)
        }
        
        return document
    }
    
    private func parseSection(section: Section, machine: StateMachine) throws -> Section {
        var index = 1
        var seenEnd = false
        while !machine.empty {
            var line = try machine.read()
            
            if line == nil {
                throw ReparoError.MissingSectionEnd("Section end is missing: \(section.key) Line: \(section.lineNumber)")
            }
            
            if line!.isEndOfSection {
                seenEnd = true
                break
            }
            
            if let section = line as? Section {
                line = try parseSection(section, machine: machine)
            }
            
            line!.parent = section
            line!.index = index
            
            section.lines.append(line!)
            index += 1
        }
        
        if !seenEnd {
            if section.key != nil {
                throw ReparoError.MissingSectionEnd("Section end is missing: \(section.key) Line: \(section.lineNumber)")
            } else {
                throw ReparoError.MissingSectionEnd("Section end is missing: Line: \(section.lineNumber)")
            }
        }
        
        return section
    }
    
    public func transform(document: Document) throws -> Document {
        let transformed = document
        if transformed.lines.count > 0 {
            for transform in transforms {
                transformed.lines = try transform.transform(transformed.lines, parser: self)
                
                if transformed.lines.count == 0 {
                    throw ReparoError.InvalidConfigurationLine("oops")
                }
            }
        }
        
        return transformed
    }
}


/**
Reparo State Machine that parses configuration files
 */
public class StateMachine {
    private var values: [String]
    private var filename: String
    private var lineNumber: Int
    private var state: State
    private var popState: State
    private var next: String
    private var directive: Directive?
    
    private enum State {
        case Key
        case Value
        case Semicolon
        case IfDirective
        case SingleLineComment
        case MultiLineComment
        case DoubleQuote
        case SingleQuote
        case EndQuote
        case Push
    }

    /**
     Creates a new state machine with the given configuration string
     
     - Parameter input:      The configuration string
     - Parameter filename:   The filename of the string being parsed
     
     - Throws:               Reparo.InvalidConfigurationLine if the configuration is invalid
     */
    init(input: String, filename: String) {
        values = input.characters.map { String($0) }
        lineNumber = 1
        state = State.Key
        popState = State.Key
        next = ""
        self.filename = filename
    }
    
    /**
     Reads a single line of the configuration string.  Returns nil if the next line is either the end
     of a section, or the end of the string has been reached.
     
     - Throws:               Reparo.InvalidConfigurationLine if the configuration is invalid
     
     - Returns:              A configuration line object
     */
    func read() throws -> Line? {
        if (values.count == 0) {
            return nil
        }
        
        var line: Line? = Line(filename: filename, lineNumber: lineNumber)
        
        while (values.count > 0)
        {
            next = values[0]
            values.removeAtIndex(0)
            
            if newline() {
                lineNumber = lineNumber + 1
                
                if (line != nil) {
                    line!.lineNumber = lineNumber
                }
            }
            
            switch state {
            case State.Key:
                line = try readKey(line)
                break
            case State.Value:
                line = try readValue(line)
                break
            case State.IfDirective:
                line = readIfDirective(line)
                break
            case State.SingleLineComment:
                line = readSingleLineComment(line)
                break
            case State.MultiLineComment:
                line = readMultiLineComment(line)
                break
            case State.SingleQuote:
                line = readSingleQuote(line)
                break
            case State.DoubleQuote:
                line = readDoubleQuote(line)
                break
            case State.EndQuote:
                line = try readEndQuote(line)
                break
            default:
                break
            }
            
            if (state == State.Push)
            {
                break
            }
        }
        
        // Empty data if not a section
        if let l = line where l.key == nil && l.value == nil && !l.isASection {
            line = nil
        }
            
            // Ran out of data...
        else if state == State.Key || state == State.Value
        {
            throw ReparoError.InvalidConfigurationLine("Invalid configuration line: \(lineNumber)")
        }
        
        
        // Reset state
        if state == State.Push
        {
            state = State.Key
        }
        
        return line
    }
    
    /**
     Returns a value indicating whether the state machine has processed all configuration
     lines.
     */
    var empty: Bool {
        return values.count == 0
    }
    
    private func readKey(line: Line?) throws -> Line? {
        if next == ";" {
            state = State.Push
        }
        else if next == ":" {
            line?.key = trim(line?.key)
            
            state = State.Value
        }
        else if peek("@if")
        {
            state = State.IfDirective
            
            values.removeAtIndex(0)
            values.removeAtIndex(0)
            
            line?.key = trim(line?.key)
        }
        else if next == "{"
        {
            state = State.Push
            
            line?.key = trim(line?.key)
            
            return Section(line: line!)
        }
        else if next == "}"
        {
            if nilOrEmpty(line?.key)
            {
                state = State.Push
                
                line?.key = "}"
                
                return line
            }
            else
            {
                throw ReparoError.InvalidConfigurationLine("Unexpected end of section character ('}') : \(lineNumber)")
            }
        }
        else if next == "#"
        {
            if line?.key == nil || line?.key == ""
            {
                state = State.SingleLineComment
                
                return nil
            }
            else
            {
                throw ReparoError.InvalidConfigurationLine("Unexpected start of comment character ('#'): \(lineNumber)")
            }
        }
        else if peek("/*")
        {
            values.removeAtIndex(0)
            
            popState = state
            
            state = State.MultiLineComment
        }
        else if whitespaceOrNewLine() && nilOrEmpty(line?.key) {
            // ignore
        }
            
        else if newline() {
            throw ReparoError.InvalidConfigurationLine("Unexpected new line in configuration key: \(lineNumber)")
        }
            
            
        else if line!.key == nil {
            line!.key = next
        }
            
        else {
            line!.key = line!.key! + next
        }
        
        return line
    }
    
    private func readValue(line: Line?) throws -> Line? {
        // Check end of value
        if next == ";" {
            line?.value = trim(line?.value)
            
            state = State.Push
        }
            
            // Ignore leading whitespace
        else if whitespace() && nilOrEmpty(line?.value)
        {
            // ignore
        }
            
            // Test for directive
        else if peek("@if") {
            values.removeAtIndex(0)
            values.removeAtIndex(0)
            
            line?.value = trim(line?.value)
            
            state =  State.IfDirective
        }
            
            // Multiline comment
        else if peek("/*") {
            values.removeAtIndex(0)
            
            popState = state
            
            state = State.MultiLineComment
        }
            
            // Double quote
        else if next == "\"" && nilOrEmpty(line?.value) {
            state = State.DoubleQuote
        }
            
            // Single quote
        else if next == "'" && nilOrEmpty(line?.value) {
            state = State.SingleQuote
        }

            // New section
        else if next == "{"
        {
            state = State.Push
            
            line?.value = trim(line?.value)
            
            return Section(line: line!)
        }
            
            // Invalid newline check
        else if newline() {
            throw ReparoError.InvalidConfigurationLine("Unexpected new line in configuration value: \(lineNumber)")
        }
            
            // Initialize value
        else if line!.value == nil {
            line!.value = next
        }
            
            // Append value
        else {
            line!.value = line!.value! + next
        }
        
        return line
    }
    
    private func readIfDirective(line: Line?) -> Line? {
        if next == ";" {
            if directive != nil {
                directive!.name = trim(directive!.name)!
                line?.directives.append(directive!.clone())
                directive = nil
            }
            
            state = State.Push
        }
            
        else if next == "{" {
            if directive != nil {
                directive!.name = trim(directive!.name)!
                line?.directives.append(directive!.clone())
                directive = nil
            }
            
            state = State.Push
            
            return Section(line: line!)
        }
            
        else if next == "," {
            if directive != nil {
                directive!.name = trim(directive!.name)!
                line?.directives.append(directive!.clone())
            }
            
            directive = nil
        }
            
        else if next == "!" && directive == nil {
            directive = Directive(name: "", not: true)
        }
            
        else if whitespace() && directive == nil {
            // ignore
        }
            
        else if directive == nil {
            directive = Directive(name: next, not: false)
        }
            
        else {
            directive!.name = directive!.name + next
        }
        
        return line
    }
    
    private func readSingleLineComment(line: Line?) -> Line? {
        if newline() {
            state = State.Key
            
            return Line(filename: filename, lineNumber: lineNumber)
        }
        
        return line
    }
    
    private func readMultiLineComment(line: Line?) -> Line? {
        if peek("*/") {
            values.removeAtIndex(0)
            
            state = popState
        }
        
        return line
    }
    
    private func readDoubleQuote(line: Line?) -> Line? {
        if peek("\"\"") {
            values.removeAtIndex(0)
            
            line!.value! = line!.value! + next
        }
        else if next == "\"" {
            state = State.EndQuote
        }
        else if line!.value == nil {
            line!.value = next
        }
        else {
            line!.value! = line!.value! + next
        }
        
        return line
    }
    
    private func readSingleQuote(line: Line?) -> Line? {
        if peek("''") {
            values.removeAtIndex(0)
            
            line!.value! = line!.value! + next
        }
        else if next == "'" {
            state = State.EndQuote
        }
        else if line!.value == nil {
            line!.value = next
        }
        else {
            line!.value! = line!.value! + next
        }
        
        return line
    }
    
    private func readEndQuote(line: Line?) throws -> Line? {
        if whitespace() {
            // ignore
        }
        else if next == ";" {
            state = State.Push
        }
        else if peek("@if") {
            values.removeAtIndex(0)
            values.removeAtIndex(0)
            
            state = State.IfDirective
        }
        else {
            throw ReparoError.InvalidConfigurationLine("Unexpected character after quoted value: \(next) \(lineNumber)")
        }
        
        return line
    }
    
    private func peek(input: String) -> Bool {
        if !input.hasPrefix(next) {
            return false
        }
        
        var result = false
        
        if values.count >= input.characters.count {
            var peek = next
            for i in 0...(input.characters.count - 2) {
                peek += values[i]
            }
            
            if peek == input
            {
                result = true
            }
        }
        
        return result
    }
    
    private func whitespace() -> Bool {
        if next == " "
        {
            return true
        }
        if next == "\t"
        {
            return true
        }
        
        return false
    }
    
    private func newline() -> Bool {
        if next == "\r" {
            return true
        }
        if next == "\n" {
            return true
        }
        if next == "\r\n" {
            return true
        }
        return false
    }
    
    private func whitespaceOrNewLine() -> Bool {
        return whitespace() || newline()
    }
    
    private func nilOrEmpty(value: String?) -> Bool {
        return value == nil || value == ""
    }
    
    private func trim(input: String?) -> String? {
        return input?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}

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

/**
 Performs variable substitution configuration
*/
public class VariableTransform : ReparoTransform {
    /**
     Performs variable substitution on the given configuration lines
     
     - Parameter lines:      The configuration to transform
     - Parameter parser:     The configuration parser the transform is being called from
     
     - Throws:               ReparoError if the configuration is invalid
     
     - Returns:              The transformed configuration lines
     */
    public func transform(lines: [Line], parser: Parser) throws -> [Line] {
        return try transform(lines, parser: parser, variables: parser.variables)
    }

    private func transform(lines: [Line], parser: Parser, variables: [String: String]) throws -> [Line] {
        var scope = variables
        for line in lines {
            scope = assign(line, variables: scope)
            line.value = substitute(line.value, variables: scope)
            
            if let section = line as? Section {
                try transform(section.lines, parser: parser, variables: scope)
            }
        }
        
        return lines
    }
    
    private func assign(line: Line, variables: [String: String]) -> [String: String] {
        var scope = variables
        if let key = line.key {
            if key.hasPrefix("@set") && key.characters.count > 5 {
                var name = key.substringFromIndex(key.startIndex.advancedBy(5))
                name = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if let value = line.value {
                    scope[name] = value
                }
            }
        }
        
        return scope
    }
    
    private func substitute(value: String?, variables: [String: String]) -> String? {
        if value != nil {
            var substituted = value!
            
            for key in variables.keys {
                if (value!.containsString("@\(key)")) {
                    substituted = substituted.stringByReplacingOccurrencesOfString("@\(key)", withString: variables[key]!)
                }
            }
            
            return substituted
        }
        
        return nil
    }
}

public class DirectiveTransform : ReparoTransform {
    public func transform(lines: [Line], parser: Parser) throws -> [Line] {
        var transformed: [Line] = []
        for line in lines {
            if line.directives.count > 0 {
                var include = true
                
                for directive in line.directives {
                    let matches = parser.directives.filter { d in d == directive.name }.count
                    
                    include = matches > 0
                    
                    if directive.not {
                        include = !include
                    }
                    
                    if !include {
                        break
                    }
                }
                
                if !include {
                    continue
                }
            }
            
            if let section = line as? Section {
                section.lines = try transform(section.lines, parser: parser)
                
                transformed.append(section)
            } else {
                transformed.append(line)
            }
        }
        
        return transformed
    }
}

public class IncludeTransform : ReparoTransform {
    var includeCount = 0
    var includeLimit = 0
    public func transform(lines: [Line], parser: Parser) throws -> [Line] {
        includeCount = 1
        includeLimit = 0
        
        var transformed: [Line] = lines
        while (includeCount > 0) {
            transformed = try expand(transformed, parser: parser)
            
            if (includeLimit > 255) {
                throw ReparoError.RecursiveIncludeDetected
            }
        }
        
        return transformed
    }
    
    private func expand (lines: [Line], parser: Parser) throws -> [Line] {
        includeCount = 0
        includeLimit = includeLimit + 1
        
        var transformed: [Line] = []
        
        for line in lines {
            if line.key != nil && line.key!.hasPrefix("@include") {
                if let filename = line.value {
                    
                    // Read include file
                    let input = try parser.reader.readIncludeFile(filename)
                    
                    // Check exists
                    if input == nil {
                        throw ReparoError.MissingConfigurationFile(filename)
                    }
                    
                    // Parse include
                    let include = try parser.parseString(input!, filename: filename, runTransforms: false)
                    
                    // Append child lines (include arguments)
                    if let section = line as? Section {
                        transformed.appendContentsOf(section.lines)
                    }
                    
                    // Append include
                    transformed.appendContentsOf(include.lines)
                    
                    includeCount = includeCount + 1
                }
            } else if let section = line as? Section {
                section.lines = try expand(section.lines, parser: parser)
                transformed.append(section)
            } else {
                transformed.append(line)
            }
        }
        
        return transformed
    }
}

/**
 Declares and inserts configuration functions
 */
public class FunctionTransform : ReparoTransform {
    public func transform(lines: [Line], parser: Parser) throws -> [Line] {
        return transform(lines, parser: parser, functions: [String: [Line]]())
    }
    
    private func transform(lines: [Line], parser: Parser, functions: [String: [Line]]) -> [Line] {
        var transformed = [Line]()
        var scope = functions
        var count = 1
        
        for line in lines {
            scope = assign(line, functions: scope)
            
            line.index = count
            count += 1
            
            if isFunctionCall(line, functions: scope) {
                let substituted = substitute(line, functions: scope)
                for l in substituted {
                    l.index = count
                    l.parent = line.parent
                    transformed.append(l)
                    count += 1
                }
            } else if let section = line as? Section {
                section.lines = transform(section.lines, parser: parser, functions: scope)
                transformed.append(section)
            } else {
                transformed.append(line)
            }
        }
        
        return transformed
    }
    
    private func assign(line: Line, functions: [String: [Line]]) -> [String: [Line]] {
        var scope = functions
        if let key = line.key, name = line.value, function = line as? Section where key == "@define" {
            scope[name] = function.lines
        }
        
        return scope
    }

    private func isFunctionCall(line: Line, functions: [String: [Line]]) -> Bool {
        if let key = line.key where key.hasPrefix("@") {
            let name = key.substringFromIndex(key.startIndex.advancedBy(1))
            return functions[name] != nil
        }
        
        return false
    }
    
    private func substitute(line: Line, functions: [String: [Line]]) -> [Line] {
        if let key = line.key where key.hasPrefix("@") {
            let name = key.substringFromIndex(key.startIndex.advancedBy(1))
            if let function = functions[name] {
                var lines = [Line]()
                
                // Add function arguments
                if let arguments = line as? Section {
                    for argument in arguments.lines {
                        if let key = argument.key {
                            argument.key = "@set " + key
                            lines.append(argument)
                        }
                    }
                }
                
                for line in function {
                    lines.append(line.clone())
                }
                
                return lines
            }
        }
        
        return [Line] (arrayLiteral: line)
    }
}

public class ReduceTransform : ReparoTransform {
    public func transform(lines: [Line], parser: Parser) throws -> [Line] {
        var transformed: [Line] = []
        var reduced: [Line] = []
        for line in lines {            
            if let section = line as? Section {
                section.lines = try transform(section.lines, parser: parser)
                
                if section.directives.count > 0 && section.key == nil {
                    reduced.appendContentsOf(section.lines)
                }
                
                transformed.append(section)
            } else {
                transformed.append(line)
            }
        }
        
        for reduce in reduced {
            if let key = reduce.key {
                transformed = removeKeys(transformed, key: key)
            }
            
            transformed.append(reduce)
        }
        
        return transformed
    }
    
    func removeKeys(lines: [Line], key: String) -> [Line] {
        return lines.filter { line in line.key != key }
    }
}

public class ReduceSectionTransform : ReparoTransform {
    public func transform(lines: [Line], parser: Parser) throws -> [Line] {
        var transformed: [Line] = []
        
        for line in lines {
            // Don't include duplicate sections if they have directives
            if hasMultipleKeys(lines, key: line.key) {
                if line.directives.count < maxDirectiveCount(lines, key: line.key) {
                    continue
                }
            }
            
            if let section = line as? Section {
                section.lines = try transform(section.lines, parser: parser)
                
                transformed.append(section)
            } else {
                transformed.append(line)
            }
        }
        
        return transformed
    }
    
    func hasMultipleKeys(lines: [Line], key: String?) -> Bool {
        guard let key = key else {
            return false
        }
        
        var count = 0
        
        for line in lines {
            if line.key == key {
                count += 1
            }
        }
        
        return count > 1
    }
    
    func maxDirectiveCount(lines: [Line], key: String?) -> Int {
        guard let key = key else {
            return 0
        }
        
        var count = 0
        
        for line in lines {
            if line.key == key {
                if line.directives.count > count {
                    count = line.directives.count
                }
            }
        }
        
        return count
    }
}

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

}

enum ReparoError: ErrorType {
    case InvalidConfigurationLine(String)
    case InvalidColorString(String)
    case MissingConfigurationFile(String)
    case RecursiveIncludeDetected
    case MissingSectionEnd(String)
}



