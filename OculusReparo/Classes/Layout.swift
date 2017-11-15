import Foundation
import UIKit

open class Layout {
    static open var layerBuilders: [LayerBuilder] = []
    static open var viewBuilders: [ViewBuilder] = []
    static open var imageLoader: UIImageLoader = MainBundleImageLoader()
    static open var transformer: LayoutTransformer = LayoutTransformer()
    static open var debugger: LayoutDebugger? = ConsoleLayoutDebugger()
    static open var constrainer: LayoutConstrainer? = LayoutConstrainer()
    
    static fileprivate var initialized = false

    fileprivate var orientation = Hardware.orientation
    
    fileprivate var _laidOutCount = 0
    open var laidOutCount: Int {
        return _laidOutCount
    }
    
    fileprivate var _laidOut = false
    open var laidOut: Bool {
        return _laidOut
    }

    open var bounds: CGSize = CGSize.zero
    
    open var variables: [String: AnyObject]
    open var directives: [String]
    open var model: NSObject?
    open var eventTarget: AnyObject?
    open var view: UIView?
    open var filename: String?
    
    
    open var viewFragments = [String: LayoutViewFragment]()
    open var layerFragments = [String: LayoutLayerFragment]()
    
    open var needsLayout: Bool {
        if laidOut == false {
            return true
        }
        
        if let view = view {
            if view.bounds.height != bounds.height {
                return true
            }
            
            if view.bounds.width != bounds.width {
                return true
            }
        }
        
        if orientation != Hardware.orientation {
            return true
        }
        
        return false
    }
    
    var dataSources = [UITableViewDataSource]()
    
    public init() {
        variables = [:]
        directives = []
        
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
            Layout.viewBuilders.append(UISearchBarBuilder())
            Layout.viewBuilders.append(UITextFieldBuilder())
            Layout.viewBuilders.append(UICollectionViewBuilder())
            Layout.viewBuilders.append(UIActivityIndicatorBuilder())
            Layout.viewBuilders.append(UIWebViewBuilder())

            // Layer builders
            Layout.layerBuilders.append(CALayerBuilder())
                
            Layout.initialized = true
        }
        
        // append default directives
        directives.append("device:" + Hardware.device.rawValue)
        directives.append("device-type:" + Hardware.deviceType.rawValue)
        directives.append("screen:" + Hardware.screenSize.rawValue)
        directives.append(Hardware.orientation)
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
    
    open func apply() throws {
        try apply(filename!)
    }
    
    open func apply(_ filename: String) throws {
        guard let view = view else {
            throw LayoutError.missingRootView
        }
                
        bounds = view.bounds.size
        orientation = Hardware.orientation
        
        Layout.debugger?.debug("Laying out view    : \(filename)")
        Layout.debugger?.debug("Screen Orientation : \(orientation)")
        Layout.debugger?.debug("View Height        : \(view.frame.height)")
        Layout.debugger?.debug("View Width         : \(view.frame.width)")
        
        Layout.debugger?.debug("\(directives.count) Directives:")
        for directive in directives {
            Layout.debugger?.debug("  \(directive)")
        }                
        
        self.filename = filename

        _ = Layout.transformer.transform(layout: self)

        let parser = Parser(layout: self)
        
        let layout = try parser.parseFile(filename)
        
        try setProperties(layout, view: view)
        
        for section in layout.sections {
            try build(section, parent: view)
        }
        
        if _laidOut == false {
            try addConstraints()
        }
        
        _laidOut = true
        
        _laidOutCount = _laidOutCount + 1
    }
    
    open func addConstraints() throws {
        try Layout.constrainer?.add(self)
    }
    
    func debug(_ layout: Document) {
        let lines = layout.toString().components(separatedBy: "\n")
        
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
    
    open func clearDirective(_ directive: String) {
        let index = directives.index(of: directive)
        if let index = index {
            directives.remove(at: index)
        }
    }

    open func clearVariable(_ name: String) {
        let index = variables.index(forKey: name)
        if let index = index {
            variables.remove(at: index)
        }
    }
    
    open func addVariable(_ name: String, value: String) {
        variables[name] = value as AnyObject?
    }
    
    open func addVariable(_ name: String, value: UIColor) {
        variables[name] = Convert.getHexColor(value) as AnyObject?
    }
    
    open func addVariable(_ name: String, value: Int) {
        variables[name] = String(value) as AnyObject?
    }
    
    open func addVariable(_ name: String, value: Float) {
        variables[name] = String(value) as AnyObject?
    }
    
    open func find<T>(_ viewId: String) -> T {
        return findView(viewId) as! T
    }
    
    open func findView(_ viewId: String) -> UIView? {
        if viewFragments[viewId] != nil {
            return viewFragments[viewId]?.view
        }
        
        return nil
    }
    
    open func hasView(_ viewId: String) -> Bool {
        return viewFragments[viewId] != nil
    }
    
    open func findLayer(_ layerId: String) -> CALayer? {
        if layerFragments[layerId] != nil {
            return layerFragments[layerId]?.layer
        }
        
        return nil
    }
    
    open func hasLayer(_ layerId: String) -> Bool {
        return layerFragments[layerId] != nil
    }
    
    open func handleLayoutError(_ message: String) {
        if let view = view {
            for subview in view.subviews {
                subview.removeFromSuperview()
            }

            view.backgroundColor = UIColor.white

            let header = UIView()
            header.backgroundColor = UIColor.red
            header.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
            view.addSubview(header)
            
            let title = UILabel()
            title.frame = CGRect(x: 8, y: 30, width: view.frame.width - 16, height: 30)
            title.textColor = UIColor.white
            title.backgroundColor = UIColor.red
            title.text = "Error Processing Layout"
            title.font = UIFont.boldSystemFont(ofSize: 17)
            header.addSubview(title)
            
            let label = UILabel()
            label.frame = CGRect(x: 8, y: 68, width: view.frame.width - 16, height: view.frame.height - 68)
            label.textColor = UIColor.red
            label.backgroundColor = UIColor.white
            label.text = message
            label.font = UIFont(name: "Courier", size: 15)
            label.numberOfLines = 100
            label.sizeToFit()
            view.addSubview(label)
        } else {
            print(message)
        }
    }
    
    static open func generateErrorMessage(_ layout: Section, key: String?) -> String {
        var message = "\n\nError occured at:\n\n"
        
        if let key = layout.key {
            message.append("Section name      : \(key)\n")
        }
        
        if let key = key {
            for line in layout.lines {
                if line.key == key {
                    message.append("Line path         : \(line.path)\n")
                    message.append("Line key          : \(key)\n")
                    
                    if let value = line.value {
                        message.append("Line value        : \(value)\n")
                    }
                    
                    message.append("Filename          : \(line.filename)\n")
                    message.append("Line number       : \(line.lineNumber)\n\n")
                }
            }
        }
        
        return message
    }

    /**
     Registers the given builder
    */
    static open func register(_ builder: ViewBuilder) {
        Layout.viewBuilders.append(builder)
    }
    
    fileprivate func setProperties(_ layout: Section, view: UIView) throws {
        if let properties = layout.getSection("layout") {
            view.backgroundColor = try properties.getUIColor("background-color")
            
            var width = view.frame.width, height = view.frame.height
            
            width = properties.getCGFloat("width", ifMissing: width)
            height = properties.getCGFloat("height", ifMissing: height)
            
            view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: width, height: height)
        }
    }
    
    fileprivate func build(_ layout: Section, parent: UIView) throws {
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
                let layer = try builder.build(layout, instance: self, parent: parent.layer)

                for section in layout.sections {
                    try build(section, parent: layer)
                }
                
                break
            }
        }
    }
    
    fileprivate func build(_ layout: Section, parent: CALayer) throws {
        for builder in Layout.layerBuilders {
            if (builder.canBuild(layout)) {
                let layer = try builder.build(layout, instance: self, parent: parent)
                
                for section in layout.sections {
                    try build(section, parent: layer)
                }
                
                break
            }
        }
    }
}
