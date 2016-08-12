import Foundation
import UIKit

public class UIScrollViewBuilder : ViewBuilder {
    override public func canBuild(layout: Section) -> Bool {
        return layout.key == "scroll"
    }
    
    override public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let scroll: UIScrollView = try initialize(layout, instance: instance, parent: parent)
        
        scroll.bounces = try layout.getBool("bounces", ifMissing: true)
        scroll.scrollEnabled = try layout.getBool("scroll-enabled", ifMissing: true)
        scroll.pagingEnabled = try layout.getBool("paging-enabled")
        scroll.showsVerticalScrollIndicator = try layout.getBool("shows-vertical-scroll-indicator", ifMissing: true)
        scroll.showsHorizontalScrollIndicator = try layout.getBool("shows-horizontal-scroll-indicator", ifMissing: true)
                
        let position = try getPosition(layout, parent: parent)
        
        let width = layout.getValue("content-width", ifMissing: "100%")
        let w = position.getDimension(width, parent: parent.frame.width)
        
        let height = layout.getValue("content-height", ifMissing: "100%")
        let h = position.getDimension(height, parent: parent.frame.height)
        
        scroll.contentSize = CGSize(width: w, height: h)
        
        return scroll;
    }
}
