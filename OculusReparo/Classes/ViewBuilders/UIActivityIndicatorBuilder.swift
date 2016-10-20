import Foundation
import UIKit

/// View builder for a UIActivityIndicatorView object
public class UIActivityIndicatorBuilder : ViewBuilder {
    override public func canBuild(layout: Section) -> Bool {
        return layout.key == "activity-indicator"
    }
    
    override public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let view: UIActivityIndicatorView = try initialize(layout, instance: instance, parent: parent)
        
        if let color = try layout.getUIColor("color") {
            view.color = color
        }
        
        return view;
    }
}
