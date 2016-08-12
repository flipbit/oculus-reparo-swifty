import Foundation
import UIKit

public class ViewBuilder {
    public init() {
    }
    
    public func canBuild(layout: Section) -> Bool {
        assertionFailure("You must override the canBuild() method")
        return false
    }
    
    public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        throw LayoutError.InvalidConfiguration("You must override the build() method")
    }
    
    public func initialize<T: UIView>(layout: Section, instance: Layout, parent: UIView) throws -> T {
        var view: T
        
        var id = layout.path
        if layout.hasValue("id") {
            id = layout.getValue("id")!
        }
        
        if instance.hasView(id) {
            if instance.laidOut == false {
                throw LayoutError.InvalidConfiguration("Duplicate view id: \(id)")
            }
            view = instance.findView(id) as! T
        } else {
            view = T()
            instance.views[id] = view
            
            if let model = instance.model where layout.hasValue("id") {
                if model.respondsToSelector(Selector("\(id)")) {
                    model.setValue(view, forKey: id)
                }
            }
        }

        return try initialize(view, layout: layout, instance: instance, parent: parent)
    }
    
    public func initialize<T: UIView>(view: T, layout: Section, instance: Layout, parent: UIView) throws -> T {
        var id = layout.path
        if layout.hasValue("id") {
            id = layout.getValue("id")!
        }
        
        if !instance.hasView(id) {
            instance.views[id] = view
            
            if let model = instance.model where layout.hasValue("id") {
                if model.respondsToSelector(Selector("\(id)")) {
                    model.setValue(view, forKey: id)
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
        
        if layout.hasValue("center-anchor") {
            let constrain = view.centerXAnchor.constraintEqualToAnchor(view.superview!.centerXAnchor, constant: 200)
            
            constrain.active = true
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