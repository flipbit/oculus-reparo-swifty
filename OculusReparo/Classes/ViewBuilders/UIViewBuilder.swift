import Foundation
import UIKit

open class UIViewBuilder : ViewBuilder {
    override open func canBuild(_ layout: Section) -> Bool {
        return layout.key == "view"
    }
    
    override open func build(_ layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let view: UIView = try initialize(layout, instance: instance, parent: parent)
        
        return view;
    }
}
