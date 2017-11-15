import Foundation
import UIKit

open class UISearchBarBuilder : ViewBuilder {
    override open func canBuild(_ layout: Section) -> Bool {
        return layout.key == "search"
    }
    
    override open func build(_ layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let search: UISearchBar = try initialize(layout, instance: instance, parent: parent)
        
        return search;
    }
}

