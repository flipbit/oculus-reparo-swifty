import Foundation
import UIKit

public class LayerBuilder {
    public init() {
    }
    
    public func canBuild(layout: Section) -> Bool {
        return false
    }
    
    public func build(layout: Section, instance: Layout, parent: UIView) throws -> CALayer {
        return CALayer()
    }
    
    public func initialize<T: CALayer>(layout: Section, instance: Layout, parent: UIView) throws -> T {
        var layer: T
        
        var layerId = layout.path
        if layout.hasValue("id") {
            layerId = layout.getValue("id")!
        }
        
        if instance.hasLayer(layerId) {
            layer = instance.findLayer(layerId) as! T
        } else {
            layer = T()
            instance.layers[layerId] = layer
        }
        
        layer.frame = try getFrame(layout, parent: parent)
        layer.backgroundColor = try layout.getCGColor("background-color")
        layer.zPosition = layout.getCGFloat("z-position", ifMissing: 10)
        layer.cornerRadius = layout.getCGFloat("corner-radius", ifMissing: 0)
        layer.borderColor = try layout.getCGColor("border-color")
        layer.borderWidth = layout.getCGFloat("border-width", ifMissing: 0)
        layer.opacity = layout.getFloat("opacity", ifMissing: 1)
        layer.hidden = try layout.getBool("hidden")
        
        if layer.superlayer == nil {
            parent.layer.addSublayer(layer)
        }
        
        return layer
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