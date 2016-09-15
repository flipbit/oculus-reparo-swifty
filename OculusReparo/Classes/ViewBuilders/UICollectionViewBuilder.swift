import Foundation
import UIKit

public class UICollectionViewBuilder : ViewBuilder {
    override public func canBuild(layout: Section) -> Bool {
        return layout.key == "collection"
    }
    
    override public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flow.itemSize = CGSize(width: 100, height: 100)
        flow.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: flow)
        
        collection.frame = try getFrame(layout, view: collection, parent: parent, instance: instance)
        
        try initialize(collection, layout: layout, instance: instance, parent: parent)
        
        collection.bounces = try layout.getBool("bounces", ifMissing: true)
        collection.isScrollEnabled = try layout.getBool("scroll-enabled", ifMissing: true)
        
        return collection;
    }
}
