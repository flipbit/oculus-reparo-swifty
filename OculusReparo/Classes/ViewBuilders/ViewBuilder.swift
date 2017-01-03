import Foundation
import UIKit

open class ViewBuilder {
    public init() {
    }
    
    open func canBuild(_ layout: Section) -> Bool {
        assertionFailure("You must override the canBuild() method")
        return false
    }
    
    open func build(_ layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        throw LayoutError.invalidConfiguration("You must override the build() method")
    }
    
    open func initialize<T: UIView>(_ layout: Section, instance: Layout, parent: UIView) throws -> T {
        var view: T
        
        var id = layout.path
        if let viewId = layout.getString("id") {
            id = viewId
        }
        
        if instance.hasView(id) {
            if instance.laidOut == false {
                throw LayoutError.invalidConfiguration("Duplicate view id: \(id)")
            }
            view = instance.findView(id) as! T
            Layout.debugger?.debug("Found view: \(id)")
        } else {
            view = T()
            let fragment = LayoutViewFragment(view: view, id: id, configuration: layout)
            instance.viewFragments[id] = fragment
            
            if let model = instance.model, layout.hasValue("id") {
                if model.responds(to: Selector("\(id)")) {
                    model.setValue(view, forKey: id)
                }
            }
            
            Layout.debugger?.debug("Created view: \(id)")
        }

        return try initialize(view, layout: layout, instance: instance, parent: parent)
    }
    
    open func initialize<T: UIView>(_ view: T, layout: Section, instance: Layout, parent: UIView) throws -> T {
        var id = layout.path
        if let viewId = layout.getString("id") {
            id = viewId
        }
        
        if !instance.hasView(id) {
            let fragment = LayoutViewFragment(view: view, id: id, configuration: layout)
            instance.viewFragments[id] = fragment
            
            if let model = instance.model, layout.hasValue("id") {
                if model.responds(to: Selector("\(id)")) {
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

        view.backgroundColor = try layout.getUIColor("background-color", ifMissing: UIColor.clear)
        view.layer.zPosition = layout.getCGFloat("z-position", ifMissing: 0)
        view.layer.cornerRadius = layout.getCGFloat("corner-radius", ifMissing: 0)
        view.layer.borderColor = try layout.getCGColor("border-color")
        view.layer.borderWidth = layout.getCGFloat("border-width", ifMissing: 0)
        view.layer.opacity = layout.getFloat("opacity", ifMissing: 1)
        view.clipsToBounds = try layout.getBool("clips-to-bounds", or: false)
        view.isHidden = try layout.getBool("hidden", or: false)
        view.isUserInteractionEnabled = try layout.getBool("user-interaction-enabled", or: true)
        view.accessibilityIdentifier = layout.getString("accessibility-identifier")
        
        
        if view.superview == nil {
            parent.addSubview(view)
        }
        
        return view
    }

    open func getPosition(_ layout: Section, parent: UIView) throws -> Position? {
        if let config = layout.getSection("position") {
            return try Position(section: config, parent: parent)
        }
        
        return nil
    }
    
    open func getFrame(_ layout: Section, view: UIView, parent: UIView, instance: Layout) throws -> CGRect {
        var frame = CGRect.zero
        
        if let position = try getPosition(layout, parent: parent) {
            let lastSiblingFrame = position.getLastSiblingViewFrame(view)
            frame = position.toFrame(lastSiblingFrame)
        }
        
        Layout.debugger?.debug(" -> Set frame: \(frame)")
        
        return frame
    }
}
