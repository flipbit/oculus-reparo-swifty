import Foundation

public class Hardware {
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
    public static var deviceType: DeviceType {
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
        case Device.iPhoneSE:                return DeviceType.iPhone
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
            return "portrait"
        } else {
            return "landscape"
        }
    }
}

public enum Device : String {
    case iPodTouch5 = "ipod-touch-5"
    case iPodTouch6 = "iPod-touch-6"
    case iPhone4 = "iphone-4"
    case iPhone4s = "iphone-4s"
    case iPhone5 = "iphone-5"
    case iPhone5c = "iphone-5c"
    case iPhone5s = "iphone-5s"
    case iPhone6 = "iphone-6"
    case iPhone6Plus = "iphone-6-plus"
    case iPhone6s = "iphone-6s"
    case iPhone6sPlus = "iphone-6s-plus"
    case iPhoneSE = "iphone-se"
    case iPad2 = "ipad-2"
    case iPad3 = "ipad-3"
    case iPad4 = "ipad-4"
    case iPadAir = "ipad-air"
    case iPadAir2 = "ipad-air-2"
    case iPadMini = "ipad-mini"
    case iPadMini2 = "ipad-mini-2"
    case iPadMini3 = "ipad-mini-3"
    case iPadMini4 = "ipad-mini-4"
    case iPadPro = "ipad-pro"
    case AppleTV = "apple-tv"
    case Simulator = "simulator"
    case Unknown = "unknown"
}

public enum DeviceType : String {
    case iPodTouch = "ipod-touch"
    case iPhone = "iphone"
    case iPad = "ipad"
    case AppleTV = "apple-tv"
    case Simulator = "simulator"
    case Unknown = "unknown"
}

public enum ScreenSize : String {
    case iPhone = "iphone"
    case iPhone5 = "iphone-5"
    case iPhone6 = "iphone-6"
    case iPhone6Plus = "iphone-6-plus"
    case iPad = "ipad"
    case iPadPro = "ipad-pro"
    case AppleTV = "apple-tv"
    case Simulator = "simulator"
    case Unknown = "unknown"
}
