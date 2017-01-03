import Foundation
import UIKit

/// View builder for a UIActivityIndicatorView object
open class UIActivityIndicatorBuilder : ViewBuilder {
    override open func canBuild(_ layout: Section) -> Bool {
        return layout.key == "activity-indicator"
    }
    
    override open func build(_ layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let view: UIActivityIndicatorView = try initialize(layout, instance: instance, parent: parent)
        
        if let color = try layout.getUIColor("color") {
            view.color = color
        }
        
        return view;
    }
}
