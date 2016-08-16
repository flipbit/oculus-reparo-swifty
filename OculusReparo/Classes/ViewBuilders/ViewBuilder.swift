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
            Layout.debugger?.info("Found view: \(id)")
        } else {
            view = T()
            let fragment = LayoutViewFragment(view: view, id: id, configuration: layout)
            instance.viewFragments[id] = fragment
            
            if let model = instance.model where layout.hasValue("id") {
                if model.respondsToSelector(Selector("\(id)")) {
                    model.setValue(view, forKey: id)
                }
            }
            
            Layout.debugger?.info("Created view: \(id)")
        }

        return try initialize(view, layout: layout, instance: instance, parent: parent)
    }
    
    public func initialize<T: UIView>(view: T, layout: Section, instance: Layout, parent: UIView) throws -> T {
        var id = layout.path
        if layout.hasValue("id") {
            id = layout.getValue("id")!
        }
        
        if !instance.hasView(id) {
            let fragment = LayoutViewFragment(view: view, id: id, configuration: layout)
            instance.viewFragments[id] = fragment
            
            if let model = instance.model where layout.hasValue("id") {
                if model.respondsToSelector(Selector("\(id)")) {
                    model.setValue(view, forKey: id)
                }
            }
        }

        // Set frame on initial layout
        if instance.laidOut == false {
            view.frame = try getFrame(layout, view: view, parent: parent, instance: instance)
        }
        
        // Only set frame if no constraints have been applied on subsequent layouts
        if instance.laidOut && view.translatesAutoresizingMaskIntoConstraints == true {
            view.frame = try getFrame(layout, view: view, parent: parent, instance: instance)
        }

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

    public func getPosition(layout: Section, parent: UIView) throws -> Position? {
        if let config = layout.getSection("position") {
            return try Position(section: config, parent: parent)
        }
        
        return nil
    }
    
    public func getFrame(layout: Section, view: UIView, parent: UIView, instance: Layout) throws -> CGRect {
        var frame = CGRectZero
        
        if let position = try getPosition(layout, parent: parent) {
            let lastSiblingFrame = position.getLastSiblingViewFrame(view)
            frame = position.toFrame(lastSiblingFrame)
        }
        
        Layout.debugger?.info(" -> Set frame: \(frame)")
        
        return frame
    }
}