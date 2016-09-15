import Foundation
import UIKit

public class Layout {
    static public var layerBuilders: [LayerBuilder] = []
    static public var viewBuilders: [ViewBuilder] = []
    static public var imageLoader: UIImageLoader = MainBundleImageLoader()
    static public var debugger: LayoutDebugger?
    
    static private var initialized = false

    private var orientation = Hardware.orientation
    
    private var _laidOut = false
    public var laidOut: Bool {
        return _laidOut
    }

    public var bounds: CGSize = CGSize.zero
    
    public var variables: [String: AnyObject]
    public var directives: [String]
    public var model: NSObject?
    public var eventTarget: AnyObject?
    public var view: UIView?
    public var filename: String?
    
    
    public var viewFragments = [String: LayoutViewFragment]()
    public var layerFragments = [String: LayoutLayerFragment]()
    
    public var needsLayout: Bool {
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
    
    public func apply() throws {
        try apply(filename!)
    }
    
    public func apply(filename: String) throws {
        guard let view = view else {
            throw LayoutError.MissingRootView
        }
        
        
        bounds = view.bounds.size
        orientation = Hardware.orientation
        
        Layout.debugger?.info("Laying out view:")
        Layout.debugger?.info("Screen Orientation : \(orientation)")
        Layout.debugger?.info("View Height        : \(view.frame.height)")
        Layout.debugger?.info("View Width         : \(view.frame.width)")
        
        Layout.debugger?.info("\(directives.count) Directives:")
        for directive in directives {
            Layout.debugger?.info("  \(directive)")
        }                
        
        self.filename = filename
        
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
    }
    
    public func addConstraints() throws {
        for key in viewFragments.keys {
            if let fragment = viewFragments[key] {
                try addConstraints(fragment)
            }
        }
    }
    
    public func addConstraints(fragment: LayoutViewFragment) throws {
        let config = fragment.configuration, view = fragment.view
        
        let tlbr = [AnchorType.Top, AnchorType.Left, AnchorType.Bottom, AnchorType.Right, AnchorType.CenterX, AnchorType.CenterY]
        
        for anchor in tlbr {
            if let section = config.getSection(anchor.rawValue) {
                let anchorToViewId = section.getValue("to", ifMissing: "@parent") ?? "@parent"
                let constant = section.getCGFloat("constant", ifMissing: 0)
                let to = try Convert.getViewIdAndAnchor(anchorToViewId, defaultIdView: "@parent", defaultAnchor: anchor)
                var anchorToView: UIView?
                
                switch to.viewId.lowercaseString {
                case "@parent":
                    anchorToView = view.superview
                    
                case "@next":
                    anchorToView = findNextSubview(view)
                    
                case "@last":
                    anchorToView = findLastSubview(view)
                    
                default:
                    anchorToView = findView(to.viewId)
                }
                
                if anchorToView == nil {
                    throw LayoutError.InvalidConfiguration("Unable to find view to anchor to: \(to.viewId)")
                }
                
                addConstraint(view, to: anchorToView!, onAnchor: anchor, toAnchor: to.anchor, constant: constant)
            }
            
            else if config.hasValue(anchor.rawValue) {
                let constant = config.getCGFloat(anchor.rawValue, ifMissing: 0)
                let parent = view.superview!
                
                addConstraint(view, to: parent, onAnchor: anchor, toAnchor: anchor, constant: constant)
            }
        }
    }
    
    func findNextSubview(view: UIView) -> UIView? {
        guard let superview = view.superview else {
            return nil
        }
        
        var next = false
        
        for subview in superview.subviews {
            if subview === view {
                next = true
            }
            
            else if next {
                return subview
            }
        }
        
        return nil
    }

    func findLastSubview(view: UIView) -> UIView? {
        guard let superview = view.superview else {
            return nil
        }
        
        var last: UIView? = nil
        
        for subview in superview.subviews {
            if subview === view {
                return last
            }
                
            last = subview
        }
        
        return nil
    }

    func addConstraint(on: UIView, to: UIView, onAnchor: AnchorType, toAnchor: AnchorType, constant: CGFloat) {
        let onAnchor = getAnchor(on, anchor: onAnchor)
        let toAnchor = getAnchor(to, anchor: toAnchor)
        
        if on.translatesAutoresizingMaskIntoConstraints {
            on.translatesAutoresizingMaskIntoConstraints = false
            
            if on.frame != CGRect.zero {
                if on.frame.height != 0 {
                    on.heightAnchor.constraintEqualToConstant(on.frame.height).active = true
                }
                if on.frame.width != 0 {
                    on.widthAnchor.constraintEqualToConstant(on.frame.width).active = true
                }
                on.frame = CGRect.zero
            }
        }
        
        onAnchor.constraintEqualToAnchor(toAnchor, constant: constant).active = true
    }
    
    func getAnchor(view: UIView, anchor: AnchorType) -> NSLayoutAnchor {
        switch (anchor) {
        case .Bottom:
            return view.bottomAnchor as NSLayoutAnchor
        case .Left:
            return view.leftAnchor as NSLayoutAnchor
        case .Right:
            return view.rightAnchor as NSLayoutAnchor
        case .Top:
            return view.topAnchor as NSLayoutAnchor
        case .CenterY:
            return view.centerYAnchor as NSLayoutAnchor
        case .CenterX:
            return view.centerXAnchor as NSLayoutAnchor
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
        variables[name] = value as AnyObject?
    }
    
    public func addVariable(name: String, value: UIColor) {
        variables[name] = Convert.getHexColor(value) as AnyObject?
    }
    
    public func addVariable(name: String, value: Int) {
        variables[name] = String(value) as AnyObject?
    }
    
    public func addVariable(name: String, value: Float) {
        variables[name] = String(value) as AnyObject?
    }
    
    public func find<T>(viewId: String) -> T {
        return findView(viewId) as! T
    }
    
    public func findView(viewId: String) -> UIView? {
        if viewFragments[viewId] != nil {
            return viewFragments[viewId]?.view
        }
        
        return nil
    }
    
    public func hasView(viewId: String) -> Bool {
        return viewFragments[viewId] != nil
    }
    
    public func findLayer(layerId: String) -> CALayer? {
        if layerFragments[layerId] != nil {
            return layerFragments[layerId]?.layer
        }
        
        return nil
    }
    
    public func hasLayer(layerId: String) -> Bool {
        return layerFragments[layerId] != nil
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
    
    private func setProperties(layout: Section, view: UIView) throws {
        if let properties = layout.getSection("layout") {
            view.backgroundColor = try properties.getUIColor("background-color")
            
            var width = view.frame.width, height = view.frame.height
            
            width = properties.getCGFloat("width", ifMissing: width)
            height = properties.getCGFloat("height", ifMissing: height)
            
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
                let layer = try builder.build(layout, instance: self, parent: parent.layer)

                for section in layout.sections {
                    try build(section, parent: layer)
                }
                
                break
            }
        }
    }
    
    private func build(layout: Section, parent: CALayer) throws {
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
