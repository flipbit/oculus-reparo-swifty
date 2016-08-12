import Foundation
import UIKit

public class UIViewBuilder : ViewBuilder {
    override public func canBuild(layout: Section) -> Bool {
        return layout.key == "view"
    }
    
    override public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let view: UIView = try initialize(layout, instance: instance, parent: parent)
        
        return view;
    }
}
