import UIKit

public class LayoutLayerFragment : LayoutFragment {
    public var layer: CALayer
    
    public init(layer: CALayer, id: String, configuration: Section) {
        self.layer = layer
        
        super.init(id: id, configuration: configuration)
    }
}
