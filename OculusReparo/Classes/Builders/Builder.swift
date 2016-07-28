public class Builder {
    public init() {
    }
    
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
