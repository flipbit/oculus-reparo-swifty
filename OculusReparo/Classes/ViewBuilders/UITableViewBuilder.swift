import Foundation

open class UITableViewBuilder : ViewBuilder {
    override open func canBuild(_ layout: Section) -> Bool {
        return layout.key == "table"
    }
    
    override open func build(_ layout: Section, instance: Layout, parent: UIView) throws -> UIView {
        let table: UITableView = try initialize(layout, instance: instance, parent: parent)
        
        table.bounces = try layout.getBool("bounces", or: true)
        table.isScrollEnabled = try layout.getBool("scroll-enabled", or: true)
                
        if try layout.getBool("set-delegate", or: false) {
            if let delegate = instance.eventTarget as? UITableViewDelegate {
                table.delegate = delegate
            } else {
                throw LayoutError.invalidConfiguration("Event target is not a UITableViewDelegate")
            }
        }
        
        if instance.laidOut {
            if let indexes = table.indexPathsForVisibleRows {
                for index in indexes {
                    if let cell = table.cellForRow(at: index) {
                        if cell.frame.width != table.frame.width {
                            cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: table.frame.width, height: cell.frame.height)
                            cell.setNeedsDisplay()
                        }
                    }
                }
            }
        }
        
        if layout.hasValue("section-index-color") {
            table.sectionIndexColor = try layout.getUIColor("section-index-color")
        }

        if layout.hasValue("section-index-background-color") {
            table.sectionIndexBackgroundColor = try layout.getUIColor("section-index-background-color")
        }
        if layout.hasValue("section-index-tracking-background-color") {
            table.sectionIndexTrackingBackgroundColor = try layout.getUIColor("section-index-tracking-background-color")
        }
        
        return table;
    }
}
