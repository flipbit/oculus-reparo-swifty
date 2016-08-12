import Foundation
import UIKit

public class Layout {
    static public var layerBuilders: [LayerBuilder] = []
    static public var viewBuilders: [ViewBuilder] = []
    static public var imageLoader: UIImageLoader = MainBundleImageLoader()
    static private var initialized = false

    private var _laidOut = false
    public var laidOut: Bool {
        return _laidOut
    }
    
    public var views: [String: UIView]
    public var layers: [String: CALayer]
    public var variables: [String: AnyObject]
    public var directives: [String]
    public var model: NSObject?
    public var eventTarget: AnyObject?
    public var view: UIView?
    public var filename: String?
    public var screenSize: CGRect
    public var enableAutoRotation = false
    public var enableAutoResizing = false
    
    var dataSources = [UITableViewDataSource]()
    
    public init() {
        variables = [:]
        directives = []
        views = [:]
        layers = [:]

        // Set screen size
        if let window = UIApplication.sharedApplication().keyWindow {
            screenSize = window.bounds
        } else {
            screenSize = CGRectZero
        }

        
        // append default builders
        if !Layout.initialized {
            // View builders
            Layout.viewBuilders.append(UIViewBuilder())
            Layout.viewBuilders.append(UILabelBuilder())
            Layout.viewBuilders.append(UISliderBuilder())
            Layout.viewBuilders.append(UIButtonBuilder())
            Layout.viewBuilders.append(UIImageViewBuilder())
            Layout.viewBuilders.append(UITableViewBuilder())
            Layout.viewBuilders.append(UIScrollViewBuilder())
            Layout.viewBuilders.append(UITextFieldBuilder())
            Layout.viewBuilders.append(UICollectionViewBuilder())

            // Layer builders
            Layout.layerBuilders.append(CALayerBuilder())
                
            Layout.initialized = true
        }
        
        // append default directives
        directives.append("device:" + Hardware.device.rawValue)
        directives.append("device-type:" + Hardware.deviceType.rawValue)
        directives.append("screen:" + Hardware.screenSize.rawValue)
        directives.append(Hardware.orientation)
        
        // register for orientation changes
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self, selector: #selector(rotate), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

    public convenience init(filename: String, view: UIView) {
        self.init()
        
        self.view = view
        self.eventTarget = view
        self.filename = filename
    }
    
    public convenience init(filename: String, controller: UIViewController) {
        self.init()
        
        self.view = controller.view
        self.eventTarget = controller
        self.filename = filename
    }
    
    public convenience init(filename: String) {
        self.init()
        
        self.filename = filename
    }
    
    deinit {
        // unregister orientation changes
        NSNotificationCenter
            .defaultCenter()
            .removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)

    }

    public func apply() throws {
        try apply(filename!)
    }
    
    public func apply(filename: String) throws {
        guard let view = view else {
            throw LayoutError.MissingRootView
        }
        
        self.filename = filename
        
        let parser = Parser(layout: self)
        
        let layout = try parser.parseFile(filename)
                
        try setProperties(layout, view: view)
        
        for section in layout.sections {
            try build(section, parent: view)
        }
        
        _laidOut = true
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
    
    public func findLayer(layerId: String) -> CALayer? {
        if layers[layerId] != nil {
            return layers[layerId]
        }
        
        return nil
    }
    
    public func hasLayer(layerId: String) -> Bool {
        return layers[layerId] != nil
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
    static public func register(builder: ViewBuilder) {
        Layout.viewBuilders.append(builder)
    }
    
    @objc private func rotate() throws {
        if enableAutoRotation {
            clearDirective("landscape")
            clearDirective("portrait")
            directives.append(Hardware.orientation)
            
            if let window = UIApplication.sharedApplication().keyWindow {
                screenSize = window.bounds
            }
            
            if let filename = filename {
                try apply(filename)
            }
        }
    }
    
    private func setProperties(layout: Section, view: UIView) throws {
        if let properties = layout.getSection("layout") {
            view.backgroundColor = try properties.getUIColor("background-color")
            
            var width = view.frame.width, height = view.frame.height
            
            width = try properties.getCGFloat("width", ifMissing: width)
            height = try properties.getCGFloat("height", ifMissing: height)
            
            view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: width, height: height)
        }
    }
    
    private func build(layout: Section, parent: UIView) throws {
        for builder in Layout.viewBuilders {
            if (builder.canBuild(layout)) {
                let view = try builder.build(layout, instance: self, parent: parent)
                
                for section in layout.sections {
                    try build(section, parent: view)
                }
                    
                break
            }
        }
        
        for builder in Layout.layerBuilders {
            if (builder.canBuild(layout)) {
                let layer = try builder.build(layout, instance: self, parent: parent)
                
                break
            }
        }
    }
}
