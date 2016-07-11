//
// Oculus Reparo View Layout
//
import Foundation
import UIKit


public protocol BuilderProtocol {
    func canBuild(layout: Reparo.Section) -> Bool
    
    func build(layout: Reparo.Section, state: OculusReparo.ViewState, parent: UIView) throws -> UIView
}



public struct OculusReparo {
    var builders: [BuilderProtocol]
    
    init() {
        builders = []
        
        builders.append(ViewBuilder())
        builders.append(LabelBuilder())
        builders.append(SliderBuilder())
        builders.append(ButtonBuilder())
        builders.append(ImageViewBuilder())
    }
    
    public func layout(filename: String, state: ViewState) throws -> ViewState {
        let parser = Reparo.Parser()
        parser.directives = state.directives
        
        let layout = try parser.parseFile(filename)
        
        try setProperties(layout, view: state.view)
        
        for section in layout.sections {
            try build(section, state: state, parent: state.view)
        }
        
        return state
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
    
    private func setProperties(layout: Reparo.Section, view: UIView) throws {
        if let properties = layout.getSection("layout") {
            view.backgroundColor = try properties.getUIColor("background-color")
        }
    }
    
    private func build(layout: Reparo.Section, state: ViewState, parent: UIView) throws {
        for builder in builders {
            if (builder.canBuild(layout)) {
                let view = try builder.build(layout, state: state, parent: parent)
                
                for section in layout.sections {
                    try build(section, state: state, parent: view)
                }
                    
                break
            }
        }
    }
}




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



extension OculusReparo {
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
            case iPad = "iPad"
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
}



extension OculusReparo {
    
    public class ViewState {
        var views: [String: UIView]
        var variables: [String: String]
        var directives: [String]
        var model: NSObject?
        var eventTarget: AnyObject?
        var view: UIView
        
        init(view: UIView) {
            variables = [:]
            directives = []
            views = [:]
            self.view = view
            
            // append default directives
            directives.append("device:" + Hardware.device.rawValue)
            directives.append("device-type:" + Hardware.deviceType.rawValue)
            directives.append("screen:" + Hardware.screenSize.rawValue)
            directives.append(Hardware.orientation)
        }
        
        public func clearDirective(directive: String) {
            let index = directives.indexOf(directive)
            if let index = index {
                directives.removeAtIndex(index)
            }
        }
        
        public func findView(layout: Reparo.Section) -> UIView? {
            if views[layout.path] != nil {
                return views[layout.path]
            }
            
            return nil
        }
        
        public func hasView(layout: Reparo.Section) -> Bool {
            return views[layout.path] != nil
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



extension OculusReparo {
    enum OculusReparoError: ErrorType {
        case MissingViewPosition(String)
    }
}



extension OculusReparo {
    public class Builder {
        public func initialize<T: UIView>(layout: Reparo.Section, state: ViewState, parent: UIView) throws -> T {
            var view: T
            
            if state.hasView(layout) {
                view = state.findView(layout) as! T
            } else {
                view = T()
                state.views[layout.path] = view
                
                if let id = layout.getValue("id") {
                    state.model?.setValue(view, forKey: id)
                }
            }
            
            view.frame = try getFrame(layout, parent: parent)
            view.backgroundColor = try layout.getUIColor("background-color")
            view.layer.zPosition = layout.getCGFloat("z-position", ifMissing: 0)
            view.layer.cornerRadius = layout.getCGFloat("corner-radius", ifMissing: 0)
            view.layer.borderColor = try layout.getCGColor("border-color")
            view.layer.borderWidth = layout.getCGFloat("border-width", ifMissing: 0)
            view.layer.opacity = layout.getFloat("opacity", ifMissing: 1)
            
            if view.superview == nil {
                parent.addSubview(view)
            }
            
            return view
        }
        
        public func getFrame(layout: Reparo.Section, parent: UIView) throws -> CGRect {
            let config = layout.getSection("position")
            
            if config == nil {
                throw OculusReparoError.MissingViewPosition("[\(layout.key) is missing a Position section (line: \(layout.lineNumber))")
            }
            
            let position = Position(section: config!, parent: parent)
            
            return position.toFrame()
        }        
    }
}



extension OculusReparo {
    public class ViewBuilder : Builder, BuilderProtocol {
        public func canBuild(layout: Reparo.Section) -> Bool {
            return layout.key == "view"
        }
        
        public func build(layout: Reparo.Section, state: ViewState, parent: UIView) throws -> UIView {
            let view: UIView = try initialize(layout, state: state, parent: parent)
            
            return view;
        }
    }
}



extension OculusReparo {
    public class LabelBuilder : Builder, BuilderProtocol {
        public func canBuild(layout: Reparo.Section) -> Bool {
            return layout.key == "label"
        }
        
        public func build(layout: Reparo.Section, state: ViewState, parent: UIView) throws -> UIView {
            let label: UILabel = try initialize(layout, state: state, parent: parent)
            
            label.text = layout.getValue("text")
            label.textColor = try layout.getUIColor("text-color")
            
            return label;
        }
    }
}


extension OculusReparo {
    public class SliderBuilder : Builder, BuilderProtocol {
        public func canBuild(layout: Reparo.Section) -> Bool {
            return layout.key == "slider"
        }
        
        public func build(layout: Reparo.Section, state: ViewState, parent: UIView) throws -> UIView {
            let slider: UISlider = try initialize(layout, state: state, parent: parent)
            
            slider.minimumValue = layout.getFloat("minimum-value", ifMissing: 0)
            slider.maximumValue = layout.getFloat("maximum-value", ifMissing: 100)
            slider.value = layout.getFloat("value", ifMissing: 0)
            
            if let color = try layout.getUIColor("tint-color") {
                    slider.tintColor = color
            }
            
            if let changed = layout.getValue("changed") where state.eventTarget != nil  {
                slider.addTarget(state.eventTarget!, action: Selector(changed), forControlEvents: UIControlEvents.TouchUpInside)
                slider.addTarget(state.eventTarget!, action: Selector(changed), forControlEvents: UIControlEvents.TouchUpOutside)
            }
            
            return slider;
        }
    }
}



extension OculusReparo {
    public class ButtonBuilder : Builder, BuilderProtocol {
        public func canBuild(layout: Reparo.Section) -> Bool {
            return layout.key == "button"
        }
        
        public func build(layout: Reparo.Section, state: ViewState, parent: UIView) throws -> UIView {
            let button: UIButton = try initialize(layout, state: state, parent: parent)
            
            if let title = layout.getValue("title") {
                button.setTitle(title, forState: UIControlState.Normal)
            }
            
            button.tintColor = try layout.getUIColor("tint-color")
            
            if state.eventTarget != nil {
                if let touched = layout.getValue("touched") {
                    button.addTarget(state.eventTarget!, action: Selector(touched), forControlEvents: UIControlEvents.TouchUpInside)
                    button.addTarget(state.eventTarget!, action: Selector(touched), forControlEvents: UIControlEvents.TouchUpOutside)
                }
            }
            
            return button;
        }
    }
}



extension OculusReparo {
    public class ImageViewBuilder : Builder, BuilderProtocol {
        public func canBuild(layout: Reparo.Section) -> Bool {
            return layout.key == "image-view"
        }
        
        public func build(layout: Reparo.Section, state: ViewState, parent: UIView) throws -> UIView {
            let button: UIImageView = try initialize(layout, state: state, parent: parent)
                        
            return button;
        }
    }
}

