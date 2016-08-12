import Foundation
import UIKit

public class CALayerBuilder : LayerBuilder {
    override public func canBuild(layout: Section) -> Bool {
        return layout.key == "layer"
    }
    
    override public func build(layout: Section, instance: Layout, parent: UIView) throws -> CALayer {
        let layer: CALayer = try initialize(layout, instance: instance, parent: parent)
        
        return layer;
    }
}