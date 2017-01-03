import Foundation
import UIKit

open class CALayerBuilder : LayerBuilder {
    override open func canBuild(_ layout: Section) -> Bool {
        return layout.key == "layer"
    }
    
    override open func build(_ layout: Section, instance: Layout, parent: CALayer) throws -> CALayer {
        let layer: CALayer = try initialize(layout, instance: instance, parent: parent)
        
        return layer;
    }
}
