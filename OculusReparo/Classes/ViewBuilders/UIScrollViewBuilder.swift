import Foundation
import UIKit

public class UIScrollViewBuilder : ViewBuilder {
    override public func canBuild(layout: Section) -> Bool {
        return layout.key == "scroll"
    }
    
    override public func build(layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let scroll: UIScrollView = try initialize(layout, instance: instance, parent: parent)
        

        scroll.showsVerticalScrollIndicator = try layout.getBool("shows-vertical-scroll-indicator", or: true)
        scroll.showsHorizontalScrollIndicator = try layout.getBool("shows-horizontal-scroll-indicator", or: true)

        // Paging
        if layout.hasValue("paging-enabled") {
            scroll.pagingEnabled = try layout.getBool("paging-enabled", or: true)
        }

        // Scrolling
        if layout.hasValue("scroll-enabled") {
            scroll.scrollEnabled = try layout.getBool("scroll-enabled", or: true)
        }

        // Bouncing
        if layout.hasValue("bounces") {
            scroll.bounces = try layout.getBool("bounces", or: true)
        }
        
        // Set content size
        if let position = try getPosition(layout, parent: parent) {
            let width = layout.getString("content-width", ifMissing: "100%")
            let w = position.getDimension(width, parent: parent.frame.width)
            
            let height = layout.getString("content-height", ifMissing: "100%")
            let h = position.getDimension(height, parent: parent.frame.height)
            
            scroll.contentSize = CGSize(width: w, height: h)
        }
        
        return scroll;
    }
}
