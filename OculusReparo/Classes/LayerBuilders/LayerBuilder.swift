import Foundation
import UIKit

public class LayerBuilder {
    public init() {
    }
    
    public func canBuild(layout: Section) -> Bool {
        assertionFailure("You must override the canBuild() method")
        return false
    }
    
    public func build(layout: Section, instance: Layout, parent: CALayer) throws -> CALayer {
        assertionFailure("You must override the build() method")
        return CALayer()
    }
    
    public func initialize<T: CALayer>(layout: Section, instance: Layout, parent: CALayer) throws -> T {
        var layer: T
        
        var layerId = layout.path
        if let id = layout.getString("id") {
            layerId = id
        }
        
        if instance.hasLayer(layerId) {
            layer = instance.findLayer(layerId) as! T
            Layout.debugger?.debug("Found layer: \(layerId)")
        } else {
            layer = T()
            let fragment = LayoutLayerFragment(layer: layer, id: layerId, configuration: layout)
            instance.layerFragments[layerId] = fragment
            Layout.debugger?.debug("Created layer: \(layerId)")
            
            if let model = instance.model where layout.hasValue("id") {
                if model.respondsToSelector(Selector("\(layerId)")) {
                    model.setValue(layer, forKey: layerId)
                }
            }
        }
        
        layer.frame = try getFrame(layout, layer: layer, parent: parent, instance: instance)
        layer.backgroundColor = try layout.getCGColor("background-color")
        layer.zPosition = layout.getCGFloat("z-position", ifMissing: 10)
        layer.cornerRadius = layout.getCGFloat("corner-radius", ifMissing: 0)
        layer.borderColor = try layout.getCGColor("border-color")
        layer.borderWidth = layout.getCGFloat("border-width", ifMissing: 0)
        layer.opacity = layout.getFloat("opacity", ifMissing: 1)
        layer.hidden = try layout.getBool("hidden", or: false)
        
        if layer.superlayer == nil {
            parent.addSublayer(layer)
        }
        
        return layer
    }
    
    public func getPosition(layout: Section, parent: CALayer) throws -> Position {
        guard let config = layout.getSection("position") else {
            let message = "[\(layout.key) is missing a Position section"
            
            let info = LayoutErrorInfo(message: message, filename: layout.filename, lineNumber: layout.lineNumber)
            
            throw LayoutError.ConfigurationError(info)
        }
        
        return try Position(section: config, parent: parent)
    }
    
    public func getFrame(layout: Section, layer: CALayer, parent: CALayer, instance: Layout) throws -> CGRect {
        let position = try getPosition(layout, parent: parent)
        let lastSiblingFrame = position.getLastSiblingLayerFrame(layer)
        let frame = position.toFrame(lastSiblingFrame)
        
        Layout.debugger?.debug(" -> Set frame: \(frame)")
        
        return frame
    }
}
