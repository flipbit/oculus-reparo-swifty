import Foundation
import UIKit

open class UICollectionViewBuilder : ViewBuilder {
    override open func canBuild(_ layout: Section) -> Bool {
        return layout.key == "collection"
    }
    
    override open func build(_ layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flow.itemSize = CGSize(width: 100, height: 100)
        flow.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: flow)
        
        collection.frame = try getFrame(layout, view: collection, parent: parent, instance: instance)
        
        try initialize(collection, layout: layout, instance: instance, parent: parent)
        
        collection.bounces = try layout.getBool("bounces", or: true)
        collection.isScrollEnabled = try layout.getBool("scroll-enabled", or: true)
        
        return collection;
    }
}
