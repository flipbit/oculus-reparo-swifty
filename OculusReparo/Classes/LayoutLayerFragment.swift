import UIKit

open class LayoutLayerFragment : LayoutFragment {
    open var layer: CALayer
    
    public init(layer: CALayer, id: String, configuration: Section) {
        self.layer = layer
        
        super.init(id: id, configuration: configuration)
    }
}
